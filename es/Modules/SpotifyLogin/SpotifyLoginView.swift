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
        LazyVStack {
            Text(spotifyLoginViewModel.loginTitle)
                .font(.title)
                .padding()
            Button {
                self.spotifyLoginViewModel.changeUserConnectionStatus()
            } label: {
                Text(self.spotifyLoginViewModel.userConnectionButtonTitle)
            }
        }
    }
}

struct SpotifyLoginView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyLoginView()
    }
}
