//
//  SpotiftyPlaybackStartResume.swift
//  es
//
//  Created by Richard Smith on 2023-04-25.
//

import Foundation

struct SpotifyPlaybackStartResume: Codable {
    enum CodingKeys: String, CodingKey {
        case uris
    }
    
    let uris: [String]
}
