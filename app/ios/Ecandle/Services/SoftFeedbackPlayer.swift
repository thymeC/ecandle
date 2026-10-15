import AVFoundation
import Foundation
import UIKit

/// Optional soft one-shot cues (ignite / extinguish). Kept quiet and short.
final class SoftFeedbackPlayer {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var isAttached = false

    /// When `allowAudio` is false (e.g. mic session active), only haptics fire.
    func playIgnite(allowAudio: Bool = true) {
        if allowAudio {
            playTone(frequency: 420, duration: 0.09, volume: 0.06, noise: 0.35)
        }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred(intensity: 0.55)
    }

    func playExtinguish(allowAudio: Bool = true) {
        if allowAudio {
            playNoiseBurst(duration: 0.18, volume: 0.045)
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred(intensity: 0.7)
    }

    func playCelebration() {
        let success = UINotificationFeedbackGenerator()
        success.notificationOccurred(.success)
    }

    private func ensureEngine(format: AVAudioFormat) throws {
        if !isAttached {
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)
            isAttached = true
        }
        if !engine.isRunning {
            try engine.start()
        }
    }

    private func playTone(frequency: Double, duration: Double, volume: Float, noise: Float) {
        let sampleRate = 22_050.0
        let frameCount = Int(duration * sampleRate)
        var samples = [Float](repeating: 0, count: frameCount)
        for i in 0..<frameCount {
            let t = Double(i) / sampleRate
            let env = Float(min(1, min(t * 40, (duration - t) * 12)))
            let wave = Float(sin(2 * Double.pi * frequency * t))
            let hiss = Float.random(in: -1...1) * noise
            samples[i] = (wave * 0.7 + hiss) * env * volume
        }
        schedule(samples: samples, sampleRate: sampleRate)
    }

    private func playNoiseBurst(duration: Double, volume: Float) {
        let sampleRate = 22_050.0
        let frameCount = Int(duration * sampleRate)
        var samples = [Float](repeating: 0, count: frameCount)
        for i in 0..<frameCount {
            let t = Double(i) / sampleRate
            let env = Float(exp(-t * 14))
            samples[i] = Float.random(in: -1...1) * env * volume
        }
        schedule(samples: samples, sampleRate: sampleRate)
    }

    private func schedule(samples: [Float], sampleRate: Double) {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)) else { return }
        buffer.frameLength = AVAudioFrameCount(samples.count)
        let dst = buffer.floatChannelData![0]
        for i in samples.indices {
            dst[i] = samples[i]
        }
        do {
            try ensureEngine(format: format)
            player.scheduleBuffer(buffer, completionHandler: nil)
            if !player.isPlaying {
                player.play()
            }
        } catch {
            // Soft feedback is best-effort; never block candle UX.
        }
    }
}
