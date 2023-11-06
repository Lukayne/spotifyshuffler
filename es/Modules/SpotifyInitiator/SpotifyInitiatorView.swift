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
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject var spotifyInitiatorViewModel = { SpotifyInitiatorViewModel.shared } ()

    var body: some Scene {
        WindowGroup {
            SpotifyLoginView()
        }
    }
}
