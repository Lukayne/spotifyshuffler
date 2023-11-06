//
//  SpotifyLoginView.swift
//  es
//
//  Created by Richard Smith on 2023-04-17.
//

import SwiftUI

struct SpotifyLoginView: View {
    @StateObject var spotifyLoginViewModel = SpotifyLoginViewModel()
    
    var body: some View {
        
        switch spotifyLoginViewModel.authState {
        case .idle:
            LazyVStack {
                Text(spotifyLoginViewModel.loginTitle)
                    .font(.title)
                    .padding()
                Button {
                    self.spotifyLoginViewModel.connectUser()
                } label: {
                    Text(self.spotifyLoginViewModel.userConnectionButtonTitle)
                }
            }
        case .loading:
            ProgressView()
        case .error:
            Text("ERROR")
        case .authorized:
            SpotifyPlaylistsView()
        }
    }
}

struct SpotifyLoginView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyLoginView()
    }
}
