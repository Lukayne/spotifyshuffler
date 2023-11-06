//
//  SpotifyFollowers.swift
//  es
//
//  Created by Richard Smith on 2023-04-20.
//

import Foundation

struct SpotifyFollowers: Codable {
    
    enum CodingKeys: String, CodingKey {
        case href, total
    }
    
    let href: String?
    let total: Int?
}
