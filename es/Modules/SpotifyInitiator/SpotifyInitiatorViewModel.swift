//
//  SpotifyInitiatorViewModel.swift
//  es
//
//  Created by Richard Smith on 2023-04-17.
//

import Foundation
import Combine


class SpotifyInitiatorViewModel: NSObject, ObservableObject, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    
    private let spotifyClientID = "2fa0dce8d41746b4b75b9f102f37281f"
    private let spotifyRedirectURL = URL(string: "rs.ees.es://es")!
    private let spotifyInitialSongURL = "spotify:track:20I6sIOMTCkB6w7ryavxtO"
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: spotifyClientID, redirectURL: spotifyRedirectURL)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = spotifyInitialSongURL

        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()

    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()

    private var lastPlayerState: SPTAppRemotePlayerState?
    
    
    func fetchPlayerState() {
        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
            }
        })
    }
    
    func update(playerState: SPTAppRemotePlayerState) {
            lastPlayerState = playerState
        
            if playerState.isPaused {
            
            } else {
            
            }
        }
    
    func didBecomeActive() {
        let scopes: SPTScope = [
                                    .userReadEmail, .userReadPrivate,
                                    .userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying,
                                    .streaming, .appRemoteControl,
                                    .playlistReadCollaborative, .playlistModifyPublic, .playlistReadPrivate, .playlistModifyPrivate,
                                    .userLibraryModify, .userLibraryRead,
                                    .userTopRead, .userReadPlaybackState, .userReadCurrentlyPlaying,
                                    .userFollowRead, .userFollowModify,
                                ]
        
        sessionManager.initiateSession(with: scopes, options: .clientOnly)
        if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
        }
    }
    
    func willResignActive() {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
        self.appRemote.connect()
    }
    
    func connect() {
        self.appRemote.authorizeAndPlayURI(self.spotifyInitialSongURL)
    }
    
    
    // MARK: - SPTSessionManagerDelegate

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
//        presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
//        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
    }

    // MARK: - SPTAppRemoteDelegate

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
//        updateViewBasedOnConnected()
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
            }
        })
        fetchPlayerState()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
//        updateViewBasedOnConnected()
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
//        updateViewBasedOnConnected()
        lastPlayerState = nil
    }

    // MARK: - SPTAppRemotePlayerAPIDelegate

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
//        update(playerState: playerState)
    }}
