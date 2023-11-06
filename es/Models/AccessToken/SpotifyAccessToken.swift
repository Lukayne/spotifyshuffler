//
//  SpotifyAccessToken.swift
//  es
//
//  Created by Richard Smith on 2023-05-02.
//

import Foundation

struct SpotifyAccessToken: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case scope
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
    
    let accessToken: String?
    let tokenType: String?
    let scope: String?
    let expiresIn: Int?
    let refreshToken: String?
}
