//
//  SpotifyPlaylistViewModel.swift
//  es
//
//  Created by Richard Smith on 2023-04-24.
//

import Combine

class SpotifyPlaylistViewModel: ObservableObject {

    @Published var tracks: TracksForPlaylist = TracksForPlaylist(name: "", total: 0, trackObject: [TrackObject(name: "", uri: "")])
    @Published var numberOfTracksLoaded: Int = 0
    @Published var remainingTracksToLoad: Int = 0
    
    @Published private var spotifyPlaylistAPIHandler: SpotifyAPIPlaylistHandler = { SpotifyAPIPlaylistHandler.shared } ()
    @Published private var playlist: Playlist = Playlist(name: "", description: "", playlistID: "", externalURLs: ExternalURLs(spotify: ""), tracks: Tracks(href: "", total: 0))
    
    private var cancellable: AnyCancellable?
    private var playListItemsCancellable: AnyCancellable?
    private var bag = Set<AnyCancellable>()
    
    init(playlist: Playlist) {
        self.playlist = playlist
        
        cancellable = spotifyPlaylistAPIHandler.objectWillChange.sink(receiveValue: { _ in
            self.objectWillChange.send()
        })
    }
    
    func onAppear() {
        loadAllTracks(numberOfTracks: playlist.tracks.total)
        setPlaylistInfo()
    }
    
    private func setPlaylistInfo() {
        self.tracks.name = playlist.name
        self.tracks.total = playlist.tracks.total
        self.remainingTracksToLoad = playlist.tracks.total
    }
    
    private func getTracks(limit: Int, offset: Int) {
        playListItemsCancellable = spotifyPlaylistAPIHandler.getTracksForPlaylist(playlistID: playlist.playlistID, market: "", fields: "", limit: limit, offset: offset, additionalTypes: "")
            .sink { spotifyPlaylistItems in
                self.mapTracks(spotifyPlaylistItems: spotifyPlaylistItems)
            }
    }
    
    private func mapTracks(spotifyPlaylistItems: SpotifyPlaylistItems) {
        let trackObjects: [TrackObject] = spotifyPlaylistItems.items.map { (tracks) in
            return TrackObject(name: tracks?.track?.name ?? "", uri: tracks?.track?.uri ?? "")
        }
    
        self.tracks.trackObject.insert(contentsOf: trackObjects, at: numberOfTracksLoaded)
        self.numberOfTracksLoaded = self.tracks.trackObject.count
        
        if self.tracks.total != self.tracks.trackObject.count {
            self.loadAllTracks(numberOfTracks: remainingTracksToLoad)
        }
    }
    
    func loadAllTracks(numberOfTracks: Int) {
        var limit = 50
        
        if numberOfTracks <= 50 {
            limit = numberOfTracks
            self.getTracks(limit: limit, offset: 0)
            return
        }
        
        if numberOfTracksLoaded == numberOfTracks {
            return
        } else {
            self.getTracks(limit: limit, offset: numberOfTracksLoaded)
        }
    }
    
    private func shufflePlaylist() {
        
    }
    
    private func pauseSong() {
        
    }
    
    private func playSong() {
        
    }
}
