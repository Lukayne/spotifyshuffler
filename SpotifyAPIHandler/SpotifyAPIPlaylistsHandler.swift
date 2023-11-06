//
//  SpotifyAPIPlaylistsHandler.swift
//  es
//
//  Created by Richard Smith on 2023-04-18.
//

import Combine

class SpotifyAPIPlaylistsHandler: NSObject, ObservableObject {
    
    static let shared = SpotifyAPIPlaylistsHandler()
    
    private let spotifyInit = { SpotifyAPIDefaultHandler.shared }()

    private override init() {
        
    }

    func getCurrentUserProfile() -> AnyPublisher<SpotifyCurrentUserProfile, Never> {
        let emptySpotifyCurrentUserProfile = SpotifyCurrentUserProfile(country: nil, displayName: nil, email: nil, explicitContent: nil, externalURLs: nil, followers: nil, href: nil, id: nil, images: nil, product: nil, type: nil, uri: nil)
        let url = URL(string: "https://api.spotify.com/v1/me")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + (spotifyInit.appRemote.connectionParameters.accessToken ?? ""), forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: SpotifyCurrentUserProfile.self, decoder: JSONDecoder())
            .replaceError(with: emptySpotifyCurrentUserProfile)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func getUsersPlaylists(userID: String, limit: Int, offset: Int) -> AnyPublisher<SpotifyPlaylists, Never> {
        let emptySpotifyPlaylists = SpotifyPlaylists(href: "", items: [SimplifiedPlaylistObject(collaborative: false, description: "", externalURLs: SpotifyExternalURLs(spotify: ""), href: "", id: "", images: [SpotifyImages(url: "", height: 0, width: 0)], name: "", owner: SpotifyOwner(externalURLs: SpotifyExternalURLs(spotify: ""), followers: SpotifyFollowers(href: "", total: 0), href: "", id: "", type: "", uri: "", displayName: ""), public: false, snapshotID: "", tracks: SpotifyTracks(href: "", total: 0), type: "", uri: "", primaryColor: nil)], limit: 0, next: "", offset: 0, previous: "", total: 0)
        
        let queryItems = [URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)")]
        var urlComponentents = URLComponents(string: "https://api.spotify.com/v1/users/\(userID)/playlists")
        urlComponentents!.queryItems = queryItems
        let url = urlComponentents!.url
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + (spotifyInit.appRemote.connectionParameters.accessToken ?? ""), forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: SpotifyPlaylists.self, decoder: JSONDecoder())
            .replaceError(with: emptySpotifyPlaylists)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
