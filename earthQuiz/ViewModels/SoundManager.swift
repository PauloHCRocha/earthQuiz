//
//  SoundManager.swift
//  earthQuiz
//
//  Created by Claude on 2025-12-08.
//

import Foundation
import AVFoundation

final class SoundManager {

    static let shared = SoundManager()

    // Separate players for background music and sound effects
    private var musicPlayer: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?

    // Volume levels
    private let musicVolume: Float = 0.3
    private let sfxVolume: Float = 1.0

    private init() {
        // Configure audio session for playback with mixing
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    // MARK: - Background Music

    /// Start playing the theme song on loop
    func playThemeSong() {
        guard let url = Bundle.main.url(forResource: "theme song loop", withExtension: "mp3") else {
            print("Theme song file not found: theme song loop.mp3")
            return
        }

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1 // Loop indefinitely
            musicPlayer?.volume = musicVolume
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print("Failed to play theme song: \(error)")
        }
    }

    /// Stop the theme song
    func stopThemeSong() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    /// Pause the theme song
    func pauseThemeSong() {
        musicPlayer?.pause()
    }

    /// Resume the theme song
    func resumeThemeSong() {
        musicPlayer?.play()
    }

    /// Check if theme song is playing
    var isThemeSongPlaying: Bool {
        return musicPlayer?.isPlaying ?? false
    }

    // MARK: - Sound Effects

    /// Play sound for speed bonus
    func playSpeedBonus() {
        playSFX(named: "speed bonus", extension: "mp3")
    }

    /// Play sound for streak/combo bonus
    func playCombo() {
        playSFX(named: "combo", extension: "mp3")
    }

    /// Play sound for outstanding performance (speed + streak)
    func playOutstanding() {
        playSFX(named: "outstanding", extension: "mp3")
    }

    // MARK: - Private

    private func playSFX(named name: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Sound file not found: \(name).\(ext)")
            return
        }

        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.volume = sfxVolume
            sfxPlayer?.prepareToPlay()
            sfxPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
}
