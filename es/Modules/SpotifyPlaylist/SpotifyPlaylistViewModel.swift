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
    @Published var songBeingPlayed: String = ""
    
    @Published private var spotifyPlaylistAPIHandler: SpotifyAPIPlaylistHandler = { SpotifyAPIPlaylistHandler.shared } ()
    @Published private var playlist: Playlist = Playlist(name: "", description: "", playlistID: "", externalURLs: ExternalURLs(spotify: ""), tracks: Tracks(href: "", total: 0))
    @Published private var alreadyShuffledIndexes: [Int] = [Int]()
    @Published private var spotifyDefaultViewModel: SpotifyDefaultViewModel = { SpotifyDefaultViewModel.shared } ()
    
    private var bag = Set<AnyCancellable>()
    
    init(playlist: Playlist) {
        self.playlist = playlist
        
        spotifyDefaultViewModel.$currentSongBeingPlayed.sink { [weak self] song in
            self?.songBeingPlayed = song 
        }.store(in: &bag)
    }
    
    deinit {
        bag.removeAll()
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
        spotifyPlaylistAPIHandler.getTracksForPlaylist(playlistID: playlist.playlistID, market: "", fields: "", limit: limit, offset: offset, additionalTypes: "")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if case APIError.validationError(let reason) = error {
                        print(reason)
                    }
                    else if case APIError.serverError(statusCode: _, reason: let reason, retryAfter: _) = error {
                        print(reason ?? "Server error")
                    }
                    else if case APIError.badOrExpiredToken(let reason) = error {
                        print (reason)
                    }
                    else {
                        print(error.localizedDescription)
                    }
                }
            }, receiveValue: { [weak self] spotifyPlaylistItems in
                if self?.numberOfTracksLoaded != self?.tracks.total {
                    self?.mapTracks(spotifyPlaylistItems: spotifyPlaylistItems)
                } else {
                    self?.state = .loadedAllSongs
                }
            }).store(in: &bag)
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
        
        numberOfTracksLoaded = tracks.trackObject.count
        
        if tracks.total != tracks.trackObject.count {
            loadAllTracks(numberOfTracks: remainingTracksToLoad)
        } else {
            state = .loadedAllSongs
        }
    }
    
    private func loadAllTracks(numberOfTracks: Int) {
        var limit = 50
        
        if numberOfTracks <= 50 {
            limit = numberOfTracks
            state = .loading
            getTracks(limit: limit, offset: 0)
            return
        }

        if numberOfTracksLoaded == numberOfTracks {
            state = .loadedAllSongs
            return
        } else {
            state = .loading
            getTracks(limit: limit, offset: numberOfTracksLoaded)
        }
    }
    
    private func getRandomNumber() -> Int {
        var randomInt = Int.random(in: 0...tracks.trackObject.count-1)
        while alreadyShuffledIndexes.contains(randomInt) {
            randomInt = Int.random(in: 0...tracks.trackObject.count-1)
        }
        alreadyShuffledIndexes.append(randomInt)
        
        return randomInt
    }
    
    private func shuffleRandomSong(randomIndex: Int) {
        let randomTrack = self.tracks.trackObject[randomIndex]
        
        spotifyPlaylistAPIHandler.shuffleSong(songURI: randomTrack.uri)
    }
    
    func playSong() {
        shuffleRandomSong(randomIndex: getRandomNumber())
    }
    
    func pause() {
        spotifyDefaultViewModel.pausePlayback()
    }
    
    func resume() {
        spotifyDefaultViewModel.startPlayback()
    }
}
