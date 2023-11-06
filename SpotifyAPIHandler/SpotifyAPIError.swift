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
        case .serverError(let statusCode, let reason, let retryAfter):
            return "Server error with code \(statusCode), reason: \(reason ?? "no reason given"), retry after \(retryAfter ?? "no retry after provided")"
        }
    }
}

struct APIErrorMessage: Decodable {
    var error: Bool
    var reason: String
}
