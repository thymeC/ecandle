import AVFoundation
import Combine
import Foundation
import UIKit

@MainActor
final class CandleViewModel: ObservableObject {
    @Published var mode: CandleLayoutMode = .count
    @Published var candleCount: Int = 5
    @Published var age: Int = 18
    @Published var candles: [CandleItem] = []
    @Published var showCake: Bool = true
    @Published var musicEnabled: Bool = true
    @Published var softSoundEnabled: Bool = false
    @Published var micEnabled: Bool = false
    @Published var blowLevel: Double = 0
    @Published var showCelebration: Bool = false
    @Published var statusMessage: String = "先设置蜡烛，再点击「点燃蜡烛」"
    @Published var micPermissionDenied: Bool = false
    /// Settings sheet visibility. Collapses automatically when entering blow mode.
    @Published var isSettingsExpanded: Bool = true

    private let musicPlayer = BirthdayMusicPlayer()
    private let softFeedback = SoftFeedbackPlayer()
    private let blowDetector = BlowDetector()
    private var blowCancellable: AnyCancellable?

    var litCount: Int {
        candles.filter { $0.isLit && !$0.isOut }.count
    }

    var isImmersive: Bool { !isSettingsExpanded }

    var glowStrength: Double {
        guard !candles.isEmpty else { return 0 }
        return Double(litCount) / Double(candles.count)
    }

    init() {
        rebuildCandles()
        blowCancellable = blowDetector.$level
            .receive(on: RunLoop.main)
            .sink { [weak self] level in
                self?.handleBlowLevel(level)
            }
    }

    deinit {
        // deinit is nonisolated; hop to main for UIKit.
        DispatchQueue.main.async {
            IdleTimerController.setActive(false)
        }
    }

    func rebuildCandles() {
        showCelebration = false
        stopMic()
        candles = makeCandles()
        refreshIdleTimer()
        updateStatus()
    }

    /// After celebration: re-light and go straight back into blow mode.
    func replayCelebration() {
        showCelebration = false
        stopMic()
        candles = makeCandles()
        Task { await lightAll() }
    }

    /// Leave celebration and return to settings.
    func finishCelebrationToSetup() {
        showCelebration = false
        stopMic()
        candles = makeCandles()
        expandSettings()
        updateStatus()
    }

    func lightAll() async {
        var didLight = false
        for index in candles.indices where !candles[index].isOut && !candles[index].isLit {
            candles[index].isLit = true
            didLight = true
        }
        if didLight, softSoundEnabled {
            softFeedback.playIgnite(allowAudio: !micEnabled)
        }
        syncMusic()
        refreshIdleTimer()
        updateStatus()
        // Immersive after lighting — mic on so you can blow right away.
        if didLight || litCount > 0 {
            collapseSettingsForBlow()
            await enableMicForBlow()
        }
    }

    func toggleLight(_ id: UUID) {
        guard let index = candles.firstIndex(where: { $0.id == id }) else { return }
        guard !candles[index].isOut else { return }
        if !candles[index].isLit {
            candles[index].isLit = true
            if softSoundEnabled {
                softFeedback.playIgnite(allowAudio: !micEnabled)
            }
            syncMusic()
            refreshIdleTimer()
            Task { await enableMicForBlow() }
        }
        updateStatus()
    }

    func setMusicEnabled(_ enabled: Bool) {
        musicEnabled = enabled
        syncMusic()
    }

    func setSoftSoundEnabled(_ enabled: Bool) {
        softSoundEnabled = enabled
    }

    func toggleSettings() {
        isSettingsExpanded.toggle()
    }

    func expandSettings() {
        isSettingsExpanded = true
    }

    func collapseSettingsForBlow() {
        isSettingsExpanded = false
    }

    /// Start mic listening (idempotent). Called automatically when candles are lit.
    @discardableResult
    func enableMicForBlow() async -> Bool {
        if micEnabled { return true }
        let granted = await blowDetector.requestPermission()
        if !granted {
            micPermissionDenied = true
            statusMessage = "请在「设置 → 隐私 → 麦克风」中允许电子蜡烛，才能吹灭蜡烛"
            return false
        }
        micPermissionDenied = false
        do {
            try blowDetector.start()
            micEnabled = true
            updateStatus()
            return true
        } catch {
            statusMessage = "无法启动麦克风：\(error.localizedDescription)"
            return false
        }
    }

    func stopMic() {
        blowDetector.stop()
        micEnabled = false
        blowLevel = 0
        updateStatus()
    }

    private func syncMusic() {
        if musicEnabled, candles.contains(where: { $0.isLit && !$0.isOut }) {
            musicPlayer.start()
        } else if !musicEnabled {
            musicPlayer.stop()
        }
    }

    private func refreshIdleTimer() {
        IdleTimerController.setActive(litCount > 0)
    }

    private func makeCandles() -> [CandleItem] {
        switch mode {
        case .count:
            let n = min(20, max(1, candleCount))
            return (0..<n).map { _ in CandleItem() }
        case .digits:
            let clamped = min(99, max(0, age))
            let text = String(clamped)
            return text.map { CandleItem(digitLabel: String($0)) }
        }
    }

    private func updateStatus() {
        let total = candles.count
        guard total > 0 else {
            statusMessage = "请设置蜡烛数量"
            return
        }
        let outCount = candles.filter(\.isOut).count
        if outCount == total {
            statusMessage = "全部熄灭啦！"
            return
        }
        let lit = candles.filter(\.isLit).count
        if lit == 0 {
            statusMessage = "点击「点燃蜡烛」，或点单根蜡烛点火"
            return
        }
        if lit < total {
            statusMessage = "已点燃 \(lit)/\(total) 根，继续点蜡烛或一键点燃"
            return
        }
        statusMessage = micEnabled
            ? "对着麦克风吹气，吹灭蜡烛吧！"
            : (micPermissionDenied
                ? "需要麦克风权限才能吹灭，请到系统设置中开启"
                : "蜡烛都亮啦！对着麦克风吹气即可熄灭")
    }

    private var blowAccum: TimeInterval = 0
    private var lastBlowTick: Date = .init()

    private func handleBlowLevel(_ level: Float) {
        blowLevel = Double(level)
        guard micEnabled else { return }
        guard candles.contains(where: { $0.isLit && !$0.isOut }) else { return }

        let now = Date()
        let dt = now.timeIntervalSince(lastBlowTick)
        lastBlowTick = now

        let threshold: Float = 0.22
        if level >= threshold {
            blowAccum += dt
            if blowAccum >= 0.12 {
                blowAccum = 0
                blowOutNext()
            }
        } else {
            blowAccum = max(0, blowAccum - dt * 0.5)
        }
    }

    private func blowOutNext() {
        guard let index = candles.firstIndex(where: { $0.isLit && !$0.isOut }) else { return }
        candles[index].isLit = false
        candles[index].isOut = true
        candles[index].extinguishToken += 1

        if softSoundEnabled {
            softFeedback.playExtinguish(allowAudio: !micEnabled)
        } else {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }

        if candles.allSatisfy(\.isOut) {
            musicPlayer.stop()
            stopMic()
            showCelebration = true
            softFeedback.playCelebration()
            IdleTimerController.setActive(false)
            statusMessage = "全部熄灭啦！"
            return
        } else {
            refreshIdleTimer()
        }
        updateStatus()
    }
}
