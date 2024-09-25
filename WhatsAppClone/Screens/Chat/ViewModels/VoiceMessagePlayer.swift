//
//  VoiceMessagePlayer.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 20.09.24.
//

import Foundation
import AVFoundation

final class VoiceMessagePlayer: ObservableObject {
    
    private var player: AVPlayer?
    private(set) var currentURL: URL?
    
    private var playerItem: AVPlayerItem?
    @Published private(set) var playbackState: PlaybackState = .stopped
    @Published private(set) var currentTime = CMTime.zero
    private var currentTimeObserver: Any?
    
    deinit {
        tearDown()
    }
    
    func playAudio(from url: URL) {
        if let currentURL, currentURL == url {
            // resumes a previous voice message that was already playing
            resumePlaying()
        } else {
            // plays voice message
            stopAudioPlayer()
            currentURL = url
            let playerItem = AVPlayerItem(url: url)
            self.playerItem = playerItem
            self.player = AVPlayer(playerItem: playerItem)
            player?.play()
            playbackState = .playing
            observeCurrentPlayerTime()
            observeEndOfPlayback()
        }
    }
    
    func pauseAudio() {
        player?.pause()
        playbackState = .paused
    }
    
    func seek(to timeInterval: TimeInterval) {
        guard let player else { return }
        let targetTime = CMTime(seconds: timeInterval, preferredTimescale: 1)
        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    // MARK: - Private Methods
    
    private func resumePlaying() {
        if playbackState == .paused || playbackState == .stopped {
            player?.play()
            playbackState = .playing
        }
    }
    private func observeCurrentPlayerTime() {
        currentTimeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] currentTime in
            self?.currentTime = currentTime
            print("observeCurrentPlayerTime: \(currentTime)")
        }
    }
    
    private func observeEndOfPlayback() {
        NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: player?.currentItem, queue: .main) { [weak self] _ in
                self?.stopAudioPlayer()
                print("observeEndOfPlayback")
            }
    }
    
    private func stopAudioPlayer() {
        player?.pause()
        player?.seek(to: .zero)
        playbackState = .stopped
        currentTime = .zero
    }
    
    private func removeObservers() {
        guard let currentTimeObserver else { return }
        player?.removeTimeObserver(currentTimeObserver)
        self.currentTimeObserver = nil
        print("removeObservers called")
    }
    
    private func tearDown() {
        removeObservers()
        player = nil
        playerItem = nil
        currentURL = nil
    }
    
}

extension VoiceMessagePlayer {
    enum PlaybackState {
        case stopped, playing, paused
        
        var icon: String {
            self == .playing ? "pause.fill" : "play.fill"
        }
    }
}
