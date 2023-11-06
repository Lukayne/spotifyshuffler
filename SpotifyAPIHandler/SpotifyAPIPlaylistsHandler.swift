//
//  SpotifyAPIPlaylistsHandler.swift
//  es
//
//  Created by Richard Smith on 2023-04-18.
//

import Combine

class SpotifyAPIPlaylistsHandler: NSObject, ObservableObject {
    
    static let shared = SpotifyAPIPlaylistsHandler()
    
    private let spotifyDefaultViewModel = { SpotifyDefaultViewModel.shared }()

    private override init() {
        
    }

    func getCurrentUserProfile() -> AnyPublisher<SpotifyCurrentUserProfile, Error> {
        
        guard let url = URL(string: "https://api.spotify.com/v1/me") else {
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
            .tryMap { data -> SpotifyCurrentUserProfile in
                let decoder = JSONDecoder()
                do {
                    return try decoder.decode(SpotifyCurrentUserProfile.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func getUsersPlaylists(userID: String, limit: Int, offset: Int) -> AnyPublisher<SpotifyPlaylists, Error> {
        let queryItems = [URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)")]
        var urlComponents = URLComponents(string: "https://api.spotify.com/v1/users/\(userID)/playlists")
        urlComponents?.queryItems = queryItems
        
        guard let nonOptionalurlComponents = urlComponents else {
            return Fail(error: APIError.invalidRequestError("Invalid URLComponents"))
                .eraseToAnyPublisher()
        }
    
        guard let url = nonOptionalurlComponents.url else {
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
            .tryMap { data -> SpotifyPlaylists in
                let decoder = JSONDecoder()
                do {
                    return try decoder.decode(SpotifyPlaylists.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
