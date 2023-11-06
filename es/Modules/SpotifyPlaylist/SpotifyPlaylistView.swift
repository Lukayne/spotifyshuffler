//
//  SpotifyPlaylistView.swift
//  es
//
//  Created by Richard Smith on 2023-04-24.
//

import SwiftUI

struct SpotifyPlaylistView: View {
    
    @EnvironmentObject var spotifyPlaylistViewModel: SpotifyPlaylistViewModel
    
    var body: some View {
        Text("Playlist: \(spotifyPlaylistViewModel.tracks.name)")
        Text("Number of songs: \(spotifyPlaylistViewModel.tracks.total)")
        Text("Number of songs loaded: \(spotifyPlaylistViewModel.numberOfTracksLoaded)")
        Text("Loading: \(spotifyPlaylistViewModel.remainingTracksToLoad) songs")
        List(spotifyPlaylistViewModel.tracks.trackObject) { track in
            VStack {
                Text("Song: \(track.name)")
                Text("URI: \(track.uri)")
            }
        }
            .onAppear(perform: spotifyPlaylistViewModel.onAppear)
    }
}

struct SpotifyPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyPlaylistView()
    }
}
