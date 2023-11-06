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
    
    @Published private var spotifyInitiatorViewModel: SpotifyAPIDefaultHandler = { SpotifyAPIDefaultHandler.shared } ()
    
    @Published var authState: AuthenticationState = AuthenticationState.idle
    
    var loginTitle = String(localized: "loginTextFieldTitleForNotConnected")
    var userConnectionButtonTitle = String(localized: "loginUserConnectionButtonTitleForNotConnected")

    private var cancellable: AnyCancellable?

    private var bag = Set<AnyCancellable>()
    
    init() {
        bind()
    }
    
    func connectUser() {
        self.spotifyInitiatorViewModel.connectUser()
    }
    
    private func bind() {
        cancellable = spotifyInitiatorViewModel.objectWillChange.sink(receiveValue: { _ in
            self.objectWillChange.send()
        })
        
        
        spotifyInitiatorViewModel.$authenticationState
            .sink { authState in
                self.authState = authState
            }.store(in: &bag)
    }
}
