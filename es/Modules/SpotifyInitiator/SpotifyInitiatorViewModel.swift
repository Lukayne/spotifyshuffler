//
//  SpotifyInitiatorViewModel.swift
//  es
//
//  Created by Richard Smith on 2023-04-17.
//

import Foundation
import Combine

enum AuthenticationState: Equatable, CaseIterable {
    case idle
    case loading
    case error
    case authorized
}

class SpotifyInitiatorViewModel: NSObject, ObservableObject, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    
    static let shared = SpotifyInitiatorViewModel()
    
    override private init() {
        
    }
    
    @Published var authenticationState: AuthenticationState = .idle
    
    var responseCode: String? {
        didSet {
            fetchAccessToken { (dictionary, error) in
                if let error = error {
                    print("Fetching token request error \(error)")
                    return
                }
                let accessToken = dictionary!["access_token"] as! String
                DispatchQueue.main.async {
                    self.appRemote.connectionParameters.accessToken = accessToken
                    self.appRemote.connect()
                }
            }
        }
    }
    
    var accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
        didSet {
           let defaults = UserDefaults.standard
           defaults.set(accessToken, forKey: accessTokenKey)
       }
   }
    
    private let spotifyInitialSongURL = "spotify:track:20I6sIOMTCkB6w7ryavxtO"
    
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
    
    func fetchAccessToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let spotifyAuthKey = "Basic \((spotifyClientID + ":" + spotifyCLientSecretKey).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
                                               "Content-Type": "application/x-www-form-urlencoded"]

                var requestBodyComponents = URLComponents()
                let scopeAsString = stringScopes.joined(separator: " ")

                requestBodyComponents.queryItems = [
                    URLQueryItem(name: "client_id", value: spotifyClientID),
                    URLQueryItem(name: "grant_type", value: "authorization_code"),
                    URLQueryItem(name: "code", value: responseCode!),
                    URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString),
                    URLQueryItem(name: "code_verifier", value: ""), // not currently used
                    URLQueryItem(name: "scope", value: scopeAsString)]
        
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data,                              // is there data
                          let response = response as? HTTPURLResponse,  // is there HTTP response
                          (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                          error == nil else {                           // was there no error, otherwise ...
                              print("Error fetching token \(error?.localizedDescription ?? "")")
                              return completion(nil, error)
                          }
                    let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                    print("Access Token Dictionary=", responseObject ?? "")
                    completion(responseObject, nil)
                }
                task.resume()
    }
    
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
    }
    
    func userInteraction() {
        guard let sessionManager = try? sessionManager else { return }
        sessionManager.initiateSession(with: scopes, options: .clientOnly)
        self.authenticationState = .loading
    }
    
    func bind() {
        
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
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
                self.authenticationState = .error
            }
        
            self.authenticationState = .authorized
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
    
    func updateViewBasedOnConnected() {
        
    }

    // MARK: - SPTAppRemotePlayerAPIDelegate

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
//        update(playerState: playerState)
    }}
