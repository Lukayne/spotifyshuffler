//
//  SpotifyAPIPlaylistsHandler.swift
//  es
//
//  Created by Richard Smith on 2023-04-18.
//

import Combine

class SpotifyAPIPlaylistsHandler: NSObject, ObservableObject {
    
    static let shared = SpotifyAPIPlaylistsHandler()
    
    private let spotifyInit = { SpotifyInitiatorViewModel.shared }()

    private override init() {
        
    }

    func getUsersPlaylists() -> AnyPublisher<SpotifyCurrentUserProfile, Never> {
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
        let emptySpotifyPlaylists = SpotifyPlaylists(href: nil, items: [SimplifiedPlaylistObject(collaborative: nil, description: nil, externalURLs: nil, href: nil, id: nil, images: [SpotifyImages(url: nil, height: nil, width: nil)], name: nil, owner: nil, public: nil, snapshotID: nil, tracks: nil, type: nil, uri: nil, primaryColor: nil)], limit: nil, next: nil, offset: nil, previous: nil, total: nil)
        
//        let queryItems = [URLQueryItem(name: "limit", value: "50"), URLQueryItem(name: "offset", value: "0")]
//        var urlComponentents = URLComponents(string: "https://api.spotify.com/v1/users/me/playlists")
//        urlComponentents!.queryItems = queryItems
//        let url = urlComponentents!.url
        
        let url = URL(string: "https://api.spotify.com/v1/users/ricci123/playlists?offset=0&limit=20")
        
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
