//
//  SpotifyAPIError.swift
//  es
//
//  Created by Richard Smith on 2023-04-27.
//

import Foundation

enum APIError: LocalizedError {
    case invalidRequestError(String)
    
    case transportError(Error)
    
    case invalidResponse
    
    case validationError(String)
    
    case decodingError(Error)
    
    case badOrExpiredToken(String)
    
    case subscribingToPlayerStateError(String)
    
    case appRemoteDisconnectedWithError(Error)
    
    case appRemoteDidFailConnectionAttemptWithError(Error)
    
    case fetchingTokenRequestError(Error)
    
    case fetchingPlayerStateFailedWithError(Error)
    
    case noAccessTokenError(String)
    
    case serverError(statusCode: Int, reason: String? = nil, retryAfter: String? = nil)
    
    var errorDescription: String? {
        switch self {
        case .invalidRequestError(let message):
            return "Invalid request: \(message)"
        case .transportError(let error):
            return "Transport error: \(error)"
        case .invalidResponse:
            return "Invalid response"
        case .validationError(let reason):
            return "Validation error: \(reason)"
        case .decodingError:
            return "Server returned data in .."
        case .badOrExpiredToken(let reason):
            return "Bad or expired token: \(reason)"
        case .subscribingToPlayerStateError(let reason):
            return "Error subscribing to player state: \(reason)"
        case .appRemoteDisconnectedWithError(let error):
            return "App remote disconnected: \(error)"
        case .appRemoteDidFailConnectionAttemptWithError(let error):
            return "App remote did fail connection attempt: \(error)"
        case .fetchingTokenRequestError(let error):
            return "Error fetching token request: \(error)"
        case .fetchingPlayerStateFailedWithError(let error):
            return "Error getting player state: \(error)"
        case .noAccessTokenError(let reason):
            return "No access token error = \(reason)"
        case .serverError(let statusCode, let reason, let retryAfter):
            return "Server error with code \(statusCode), reason: \(reason ?? "no reason given"), retry after \(retryAfter ?? "no retry after provided")"
        }
    }
}

struct APIErrorMessage: Decodable {
    var error: Bool
    var reason: String
}
