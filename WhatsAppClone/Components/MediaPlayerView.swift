//
//  MediaPlayerView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 09.09.24.
//

import SwiftUI
import AVKit

struct MediaPlayerView: View {
    
    let player: AVPlayer
    let dismissPlayer: () -> Void
    
    var body: some View {
        VideoPlayer(player: player)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                cancelButton()
                    .padding()
            }
            .onAppear { player.play() }
    }
    
    private func cancelButton() -> some View {
        Button {
            dismissPlayer()
        } label: {
            Image(systemName: "xmark")
                .scaledToFit()
                .imageScale(.large)
                .padding(10)
                .foregroundStyle(.white)
                .background(.white.opacity(0.5))
                .clipShape(.circle)
                .shadow(radius: 5)
                .padding(2)
                .bold()
            
        }
    }
}
