//
//  SpotifyPlaylistsView.swift
//  es
//
//  Created by Richard Smith on 2023-04-17.
//

import SwiftUI

struct SpotifyPlaylistsView: View {
    
    @StateObject var spotifyPlaylistsViewModel = SpotifyPlaylistsViewModel()
    
    var body: some View {
        List {
            
        }
        .onAppear(perform: spotifyPlaylistsViewModel.onAppear)
    }
}

struct SpotifyPlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyPlaylistsView()
    }
}
