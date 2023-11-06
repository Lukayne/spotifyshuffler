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
        NavigationView {
            List(spotifyPlaylistsViewModel.playlists) { playlist in
                VStack(alignment: .leading, spacing: 12) {
                    Text("Name of the playlist: \(playlist.name)")
                        .multilineTextAlignment(.leading)
                        .font(.title3)
                    Text("Description: \(playlist.description)")
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                    Text("Number of songs: \(playlist.tracks.total)")
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                }
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                
                NavigationLink(destination: SpotifyPlaylistView().environmentObject(SpotifyPlaylistViewModel(playlist: playlist))) {
                    Text("Shuffle \(playlist.name)")
                }
                .navigationTitle("Playlists for \(spotifyPlaylistsViewModel.user.name)")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: spotifyPlaylistsViewModel.onAppear)
    }
}

struct SpotifyPlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyPlaylistsView()
    }
}
