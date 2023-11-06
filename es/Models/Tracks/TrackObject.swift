//
//  TrackObject.swift
//  es
//
//  Created by Richard Smith on 2023-04-25.
//

import Foundation

struct TrackObject: Identifiable {
    
    let id = UUID()
    
    var name: String
    var uri: String
}
