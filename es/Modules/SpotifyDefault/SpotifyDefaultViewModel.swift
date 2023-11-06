//
//  SpotifyDefaultViewModel.swift
//  es
//
//  Created by Richard Smith on 2023-05-02.
//

import Foundation
import Combine

enum AuthenticationState: Equatable, CaseIterable {
    case idle
    case loading
    case error
    case authorized
}

class SpotifyDefaultViewModel: NSObject, ObservableObject, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    
    static let shared = SpotifyDefaultViewModel()
    
    @Published var authenticationState: AuthenticationState = .idle
    @Published var currentSongBeingPlayed: String = ""
    @Published var accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: accessTokenKey)
        }
    }
    
    @Published private var responseCode: String = "" {
        didSet {
            spotifyDefaultAPIHandler.fetchAccessToken(responseCode: responseCode)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(APIError.fetchingTokenRequestError(error))
                    }
                }, receiveValue: { [weak self] spotifyAccessToken in
                    if let accessToken = spotifyAccessToken.accessToken {
                        self?.appRemote.connectionParameters.accessToken = accessToken
                        self?.appRemote.connect()
                    }
                }).store(in: &bag)
        }
    }
    
    private let spotifyDefaultAPIHandler = { SpotifyAPIDefaultHandler.shared }()
    private var bag = Set<AnyCancellable>()

    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: spotifyClientID, redirectURL: redirectURI)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = ""

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
                print(APIError.fetchingPlayerStateFailedWithError(error))
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
            }
        })
    }

    func update(playerState: SPTAppRemotePlayerState) {
        lastPlayerState = playerState
    }

    func onOpenURL(url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)

        if let code = parameters?["code"] {
            responseCode = code
        } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print(APIError.noAccessTokenError(error_description))
        }
    }

    func didBecomeActive() {
        if let accessToken = appRemote.connectionParameters.accessToken {
            appRemote.connectionParameters.accessToken = accessToken
            appRemote.connect()
        } else if let accessToken = accessToken {
            appRemote.connectionParameters.accessToken = accessToken
            appRemote.connect()
        }
    }

    func willResignActive() {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }

    func connectUser() {
        guard let sessionManager = try? sessionManager else { return }
        sessionManager.initiateSession(with: scopes, options: .clientOnly)
        self.authenticationState = .loading
    }

    func pausePlayback() {
        appRemote.playerAPI?.pause()
    }

    func startPlayback() {
        appRemote.playerAPI?.resume()
    }

    // MARK: - SPTSessionManagerDelegate

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
    }

    // MARK: - SPTAppRemoteDelegate

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print(APIError.subscribingToPlayerStateError(error.localizedDescription))
                self.authenticationState = .error
            }

            self.authenticationState = .authorized
        })

        fetchPlayerState()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        connectUser()
        if let error {
            print(APIError.appRemoteDisconnectedWithError(error))
        }
        
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        if let error {
            print(APIError.appRemoteDidFailConnectionAttemptWithError(error))
        }
        connectUser()
        lastPlayerState = nil
    }

    // MARK: - SPTAppRemotePlayerAPIDelegate

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        lastPlayerState = playerState
        currentSongBeingPlayed = playerState.track.name
    }
}
