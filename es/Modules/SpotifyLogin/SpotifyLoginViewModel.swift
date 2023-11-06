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
    
    @ObservedObject private var spotifyCoordinatorViewModel = SpotifyCoordinatorViewModel()
    
    @Published var loginTitle: String = ""
    @Published var userConnectionButtonTitle: String = ""
    
    
    init() {
        bind()
    }
    
    func changeUserConnectionStatus() {
        if !spotifyCoordinatorViewModel.isUserConnected {
            
        }
    }
    
    private func bind() {
        if !spotifyCoordinatorViewModel.isUserConnected {
            self.loginTitle = String(localized: "loginTextFieldTitleForNotConnected")
            self.userConnectionButtonTitle = String(localized: "loginUserConnectionButtonTitleForNotConnected")
        } else {
            self.loginTitle = String(localized: "loginTextFieldTitleForConnected")
            self.userConnectionButtonTitle = String(localized: "loginUserConnectionButtonTitleForConnected")
        }
    }
}
