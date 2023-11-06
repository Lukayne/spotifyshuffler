//
//  Playlists.swift
//  es
//
//  Created by Richard Smith on 2023-04-21.
//

import Foundation

struct Playlists: Identifiable {
    let id = UUID()
    
    var name: String
    var description: String
    var externalURLs: ExternalURLs
    var tracks: Tracks
}
