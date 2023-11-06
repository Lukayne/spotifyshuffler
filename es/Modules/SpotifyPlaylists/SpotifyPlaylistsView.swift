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
                VStack {
                    Text("Name of the playlist: \(playlist.name)")
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text("Description: \(playlist.description)")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text("Number of songs: \(playlist.tracks.total)")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
                .contentShape(Rectangle())
                
                NavigationLink(destination: SpotifyPlaylistView().environmentObject(SpotifyPlaylistViewModel(playlist: playlist))) {
                    Text("Shuffle \(playlist.name)")
                }
            }
        }
//        .navigationTitle("Playlists for \(spotifyPlaylistsViewModel.user.name)")
        .onAppear(perform: spotifyPlaylistsViewModel.onAppear)
    }
}

struct SpotifyPlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyPlaylistsView()
    }
}
