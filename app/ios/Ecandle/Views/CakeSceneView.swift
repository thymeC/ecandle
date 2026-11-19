import SwiftUI

struct CakeSceneView: View {
    let candles: [CandleItem]
    var immersive: Bool = false
    var showCake: Bool = true
    /// Smaller scene for the settings-screen preview half.
    var compact: Bool = false
    let onTapCandle: (UUID) -> Void

    var body: some View {
        GeometryReader { geo in
            let maxBound = compact ? min(geo.size.width, 300) : min(geo.size.width, immersive ? 360 : 340)
            let plate = min(plateWidthIdeal, maxBound)
            let cake = min(cakeWidthIdeal, plate * 0.82)
            let candleBand = showCake ? cake * 0.96 : min(maxBound * 0.92, plate)
            let layout = candleFit(in: candleBand)

            ZStack(alignment: .bottom) {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1, green: 0.7, blue: 0.3).opacity(immersive ? 0.18 : 0.1),
                                .clear,
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: immersive ? 200 : 150
                        )
                    )
                    .frame(width: min(maxBound, immersive ? 360 : 300), height: immersive ? 120 : (compact ? 70 : 90))
                    .offset(y: showCake ? (immersive ? 20 : 10) : (immersive ? -10 : -20))
                    .blur(radius: 18)
                    .allowsHitTesting(false)

                if showCake {
                    Ellipse()
                        .fill(
                            LinearGradient(
                                colors: [Color(white: 0.92), Color(white: 0.65)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: plate, height: compact ? 16 : 22)
                        .shadow(color: .black.opacity(0.45), radius: 12, y: 6)
                } else {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.02),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: candleBand + 24, height: 10)
                        .blur(radius: 2)
                        .padding(.bottom, 6)
                }

                VStack(spacing: 0) {
                    HStack(spacing: layout.spacing) {
                        ForEach(candles) { candle in
                            CandleView(candle: candle, scale: layout.scale)
                                .onTapGesture { onTapCandle(candle.id) }
                        }
                    }
                    .frame(width: candleBand, alignment: .center)
                    .padding(.bottom, showCake ? 4 : 12)

                    if showCake {
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.42, green: 0.26, blue: 0.14),
                                            Color(red: 0.24, green: 0.15, blue: 0.09),
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: cake, height: cakeBodyHeight)

                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 1, green: 0.71, blue: 0.78))
                                .frame(width: cake + 8, height: compact ? 20 : 26)
                                .offset(y: compact ? -10 : -12)
                        }
                    }
                }
                .padding(.bottom, showCake ? 10 : 18)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
            .animation(.easeInOut(duration: 0.28), value: showCake)
        }
        .frame(maxWidth: .infinity)
        .frame(height: sceneHeight)
    }

    private var cakeBodyHeight: CGFloat {
        if immersive { return 100 }
        return compact ? 72 : 88
    }

    private var sceneHeight: CGFloat {
        if showCake {
            if immersive { return 340 }
            return compact ? 220 : 280
        }
        if immersive { return 220 }
        return compact ? 150 : 180
    }

    private var plateWidthIdeal: CGFloat {
        if immersive { return 340 }
        return compact ? 280 : 320
    }

    private var cakeWidthIdeal: CGFloat {
        if immersive { return 280 }
        return compact ? 230 : 260
    }

    private func candleFit(in width: CGFloat) -> (spacing: CGFloat, scale: CGFloat) {
        let count = max(candles.count, 1)
        let unit: CGFloat = candles.contains(where: \.isDigit) ? 68 : 12
        let preferredSpacing: CGFloat = {
            if count > 12 { return 2 }
            if count > 8 { return 4 }
            return 8
        }()

        let ideal = CGFloat(count) * unit + CGFloat(count - 1) * preferredSpacing
        if ideal <= width {
            return (preferredSpacing, 1)
        }

        let minSpacing: CGFloat = 1
        let tight = CGFloat(count) * unit + CGFloat(max(count - 1, 0)) * minSpacing
        if tight <= width {
            let spacing = count > 1
                ? (width - CGFloat(count) * unit) / CGFloat(count - 1)
                : preferredSpacing
            return (max(minSpacing, spacing), 1)
        }

        let scale = max(0.45, width / tight)
        return (minSpacing * scale, scale)
    }
}
