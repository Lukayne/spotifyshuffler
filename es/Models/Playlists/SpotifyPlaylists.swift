//
//  SpotifyPlaylists.swift
//  es
//
//  Created by Richard Smith on 2023-04-18.
//

import Foundation

struct SpotifyPlaylists: Codable {

    enum CodingKeys: String, CodingKey {
        case href, limit, next, offset, previous, total, items
    }
    
    let href: String?
    let items: [SimplifiedPlaylistObject?]
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
}
