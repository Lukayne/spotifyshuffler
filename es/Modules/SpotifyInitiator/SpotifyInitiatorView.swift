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
    @ObservedObject var spotifyAPIDefaultHandler = { SpotifyAPIDefaultHandler.shared } ()

    var body: some Scene {
        WindowGroup {
            SpotifyLoginView()
                .onOpenURL { url in
                    spotifyAPIDefaultHandler.onOpenURL(url: url)
                }
                .onAppear {
                    spotifyAPIDefaultHandler.didBecomeActive()
                }
                .onDisappear {
                    spotifyAPIDefaultHandler.willResignActive()
                }
        }
    }
}
