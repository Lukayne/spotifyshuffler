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
    @StateObject var spotifyInitiatorViewModel = { SpotifyAPIDefaultHandler.shared } ()

    var body: some Scene {
        WindowGroup {
            SpotifyLoginView()
                .onOpenURL { url in
                    spotifyInitiatorViewModel.onOpenURL(url: url)
                }
                .onAppear {
                    spotifyInitiatorViewModel.didBecomeActive()
                }
                .onDisappear {
                    spotifyInitiatorViewModel.willResignActive()
                }
        }
    }
}
