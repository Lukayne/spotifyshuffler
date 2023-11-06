//
//  SpotifyExternalURLs.swift
//  es
//
//  Created by Richard Smith on 2023-04-20.
//

import Foundation

struct SpotifyExternalURLs: Codable {

    enum CodingKeys: String, CodingKey {
        case spotify
    }
    
    let spotify: String?
}
