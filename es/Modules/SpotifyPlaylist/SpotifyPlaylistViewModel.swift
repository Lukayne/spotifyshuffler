//
//  SpotifyPlaylistViewModel.swift
//  es
//
//  Created by Richard Smith on 2023-04-24.
//

import Combine

enum State: Equatable, CaseIterable  {
    case notInitiated
    case loading
    case loadedAllSongs
}

class SpotifyPlaylistViewModel: ObservableObject {

    @Published var tracks: TracksForPlaylist = TracksForPlaylist(name: "", total: 0, trackObject: [TrackObject(name: "", uri: "")])
    @Published var numberOfTracksLoaded: Int = 0
    @Published var remainingTracksToLoad: Int = 0
    @Published var state: State = State.notInitiated
    
    @Published private var spotifyPlaylistAPIHandler: SpotifyAPIPlaylistHandler = { SpotifyAPIPlaylistHandler.shared } ()
    @Published private var playlist: Playlist = Playlist(name: "", description: "", playlistID: "", externalURLs: ExternalURLs(spotify: ""), tracks: Tracks(href: "", total: 0))
    @Published private var alreadyShuffledIndexes: [Int] = [Int]()
    
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
        
        if self.tracks.trackObject[0].name == "" {
            self.tracks.trackObject.removeFirst()
            self.tracks.trackObject.insert(contentsOf: trackObjects, at: self.tracks.trackObject.startIndex)
            print("CURRENT COUNT: \(self.tracks.trackObject.count)") 
        } else {
            self.tracks.trackObject.insert(contentsOf: trackObjects, at: self.tracks.trackObject.endIndex)
        }
        
        self.numberOfTracksLoaded = self.tracks.trackObject.count
        
        if self.tracks.total != self.tracks.trackObject.count {
            self.loadAllTracks(numberOfTracks: remainingTracksToLoad)
        } else {
            self.state = .loadedAllSongs
        }
    }
    
    func loadAllTracks(numberOfTracks: Int) {
        var limit = 50
        
        if numberOfTracks <= 50 {
            limit = numberOfTracks
            self.state = .loading
            self.getTracks(limit: limit, offset: 0)
            return
        }
        
        if numberOfTracksLoaded == numberOfTracks {
            self.state = .loadedAllSongs
            return
        } else {
            self.state = .loading
            self.getTracks(limit: limit, offset: numberOfTracksLoaded)
        }
    }
    
    private func getRandomNumber() -> Int {
        var randomInt = Int.random(in: 0...tracks.trackObject.count)
        while alreadyShuffledIndexes.contains(randomInt) {
            randomInt = Int.random(in: 0...tracks.trackObject.count)
        }
        alreadyShuffledIndexes.append(randomInt)
        
        return randomInt
    }
    
    private func shuffleRandomSong(randomIndex: Int) {
        let randomTrack = self.tracks.trackObject[randomIndex]
        
        self.spotifyPlaylistAPIHandler.shuffleSong(songURI: randomTrack.uri)
    }
    
    private func pauseSong() {
        
    }
    
    func playSong() {
        shuffleRandomSong(randomIndex: self.getRandomNumber())
    }
    
    private func nextSong() {
        
    }
    
    private func previousSong() {
        
    }
}
