//
//  SpotifyLoginViewModel.swift
//  es
//
//  Created by Richard Smith on 2023-04-17.
//

import Foundation
import Combine
import SwiftUI

class SpotifyLoginViewModel: ObservableObject {
    
    @Published private var spotifyCoordinatorViewModel = SpotifyCoordinatorViewModel()
    @Published private var spotifyInitiatorViewModel: SpotifyInitiatorViewModel = { SpotifyInitiatorViewModel.shared } ()
    
    @Published var loginTitle: String = ""
    @Published var userConnectionButtonTitle: String = ""
    @Published var authState: AuthenticationState = AuthenticationState.idle

    var cancellable: AnyCancellable?

    var bag = Set<AnyCancellable>()
    
    init() {
        bind()
    }
    
    func changeUserConnectionStatus() {
        self.connectUser()
    }
    
    private func connectUser() {
        self.spotifyInitiatorViewModel.userInteraction()
    }
    
    private func bind() {
        cancellable = spotifyInitiatorViewModel.objectWillChange.sink(receiveValue: { _ in
            self.objectWillChange.send()
        })
        
        
        spotifyInitiatorViewModel.$authenticationState
            .sink { authState in
                self.authState = authState
            }.store(in: &bag)
        
        if !spotifyCoordinatorViewModel.isUserConnected {
            self.loginTitle = String(localized: "loginTextFieldTitleForNotConnected")
            self.userConnectionButtonTitle = String(localized: "loginUserConnectionButtonTitleForNotConnected")
        } else {
            self.loginTitle = String(localized: "loginTextFieldTitleForConnected")
            self.userConnectionButtonTitle = String(localized: "loginUserConnectionButtonTitleForConnected")
        }
    }
}
