//
//  SceneDelegate.swift
//  es
//
//  Created by Richard Smith on 2023-04-18.
//

import SwiftUI

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    lazy var initiatorViewModel: SpotifyInitiatorViewModel = { SpotifyInitiatorViewModel.shared }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        let parameters = initiatorViewModel.appRemote.authorizationParameters(from: url)
        
        if let code = parameters?["code"] {
            initiatorViewModel.responseCode = code
        } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            initiatorViewModel.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("No access token error = ", error_description)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let accessToken = initiatorViewModel.appRemote.connectionParameters.accessToken {
            initiatorViewModel.appRemote.connectionParameters.accessToken = accessToken
            initiatorViewModel.appRemote.connect()
        } else if let accessToken = initiatorViewModel.accessToken {
            initiatorViewModel.appRemote.connectionParameters.accessToken = accessToken
            initiatorViewModel.appRemote.connect()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if initiatorViewModel.appRemote.isConnected {
            initiatorViewModel.appRemote.disconnect()
        }
    }
}

