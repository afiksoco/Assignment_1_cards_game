//
//  SoundManager.swift
//  CardWar
//

import Foundation
import AVFoundation
import AudioToolbox

/// Centralised audio for the game.
///
/// - Flip and win effects use built-in iOS *system sounds*, so no audio files
///   are required for them to work.
/// - Background music is optional: drop a file named `background.mp3` into the
///   app target and it will loop while the game is on screen and stop/pause
///   when the game stops or the app is backgrounded (per the spec extras).
///   If no such file is bundled, the music calls are simply no-ops.
final class SoundManager {

    static let shared = SoundManager()

    private var musicPlayer: AVAudioPlayer?

    private init() {
        // `.ambient` lets our effects mix without stopping the user's own music
        // when no background track of ours is playing.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    /// Short click played when the cards flip.
    func playFlip() {
        AudioServicesPlaySystemSound(1104) // built-in "Tock"
    }

    /// Fanfare played when the match ends.
    func playWin() {
        AudioServicesPlaySystemSound(1025) // built-in alert/fanfare
    }

    /// Starts looping background music (if `background.mp3` is bundled).
    func startBackgroundMusic() {
        guard musicPlayer == nil,
              let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else { return }
        musicPlayer = try? AVAudioPlayer(contentsOf: url)
        musicPlayer?.numberOfLoops = -1   // loop forever
        musicPlayer?.volume = 0.4
        musicPlayer?.play()
    }

    /// Pauses the music (e.g. when the app moves to the background).
    func pauseBackgroundMusic() {
        musicPlayer?.pause()
    }

    /// Resumes the music if it had been started.
    func resumeBackgroundMusic() {
        musicPlayer?.play()
    }

    /// Fully stops and tears down the music (when leaving the game screen).
    func stopBackgroundMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }
}
