//
//  BubbleAudioView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 28.05.24.
//

import SwiftUI

struct BubbleAudioView: View {
    @EnvironmentObject private var voiceMessagePlayer: VoiceMessagePlayer
    @State private var playbackState: VoiceMessagePlayer.PlaybackState = .stopped
    
    let item: MessageItem
    
    @State private var sliderValue: Double = 0
    @State private var sliderRange: ClosedRange<Double> = 0...20
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            
            if item.showGroupPartnerInfo {
                CircularProfileImageView(
                    profileImageUrl: item.sender?.profileImageUrl,
                    size: .mini
                )
            }
            
            
            if item.direction == .sent {
                timeStampTextView()
            }
            
            HStack {
                playButton()
                Slider(value: $sliderValue, in: sliderRange)
                    .tint(.gray)
                
                Text("04:00")
                    .foregroundStyle(.gray)
                
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .padding(5)
            .background(item.backgroundColor)
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .applyTail(item.direction)
            
            if item.direction == .received {
                timeStampTextView()
            }
        }
        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.trailingPadding)
        .onReceive(voiceMessagePlayer.$playbackState) { state in
            observePlaybackState(state)
        }
    }
    
    private func playButton() -> some View {
        Button {
            handlePlayVoiceMessage()
        } label: {
            Image(systemName: "play.fill")
                .padding(10)
                .background(item.direction == .received ? .green : .white)
                .clipShape(.circle)
                .foregroundStyle(item.direction == .sent ? .black : .white)
        }
    }
    
    private func timeStampTextView() -> some View {
        Text("3:05 PM")
            .font(.footnote)
            .foregroundStyle(.gray)
    }
}

// MARK: - VoiceMessagePlayer Playback States

extension BubbleAudioView {
    
    private func handlePlayVoiceMessage() {
        if playbackState == .stopped || playbackState == .paused {
            guard let audioMessageURL = item.audioURL,
                  let voiceMessageUrl = URL(string: audioMessageURL) else { return }
            voiceMessagePlayer.playAudio(from: voiceMessageUrl)
        } else {
            voiceMessagePlayer.pauseAudio()
        }
    }
    
    private func observePlaybackState(_ state: VoiceMessagePlayer.PlaybackState) {
        if state == .stopped {
            playbackState = .stopped
            sliderValue = 0
        } else {
            playbackState = state
        }
    }
}

#Preview {
    ScrollView {
        BubbleAudioView(item: MessageItem.stubMessages[3])
        BubbleAudioView(item: MessageItem.stubMessages[2])
           
    }
    .padding(.horizontal)
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.4))
    .onAppear {
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
   
   
}
