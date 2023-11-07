//
//  SpotifyPlaylistsMainView.swift
//  es
//
//  Created by Richard Smith on 2023-11-07.
//

import SwiftUI

struct SpotifyPlaylistsMainView: View {
    
    @StateObject var spotifyPlaylistsViewModel = SpotifyPlaylistsViewModel()
    
    var body: some View {
        NavigationStack {
            List(spotifyPlaylistsViewModel.playlists) { playlist in
                NavigationLink {
                    SpotifyPlaylistView(spotifyPlaylistViewModel: SpotifyPlaylistViewModel(playlist: playlist))
                } label: {
                    SpotifyPlaylistsRowView(playlist: playlist)
                }
            }
            .navigationTitle("Playlists for \(spotifyPlaylistsViewModel.user.name)")
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: spotifyPlaylistsViewModel.onAppear)
    }
}

struct SpotifyPlaylistsMainView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyPlaylistsMainView()
    }
}
