//
//  SpotifyMusicPlayerView.swift
//  es
//
//  Created by Richard Smith on 2023-04-17.
//

import SwiftUI

struct SpotifyMusicPlayerView: View {
    
    @StateObject var spotifyMusicPlayerViewModel = SpotifyMusicPlayerViewModel()
    
    var body: some View {
        LazyVStack {
            
        }
        .onAppear(perform: self.spotifyMusicPlayerViewModel.fetchPlayerState)
    }
}

struct SpotifyMusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyMusicPlayerView()
    }
}
