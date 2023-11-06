//
//  SpotifyPlaylistsViewModel.swift
//  es
//
//  Created by Richard Smith on 2023-04-17.
//

import Foundation
import Combine

class SpotifyPlaylistsViewModel: ObservableObject {
    
    @Published private var spotifyPlaylistsAPIHandler: SpotifyAPIPlaylistsHandler = { SpotifyAPIPlaylistsHandler.shared } ()
    @Published private var spotifyInit: SpotifyInitiatorViewModel = { SpotifyInitiatorViewModel.shared } ()
    
    @Published var playLists: SpotifyPlaylists?
    @Published var currentUserProfile: SpotifyCurrentUserProfile?
    
    
    
    private var cancellable: AnyCancellable?
    private var playlistsCancellable: AnyCancellable?
    private var bag = Set<AnyCancellable>()
    
    init() {
        cancellable = spotifyPlaylistsAPIHandler.objectWillChange.sink(receiveValue: { _ in
            self.objectWillChange.send()
        })
    }
    
    
    func onAppear() {
        if (spotifyInit.appRemote.connectionParameters.accessToken != nil) {
            getUserProfile()
        }
    }
    
    func getUserProfile() {
        cancellable = spotifyPlaylistsAPIHandler.getUsersPlaylists().sink(receiveValue: { currentUserProfile in
            self.currentUserProfile = currentUserProfile
            
            if currentUserProfile.uri != nil {
                self.getPlaylists()
            }
        })
    }
    
    func getPlaylists() {
        guard let userURI = self.currentUserProfile?.uri else {
            return
        }
        
        playlistsCancellable = spotifyPlaylistsAPIHandler.getUsersPlaylists(userID: "ricci123", limit: 50, offset: 0).sink(receiveValue: { spotifyPlaylists in
            print("Users playlists: \(spotifyPlaylists)")
        })
    }
}
