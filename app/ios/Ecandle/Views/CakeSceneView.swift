import SwiftUI

struct CakeSceneView: View {
    let candles: [CandleItem]
    var immersive: Bool = false
    let onTapCandle: (UUID) -> Void

    var body: some View {
        GeometryReader { geo in
            let bounds = min(geo.size.width, immersive ? 360 : 340)
            let plate = min(plateWidthIdeal, bounds)
            let cake = min(cakeWidthIdeal, plate * 0.82)
            let candleBand = cake * 0.96
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
                    .frame(width: min(bounds, immersive ? 360 : 300), height: immersive ? 120 : 90)
                    .offset(y: immersive ? 20 : 10)
                    .blur(radius: 18)
                    .allowsHitTesting(false)

                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.92), Color(white: 0.65)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: plate, height: 22)
                    .shadow(color: .black.opacity(0.45), radius: 12, y: 6)

                VStack(spacing: 0) {
                    HStack(spacing: layout.spacing) {
                        ForEach(candles) { candle in
                            CandleView(candle: candle, scale: layout.scale)
                                .onTapGesture { onTapCandle(candle.id) }
                        }
                    }
                    .frame(width: candleBand, alignment: .center)
                    .padding(.bottom, 4)

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
                            .frame(width: cake, height: immersive ? 100 : 88)

                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 1, green: 0.71, blue: 0.78))
                            .frame(width: cake + 8, height: 26)
                            .offset(y: -12)
                    }
                }
                .padding(.bottom, 10)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        }
        .frame(maxWidth: .infinity)
        .frame(height: immersive ? 340 : 280)
    }

    private var plateWidthIdeal: CGFloat { immersive ? 340 : 320 }
    private var cakeWidthIdeal: CGFloat { immersive ? 280 : 260 }

    private func candleFit(in width: CGFloat) -> (spacing: CGFloat, scale: CGFloat) {
        let count = max(candles.count, 1)
        let unit: CGFloat = candles.contains(where: \.isDigit) ? 28 : 10
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
