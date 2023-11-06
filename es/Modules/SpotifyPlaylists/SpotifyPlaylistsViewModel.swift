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
    @Published private var spotifyAPIDefaultHandler: SpotifyAPIDefaultHandler = { SpotifyAPIDefaultHandler.shared } ()
    @Published private var currentUserProfile: SpotifyCurrentUserProfile?
    
    @Published var numberOfPlaylists: Int = 0
    @Published var playlists: [Playlist] = [Playlist(name: "", description: "", playlistID: "", externalURLs: ExternalURLs(spotify: ""), tracks: Tracks(href: "", total: 0))]
    @Published var user: User = User(name: "")

    private var bag = Set<AnyCancellable>()
    
    init() {
        spotifyPlaylistsAPIHandler.objectWillChange.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        }).store(in: &bag)
    }
    
    deinit {
        bag.removeAll()
    }
    
    func onAppear() {
        if (spotifyAPIDefaultHandler.appRemote.connectionParameters.accessToken != nil) {
            getUserProfile()
        }
    }
    
    private func getUserProfile() {
        spotifyPlaylistsAPIHandler.getCurrentUserProfile().sink(receiveValue: { [weak self] currentUserProfile in
            self?.currentUserProfile = currentUserProfile
            
            if currentUserProfile.uri != nil {
                self?.mapSpotifyUser(spotifyUser: currentUserProfile)
                self?.getPlaylists()
            }
        }).store(in: &bag)
    }
    
    private func getPlaylists() {
        guard let userID = self.currentUserProfile?.id else {
            return
        }
        
        
        spotifyPlaylistsAPIHandler.getUsersPlaylists(userID: userID, limit: 50, offset: 0)
            .sink(receiveValue: { [weak self] spotifyPlaylists in
                self?.mapSpotifyPlaylists(spotifyPlaylists: spotifyPlaylists)
            }).store(in: &bag)
    }
    
    private func mapSpotifyPlaylists(spotifyPlaylists: SpotifyPlaylists) {
        let playLists: [Playlist] = spotifyPlaylists.items.map { (playlist) in
            return Playlist(name: playlist?.name ?? "", description: playlist?.description ?? "", playlistID: playlist?.id ?? "", externalURLs: ExternalURLs(spotify: playlist?.externalURLs?.spotify ?? ""), tracks: Tracks(href: playlist?.tracks?.href ?? "", total: playlist?.tracks?.total ?? 0))
        }
        
        self.playlists = playLists
    }
    
    private func mapSpotifyUser(spotifyUser: SpotifyCurrentUserProfile) {
        currentUserProfile.map { (user) in
            self.user.name = user.id ?? ""
        }
    }
}
