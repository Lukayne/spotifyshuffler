//
//  Tracks.swift
//  es
//
//  Created by Richard Smith on 2023-04-21.
//

import Foundation

struct Tracks: Identifiable {
    let id = UUID() 
    
    var href: String
    var total: Int
}
