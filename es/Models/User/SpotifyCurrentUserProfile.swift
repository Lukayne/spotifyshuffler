//
//  SpotifyCurrentUserProfile.swift
//  es
//
//  Created by Richard Smith on 2023-04-20.
//

import Foundation

struct SpotifyCurrentUserProfile: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case country, email, followers, href, id, images, product, type, uri
        case displayName = "display_name"
        case explicitContent = "explicit_content"
        case externalURLs = "external_urls"
    }
    
    let country: String?
    let displayName: String?
    let email: String?
    let explicitContent: SpotifyExplicitContent?
    let externalURLs: SpotifyExternalURLs?
    let followers: SpotifyFollowers?
    let href: String?
    let id: String?
    let images: [SpotifyImages]?
    let product: String?
    let type: String?
    let uri: String?
}
