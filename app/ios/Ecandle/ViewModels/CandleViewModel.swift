import AVFoundation
import Combine
import Foundation
import UIKit

enum CandleLayoutMode: String, CaseIterable, Identifiable {
    case count = "多根蜡烛"
    case digits = "数字蜡烛"

    var id: String { rawValue }
}

struct CandleItem: Identifiable, Equatable {
    let id: UUID
    let digitLabel: String?
    var isLit: Bool
    var isOut: Bool

    init(id: UUID = UUID(), digitLabel: String? = nil, isLit: Bool = false, isOut: Bool = false) {
        self.id = id
        self.digitLabel = digitLabel
        self.isLit = isLit
        self.isOut = isOut
    }

    var isDigit: Bool { digitLabel != nil }
}

@MainActor
final class CandleViewModel: ObservableObject {
    @Published var mode: CandleLayoutMode = .count
    @Published var candleCount: Int = 5
    @Published var age: Int = 18
    @Published var candles: [CandleItem] = []
    @Published var musicEnabled: Bool = true
    @Published var micEnabled: Bool = false
    @Published var blowLevel: Double = 0
    @Published var showCelebration: Bool = false
    @Published var statusMessage: String = "先设置蜡烛，再点击「点燃蜡烛」"
    @Published var micPermissionDenied: Bool = false

    private let musicPlayer = BirthdayMusicPlayer()
    private let blowDetector = BlowDetector()
    private var blowCancellable: AnyCancellable?

    init() {
        rebuildCandles()
        blowCancellable = blowDetector.$level
            .receive(on: RunLoop.main)
            .sink { [weak self] level in
                self?.handleBlowLevel(level)
            }
    }

    func rebuildCandles() {
        showCelebration = false
        candles = makeCandles()
        updateStatus()
    }

    func lightAll() {
        for index in candles.indices where !candles[index].isOut {
            candles[index].isLit = true
        }
        syncMusic()
        updateStatus()
    }

    func toggleLight(_ id: UUID) {
        guard let index = candles.firstIndex(where: { $0.id == id }) else { return }
        guard !candles[index].isOut else { return }
        if !candles[index].isLit {
            candles[index].isLit = true
            syncMusic()
        }
        updateStatus()
    }

    func setMusicEnabled(_ enabled: Bool) {
        musicEnabled = enabled
        syncMusic()
    }

    func toggleMic() async {
        if micEnabled {
            stopMic()
            return
        }
        let granted = await blowDetector.requestPermission()
        if !granted {
            micPermissionDenied = true
            statusMessage = "请在「设置 → 隐私 → 麦克风」中允许 eCandle"
            return
        }
        micPermissionDenied = false
        do {
            try blowDetector.start()
            micEnabled = true
            updateStatus()
        } catch {
            statusMessage = "无法启动麦克风：\(error.localizedDescription)"
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
            : "蜡烛都亮啦！开启「吹气」用麦克风吹灭"
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

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if candles.allSatisfy(\.isOut) {
            musicPlayer.stop()
            showCelebration = true
            let success = UINotificationFeedbackGenerator()
            success.notificationOccurred(.success)
        }
        updateStatus()
    }
}
