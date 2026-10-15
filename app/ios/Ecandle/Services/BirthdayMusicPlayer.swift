import AVFoundation
import Foundation

/// Loops a synthesized Happy Birthday melody (no bundled audio file).
final class BirthdayMusicPlayer {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var loopTask: Task<Void, Never>?
    private var isPlaying = false

    private struct Note {
        let frequency: Double
        let duration: Double
    }

    private static let melody: [Note] = [
        .init(frequency: 392.0, duration: 0.25),
        .init(frequency: 392.0, duration: 0.25),
        .init(frequency: 440.0, duration: 0.5),
        .init(frequency: 392.0, duration: 0.5),
        .init(frequency: 523.25, duration: 0.5),
        .init(frequency: 493.88, duration: 0.75),
        .init(frequency: 392.0, duration: 0.25),
        .init(frequency: 392.0, duration: 0.25),
        .init(frequency: 440.0, duration: 0.5),
        .init(frequency: 392.0, duration: 0.5),
        .init(frequency: 587.33, duration: 0.5),
        .init(frequency: 523.25, duration: 0.75),
        .init(frequency: 392.0, duration: 0.25),
        .init(frequency: 392.0, duration: 0.25),
        .init(frequency: 783.99, duration: 0.5),
        .init(frequency: 659.25, duration: 0.5),
        .init(frequency: 523.25, duration: 0.5),
        .init(frequency: 493.88, duration: 0.5),
        .init(frequency: 440.0, duration: 0.5),
        .init(frequency: 440.0, duration: 0.25),
        .init(frequency: 440.0, duration: 0.25),
        .init(frequency: 493.88, duration: 0.5),
        .init(frequency: 493.88, duration: 0.5),
        .init(frequency: 440.0, duration: 0.25),
        .init(frequency: 493.88, duration: 0.25),
        .init(frequency: 523.25, duration: 0.25),
        .init(frequency: 587.33, duration: 0.75),
    ]

    func start() {
        guard !isPlaying else { return }
        isPlaying = true
        loopTask = Task { [weak self] in
            await self?.runLoop()
        }
    }

    func stop() {
        isPlaying = false
        loopTask?.cancel()
        loopTask = nil
        player.stop()
        if engine.isRunning {
            engine.stop()
        }
    }

    private func runLoop() async {
        while !Task.isCancelled, isPlaying {
            do {
                try await playOnce()
            } catch {
                break
            }
            try? await Task.sleep(nanoseconds: 80_000_000)
        }
    }

    private func playOnce() async throws {
        let sampleRate = 44_100.0
        var samples: [Float] = []
        let volume: Float = 0.18

        for note in Self.melody {
            let frameCount = Int(note.duration * sampleRate)
            for i in 0..<frameCount {
                let t = Double(i) / sampleRate
                let wave = sin(2 * Double.pi * note.frequency * t)
                let env = min(1, min(t * 20, (note.duration - t) * 20))
                samples.append(Float(wave * env) * volume)
            }
        }

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)) else { return }
        buffer.frameLength = AVAudioFrameCount(samples.count)
        let dst = buffer.floatChannelData![0]
        for i in samples.indices {
            dst[i] = samples[i]
        }

        if !engine.isRunning {
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        }

        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            player.scheduleBuffer(buffer) {
                cont.resume()
            }
            if !player.isPlaying {
                player.play()
            }
        }

        let phraseDuration = Self.melody.reduce(0) { $0 + $1.duration }
        try await Task.sleep(nanoseconds: UInt64(phraseDuration * 1_000_000_000))
    }
}
