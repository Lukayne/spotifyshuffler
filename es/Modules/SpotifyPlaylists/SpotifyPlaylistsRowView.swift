//
//  SpotifyPlaylistsRowView.swift
//  es
//
//  Created by Richard Smith on 2023-11-07.
//

import SwiftUI

struct SpotifyPlaylistsRowView: View {
    
    var playlist: Playlist
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Name of the playlist: \(playlist.name)")
                .multilineTextAlignment(.leading)
                .font(.title3)
            Text("Description: \(playlist.description)")
                .multilineTextAlignment(.leading)
                .font(.subheadline)
            Text("Number of songs: \(playlist.tracks.total)")
                .multilineTextAlignment(.leading)
                .font(.subheadline)
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
    }
}

struct SpotifyPlaylistsRowView_Preview: PreviewProvider {
    static var previews: some View {
        SpotifyPlaylistsRowView(playlist: Playlist(name: "Indie top 50", description: "Indie playlist showcasing...", playlistID: "ID", externalURLs: ExternalURLs(spotify: "URL"), tracks: Tracks(href: "HREF", total: 50)))
    }
}
