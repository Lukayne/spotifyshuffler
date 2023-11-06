//
//  SpotifyPlaylistTrackObject.swift
//  es
//
//  Created by Richard Smith on 2023-04-25.
//

import Foundation

struct SpotifyPlaylistTrackObject: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case track
        case addedAt = "added_at"
        case isLocal = "is_local"
    }
    
    let addedAt: String?
    let isLocal: Bool?
    let track: SpotifyTrackObject?
}
