//
//  SpotifyImages.swift
//  es
//
//  Created by Richard Smith on 2023-04-20.
//

import Foundation

struct SpotifyImages: Codable {
    
    enum CodingKeys: String, CodingKey {
        case url, height, width
    }
    
    let url: String?
    let height: Int?
    let width: Int?
}
