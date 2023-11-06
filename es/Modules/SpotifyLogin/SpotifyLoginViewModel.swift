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
    
    @Published private var spotifyDefaultViewModel: SpotifyDefaultViewModel = { SpotifyDefaultViewModel.shared } ()
    
    @Published var authState: AuthenticationState = AuthenticationState.idle
    
    var loginTitle = String(localized: "loginTextFieldTitleForNotConnected")
    var userConnectionButtonTitle = String(localized: "loginUserConnectionButtonTitleForNotConnected")

    private var bag = Set<AnyCancellable>()
    
    init() {
        bind()
    }
    
    deinit {
        bag.removeAll()
    }
    
    func connectUser() {
        self.spotifyDefaultViewModel.connectUser()
    }
    
    private func bind() {
        spotifyDefaultViewModel.objectWillChange.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        }).store(in: &bag)
        
        
        spotifyDefaultViewModel.$authenticationState
            .sink { [weak self] authState in
                self?.authState = authState
            }.store(in: &bag)
    }
}
