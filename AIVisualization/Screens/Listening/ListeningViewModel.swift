//
//  ListeningViewModel.swift
//  AIVisualization
//
//  Created by Curt McCune on 9/2/24.
//

import Foundation
import AVFoundation

class ListeningViewModel: ObservableObject {
    
    init(audioData: Data?) {
        self.audioData = audioData
        
        DispatchQueue.main.async {
            Task {
                await self.mixAudio()
            }
        }
    }
    
    @Published var isPlaying: Bool = false
    @Published var progress: CGFloat = 0
    @Published var currentTime: Double = 0
    @Published var totalDuration: Double = 0
    
    private var progressUpdateTimer: Timer?
    
    var audioData: Data?
    var player: AVAudioPlayer?
    var mixedAudioURL: URL?
    
    func mixAudio() async {
        guard let audioData = audioData else {
            print("Missing audio data")
            return
        }
        
        do {
            let composition = AVMutableComposition()
            
            // Create audio track for main audio
            guard let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                print("Failed to create composition audio track")
                return
            }
            
            // Write main audio data to a temporary file
            print("hit 0")
            let mainAudioURL = try audioData.writeToTemporaryFile()
            print("Main audio file URL: \(mainAudioURL)")
            
            let mainAudioAsset = AVAsset(url: mainAudioURL)
            print("hit 0.3")
            let mainAudioTrack = try await mainAudioAsset.loadTracks(withMediaType: .audio).first
            print("hit 0.6")
            let mainAudioDuration = try await mainAudioAsset.load(.duration)
            
            // Insert main audio into composition
            try compositionAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: mainAudioDuration),
                                                      of: mainAudioTrack!,
                                                      at: .zero)
            
            // Load background music
            guard let backgroundMusicURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
                print("Background music file not found")
                return
            }
            
            let backgroundMusicAsset = AVAsset(url: backgroundMusicURL)
            print("hit 1")
            let backgroundMusicTrack = try await backgroundMusicAsset.loadTracks(withMediaType: .audio).first
            
            // Create audio track for background music
            guard let backgroundCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                print("Failed to create background music track")
                return
            }
            
            // Insert background music into composition
            print("hit 2")
            try backgroundCompositionTrack.insertTimeRange(CMTimeRange(start: .zero, duration: mainAudioDuration),
                                                           of: backgroundMusicTrack!,
                                                           at: .zero)
            
            // Lower the volume of the background music
            let backgroundMusicMixParameters = AVMutableAudioMixInputParameters(track: backgroundCompositionTrack)
            backgroundMusicMixParameters.setVolumeRamp(fromStartVolume: 0.2, toEndVolume: 0.2, timeRange: CMTimeRange(start: .zero, duration: mainAudioDuration))
            
            let audioMix = AVMutableAudioMix()
            audioMix.inputParameters = [backgroundMusicMixParameters]
            
            // Export mixed audio
            let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("mixed_audio.m4a")
            
            exportSession?.outputURL = outputURL
            exportSession?.outputFileType = .m4a
            exportSession?.audioMix = audioMix
            
            await exportSession?.export()
            
            if let error = exportSession?.error {
                print("Export failed: \(error)")
            } else {
                print("Mixed audio exported successfully to: \(outputURL)")
                print("hit 3")
                player = try AVAudioPlayer(contentsOf: outputURL)
                totalDuration = player?.duration ?? 0
            }
        } catch {
            print("Error mixing audio: \(error)")
        }
    }
    
    func pausePlayTapped() {
        guard let player else { return }
        
        if isPlaying {
            player.pause()
            progressUpdateTimer?.invalidate()
        } else {
            player.play()
            startProgressUpdates()
        }
        isPlaying.toggle()
    }
    
    private func startPlayback() {
        guard let player = player else { return }
        player.play()
        isPlaying = true
        totalDuration = player.duration
        startProgressUpdates()
    }
    
    private func startProgressUpdates() {
        progressUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.currentTime = player.currentTime
            self.progress = CGFloat(player.currentTime / player.duration)
        }
    }
    
    deinit {
        progressUpdateTimer?.invalidate()
    }
}

// Helper extension to write Data to a temporary file
extension Data {
    func writeToTemporaryFile() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp3")
        try self.write(to: tempFileURL)
        return tempFileURL
    }
}
