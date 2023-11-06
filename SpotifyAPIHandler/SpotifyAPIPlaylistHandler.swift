//
//  SpotifyAPIPlaylistHandler.swift
//  es
//
//  Created by Richard Smith on 2023-04-24.
//

import Combine

class SpotifyAPIPlaylistHandler: NSObject, ObservableObject {
    
    
    static let shared = SpotifyAPIPlaylistHandler()
    
    private let spotifyDefaultViewModel = { SpotifyDefaultViewModel.shared }()
    
    private override init() {
        
    }
    
    func getTracksForPlaylist(playlistID: String, market: String, fields: String, limit: Int, offset: Int, additionalTypes: String) -> AnyPublisher<SpotifyPlaylistItems, Error> {
        var urlComponents = URLComponents(string: "https://api.spotify.com/v1/playlists/\(playlistID)/tracks")
        let queryItems = [URLQueryItem(name: "fields", value: "items(track(name, uri))"),URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)")]
        urlComponents?.queryItems = queryItems
        
        guard let nonOptionalURLComponents = urlComponents else {
            return Fail(error: APIError.invalidRequestError("Invalid URLComponents"))
                .eraseToAnyPublisher()
        }
        
        guard let url = nonOptionalURLComponents.url else {
            return Fail(error: APIError.invalidRequestError("Invalid URL"))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer " + (spotifyDefaultViewModel.appRemote.connectionParameters.accessToken ?? ""), forHTTPHeaderField: "Authorization")
    
        let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: request)
            .mapError { error in
                return APIError.transportError(error)
            }
        
            .tryMap { (data, response) -> (data: Data, response: URLResponse) in
                
                guard let urlResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if (200..<300) ~= urlResponse.statusCode {
                } else {
                    let decoder = JSONDecoder()
                    let apiError = try decoder.decode(APIErrorMessage.self, from: data)
                    
                    if urlResponse.statusCode == 400 {
                        throw APIError.validationError(apiError.reason)
                    }
                    
                    if urlResponse.statusCode == 401 {
                        throw APIError.validationError(apiError.reason)
                    }
                    
                    if (500..<600) ~= urlResponse.statusCode {
                        let retryAfter = urlResponse.value(forHTTPHeaderField: "Retry-After")
                        throw APIError.serverError(statusCode: urlResponse.statusCode, reason: apiError.reason, retryAfter: retryAfter)
                    }
                }
                return (data, response)
            }
        
        return dataTaskPublisher
            .tryCatch { error -> AnyPublisher<(data: Data, response: URLResponse), Error> in
                if case APIError.serverError = error {
                    return Just(Void())
                        .delay(for: 3, scheduler: DispatchQueue.global())
                        .flatMap { _ in
                            return dataTaskPublisher
                        }
                        .eraseToAnyPublisher()
                }
                throw error
            }
            .map(\.data)
            .tryMap { data -> SpotifyPlaylistItems in
                let decoder = JSONDecoder()
                do {
                    return try decoder.decode(SpotifyPlaylistItems.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func shuffleSong(songURI: String) {
        
        guard let url = URL(string: "https://api.spotify.com/v1/me/player/play") else {
            print(APIError.invalidRequestError("Invalid URL"))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer " + (spotifyDefaultViewModel.appRemote.connectionParameters.accessToken ?? ""), forHTTPHeaderField: "Authorization")
        let body = SpotifyPlaybackStartResume(uris: [songURI])
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonData = try jsonEncoder.encode(body)
            
            URLSession.shared.uploadTask(with: request, from: jsonData) { data, urlResponse, error in
                if let error = error {
                    print("error \(error.localizedDescription)")
                }
                
                if let responseCode = (urlResponse as? HTTPURLResponse)?.statusCode, let data = data {
                    guard responseCode == 204 else {
                        print("Invalid response code: \(responseCode)")
                        return
                    }
                    if let responseJSONData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                        print("RESPONSE JSON DATA = \(responseJSONData)")
                    }
                }
            }.resume()
        } catch {
            print("ERROR")
        }
    }
}

