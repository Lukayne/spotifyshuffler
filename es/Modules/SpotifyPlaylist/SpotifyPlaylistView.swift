//
//  SpotifyPlaylistView.swift
//  es
//
//  Created by Richard Smith on 2023-04-24.
//

import SwiftUI

struct SpotifyPlaylistView: View {
    
    @StateObject var spotifyPlaylistViewModel: SpotifyPlaylistViewModel
    
    var body: some View {
        VStack {
            Text("Playlist: \(spotifyPlaylistViewModel.tracks.name)")
            Text("Number of songs: \(spotifyPlaylistViewModel.tracks.total)")
            Text("Number of songs loaded: \(spotifyPlaylistViewModel.numberOfTracksLoaded)")
        }
        switch spotifyPlaylistViewModel.playlistState {
        case .loading:
            Text("Loading: \(spotifyPlaylistViewModel.remainingTracksToLoad) songs")
        case .loadedAllSongs:
            VStack {
                HStack {
                    Button("Resume") {
                        spotifyPlaylistViewModel.resume()
                    }
                    Button("Shuffle a song") {
                        spotifyPlaylistViewModel.playSong()
                    }
                    Button("Pause") {
                        spotifyPlaylistViewModel.pause()
                    }
                }
                Text("Currently playing: \(spotifyPlaylistViewModel.songBeingPlayed)")
            }
        case .notInitiated:
            Text("")
        }
        
        List(spotifyPlaylistViewModel.tracks.trackObject) { track in
            VStack(alignment: .leading, spacing: 12) {
                Text("Song: \(track.name)")
                Text("URI: \(track.uri)")
                    .font(.footnote)
            }
        }
        .onAppear(perform: spotifyPlaylistViewModel.onAppear)
    }
}

struct SpotifyPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyPlaylistView(spotifyPlaylistViewModel: SpotifyPlaylistViewModel(playlist: Playlist(name: "Indie", description: "INDIE TOP 50", playlistID: "Id..", externalURLs: ExternalURLs(spotify: "spotifyurl"), tracks: Tracks(href: "HREF", total: 123))))
    }
}
