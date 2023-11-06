//
//  SpotifyExplicitContent.swift
//  es
//
//  Created by Richard Smith on 2023-04-20.
//

import Foundation

struct SpotifyExplicitContent: Codable {
    
    enum CodingKeys: String, CodingKey {
        case filterEnabled = "filter_enabled"
        case filterLocked = "filter_locked"
        
    }
    
    let filterEnabled: Bool?
    let filterLocked: Bool?
}
