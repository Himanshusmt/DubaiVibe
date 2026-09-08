//
//  SOSSoundPlayer.swift
//  MyGuardianLink
//

import AVFoundation

enum SOSSoundPlayer {
    private static var player: AVAudioPlayer?

    static func play() {
        guard let url = Bundle.main.url(forResource: "sos", withExtension: "mp3") else {
            print("SOS sound file not found in bundle")
            return
        }

        let playBlock = {
            playOnMainThread(url: url)
        }

        if Thread.isMainThread {
            playBlock()
        } else {
            DispatchQueue.main.async(execute: playBlock)
        }
    }

    private static func playOnMainThread(url: URL) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetoothA2DP]
            )
            try session.setActive(true, options: [])

            player?.stop()
            player = nil

            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.volume = 1.0
            audioPlayer.numberOfLoops = 0
            audioPlayer.prepareToPlay()
            player = audioPlayer

            if !audioPlayer.play() {
                print("SOS sound failed to start playback")
            }
        } catch {
            print("SOS sound error:", error.localizedDescription)
        }
    }

    static func stop() {
        let stopBlock = {
            player?.stop()
            player = nil
            try? AVAudioSession.sharedInstance().setActive(
                false,
                options: [.notifyOthersOnDeactivation]
            )
        }

        if Thread.isMainThread {
            stopBlock()
        } else {
            DispatchQueue.main.async(execute: stopBlock)
        }
    }
}
