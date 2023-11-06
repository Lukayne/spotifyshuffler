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
    @StateObject var spotifyInitiatorViewModel = SpotifyInitiatorViewModel()
 
    var body: some Scene {
        WindowGroup {
            SpotifyLoginView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    spotifyInitiatorViewModel.didBecomeActive()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    print("applicationWillEnterForeground")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    spotifyInitiatorViewModel.willResignActive()
                }
        }
    }
}
