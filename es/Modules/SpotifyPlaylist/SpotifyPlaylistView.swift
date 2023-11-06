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
        
        switch spotifyPlaylistViewModel.state {
        case .loading:
            Text("Loading: \(spotifyPlaylistViewModel.remainingTracksToLoad) songs")
        case .loadedAllSongs:
            HStack {
                Button("Previous") {
                    
                }
                Button("Play") {
                    spotifyPlaylistViewModel.playSong()
                }
                Button("Next") {
                    
                }
            }
        case .notInitiated:
            Text("")
        }
        
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
