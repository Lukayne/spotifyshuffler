//
//  Constants.swift
//  es
//
//  Created by Richard Smith on 2023-04-18.
//

import Foundation

let accessTokenKey = "access-token-key"
let redirectURI = URL(string: "es://")!
let spotifyClientID = "2fa0dce8d41746b4b75b9f102f37281f"
let spotifyCLientSecretKey = "c123c8f0f4764f4285ef31f9fa34606b"

let scopes: SPTScope = [.userReadEmail, .userReadPrivate, .userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying, .streaming, .appRemoteControl, .playlistReadCollaborative, .playlistModifyPublic, .playlistReadPrivate, .playlistModifyPrivate, .userLibraryModify, .userLibraryRead, .userTopRead, .userReadPlaybackState, .userReadCurrentlyPlaying, .userFollowRead, .userFollowModify]
let stringScopes = ["user-read-email", "user-read-private",
                    "user-read-playback-state", "user-modify-playback-state", "user-read-currently-playing",
                    "streaming", "app-remote-control",
                    "playlist-read-collaborative", "playlist-modify-public", "playlist-read-private", "playlist-modify-private",
                    "user-library-modify", "user-library-read",
                    "user-top-read", "user-read-playback-position", "user-read-recently-played",
                    "user-follow-read", "user-follow-modify"]
