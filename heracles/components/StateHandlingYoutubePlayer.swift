//
//  StateHandlingYoutubePlayer.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 14/02/2025.
//

import SwiftUI
import YouTubePlayerKit

/**
    Youtube Player View with builtin state handling. It displays a ProgressView when the player is loading and a ContentUnavailableView with the error message when the player encounters an error.
 */
struct StateHandlingYoutubePlayer: View {
    var player: YouTubePlayer
    var body: some View {
        YouTubePlayerView(player){ state in
            switch state {
            case .idle:
                ProgressView()
            case .ready:
                EmptyView()
            case .error(let error):
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle.fill",
                    description: Text("YouTube player couldn't be loaded: \(error)")
                )
            }
        }
    }
}

//#Preview {
//    StateHandlingYoutubePlayer()
//}
