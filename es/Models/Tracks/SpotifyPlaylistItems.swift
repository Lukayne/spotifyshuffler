//
//  SpotifyPlaylistItems.swift
//  es
//
//  Created by Richard Smith on 2023-04-25.
//

import Foundation

struct SpotifyPlaylistItems: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case href, limit, next, offset, previous, total, items
    }
    
    let href: String?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
    let items: [SpotifyPlaylistTrackObject?]
}
