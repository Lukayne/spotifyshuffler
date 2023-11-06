//
//  SpotifyInitiatorView.swift
//  es
//
//  Created by Richard Smith on 2023-04-17.
//

import SwiftUI
import Combine

@main
struct SpotifyInitiatorView: App {
    @ObservedObject var spotifyDefaultViewModel = { SpotifyDefaultViewModel.shared } ()

    var body: some Scene {
        WindowGroup {
            SpotifyLoginView()
                .onOpenURL { url in
                    spotifyDefaultViewModel.onOpenURL(url: url)
                }
                .onAppear {
                    spotifyDefaultViewModel.didBecomeActive()
                }
                .onDisappear {
                    spotifyDefaultViewModel.willResignActive()
                }
        }
    }
}
