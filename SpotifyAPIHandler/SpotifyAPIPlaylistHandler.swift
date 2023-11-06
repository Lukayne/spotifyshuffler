//
//  SpotifyAPIPlaylistHandler.swift
//  es
//
//  Created by Richard Smith on 2023-04-24.
//

import Combine

class SpotifyAPIPlaylistHandler: NSObject, ObservableObject {
    
    
    static let shared = SpotifyAPIPlaylistHandler()
    
    private let spotifyInit = { SpotifyInitiatorViewModel.shared }()
    
    private override init() {
        
    }
    
    func getTracksForPlaylist(playlistID: String, market: String, fields: String, limit: Int, offset: Int, additionalTypes: String) -> AnyPublisher<SpotifyPlaylistItems, Never> {
        let emptySpotifyPlaylistItems = SpotifyPlaylistItems(href: nil, limit: nil, next: nil, offset: nil, previous: nil, total: nil, items: [SpotifyPlaylistTrackObject(addedAt: nil, isLocal: nil, track: SpotifyTrackObject(name: nil, uri: nil))])
        
        
        var urlComponents = URLComponents(string: "https://api.spotify.com/v1/playlists/\(playlistID)/tracks")
        let queryItems = [URLQueryItem(name: "fields", value: "items(track(name, uri))"),URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)")]
        urlComponents!.queryItems = queryItems
        let url = urlComponents!.url
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + (spotifyInit.appRemote.connectionParameters.accessToken ?? ""), forHTTPHeaderField: "Authorization")
    
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: SpotifyPlaylistItems.self, decoder: JSONDecoder())
            .replaceError(with: emptySpotifyPlaylistItems)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

