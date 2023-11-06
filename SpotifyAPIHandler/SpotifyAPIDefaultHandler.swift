//
//  SpotifyAPIDefaultHandler.swift
//  es
//
//  Created by Richard Smith on 2023-04-17.
//

import Foundation
import Combine

class SpotifyAPIDefaultHandler: NSObject, ObservableObject {
    
    
    static let shared = SpotifyAPIDefaultHandler()
    
    
    // MARK: - API
    
    func fetchAccessToken(responseCode: String?) -> AnyPublisher<SpotifyAccessToken, Error> {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            return Fail(error:APIError.invalidRequestError("Invalid URL"))
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        guard let spotifyAuthKeyValues = (spotifyClientID + ":" + spotifyCLientSecretKey).data(using: .utf8)?.base64EncodedString() else {
            return Fail(error: APIError.invalidRequestError("Invalid SpotifyAuthKey"))
                .eraseToAnyPublisher()
        }

        let spotifyAuthKey = "Basic \(spotifyAuthKeyValues)"

        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
                                       "Content-Type": "application/x-www-form-urlencoded"]
        var requestBodyComponents = URLComponents()
        let scopeAsString = stringScopes.joined(separator: " ")

        guard let nonOptionalResponseCode = responseCode else {
            return Fail(error: APIError.invalidRequestError("Invalid response code"))
                .eraseToAnyPublisher()
        }

        requestBodyComponents.queryItems = [
            URLQueryItem(name: "client_id", value: spotifyClientID),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: responseCode),
            URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString),
            URLQueryItem(name: "code_verifier", value: ""), // not currently used
            URLQueryItem(name: "scope", value: scopeAsString)]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)

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
                    throw APIError.serverError(statusCode: urlResponse.statusCode, reason: apiError.reason, retryAfter: "")
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
            .tryMap { data -> SpotifyAccessToken in
                let decoder = JSONDecoder()
                do {
                    return try
                    decoder.decode(SpotifyAccessToken.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
