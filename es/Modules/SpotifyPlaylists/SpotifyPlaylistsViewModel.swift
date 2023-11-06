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
    @Published private var spotifyInit: SpotifyAPIDefaultHandler = { SpotifyAPIDefaultHandler.shared } ()
    @Published private var currentUserProfile: SpotifyCurrentUserProfile?
    
    @Published var numberOfPlaylists: Int = 0
    @Published var playlists: [Playlist] = [Playlist(name: "", description: "", playlistID: "", externalURLs: ExternalURLs(spotify: ""), tracks: Tracks(href: "", total: 0))]
    @Published var user: User = User(name: "")

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
    
    private func getUserProfile() {
        cancellable = spotifyPlaylistsAPIHandler.getCurrentUserProfile().sink(receiveValue: { currentUserProfile in
            self.currentUserProfile = currentUserProfile
            
            if currentUserProfile.uri != nil {
                self.mapSpotifyUser(spotifyUser: currentUserProfile)
                self.getPlaylists()
            }
        })
    }
    
    private func getPlaylists() {
        guard let userID = self.currentUserProfile?.id else {
            return
        }
        
        
        playlistsCancellable = spotifyPlaylistsAPIHandler.getUsersPlaylists(userID: userID, limit: 50, offset: 0)
            .sink(receiveValue: { spotifyPlaylists in
                self.mapSpotifyPlaylists(spotifyPlaylists: spotifyPlaylists)
            })
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
