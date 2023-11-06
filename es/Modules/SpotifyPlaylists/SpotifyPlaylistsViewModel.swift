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
    @Published var playLists: SpotifyPlaylists = SpotifyPlaylists(href: "", items: [SimplifiedPlaylistObject(collaborative: false, description: "", externalURLs: SpotifyExternalURLs(spotify: ""), href: "", id: "", images: [SpotifyImages(url: "", height: 0, width: 0)], name: "", owner: SpotifyOwner(externalURLs: SpotifyExternalURLs(spotify: ""), followers: SpotifyFollowers(href: "", total: 0), href: "", id: "", type: "", uri: "", displayName: ""), public: false, snapshotID: "", tracks: SpotifyTracks(href: "", total: 0), type: "", uri: "", primaryColor: 0)], limit: 0, next: "", offset: 0, previous: "", total: 0)
    @Published private var currentUserProfile: SpotifyCurrentUserProfile?
    
    @Published var numberOfPlaylists: Int = 0
    @Published var mappedPlaylists: Playlists = Playlists(name: "", description: "", externalURLs: ExternalURLs(spotify: ""), tracks: Tracks(href: "", total: 0
                                                                                                                ))
    
    
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
        
        spotifyPlaylistsAPIHandler.getUsersPlaylists(userID: "ricci123", limit: 50, offset: 0)
            .compactMap { $0 }
            .assign(to: &$playLists)
    }
    
    private func setNumberOfPlaylists() {
        self.numberOfPlaylists = playLists.total ?? 0
    }
    
    private func mapPlaylist() {
        
    }
}
