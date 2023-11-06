//
//  SpotifyTrackObject.swift
//  es
//
//  Created by Richard Smith on 2023-04-25.
//

import Foundation

struct SpotifyTrackObject: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case name, uri
    }
    
    let name: String?
    let uri: String?
}
