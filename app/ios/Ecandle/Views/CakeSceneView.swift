import SwiftUI

struct CakeSceneView: View {
    let candles: [CandleItem]
    var immersive: Bool = false
    let onTapCandle: (UUID) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // Soft pool of light under the cake when lit.
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
                .frame(width: immersive ? 360 : 300, height: immersive ? 120 : 90)
                .offset(y: immersive ? 20 : 10)
                .blur(radius: 18)

            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.92), Color(white: 0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: plateWidth, height: 22)
                .shadow(color: .black.opacity(0.45), radius: 12, y: 6)

            VStack(spacing: 0) {
                HStack(spacing: spacing) {
                    ForEach(candles) { candle in
                        CandleView(candle: candle)
                            .onTapGesture { onTapCandle(candle.id) }
                    }
                }
                .frame(maxWidth: .infinity)
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
                        .frame(width: cakeWidth, height: immersive ? 100 : 88)

                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 1, green: 0.71, blue: 0.78))
                        .frame(width: cakeWidth + 8, height: 26)
                        .offset(y: -12)
                }
            }
            .padding(.bottom, 10)
            .scaleEffect(immersive ? 1.12 : 1)
        }
        .frame(height: immersive ? 340 : 280)
    }

    private var plateWidth: CGFloat { immersive ? 340 : 320 }
    private var cakeWidth: CGFloat { immersive ? 280 : 260 }

    private var spacing: CGFloat {
        let count = max(candles.count, 1)
        if count > 12 { return 2 }
        if count > 8 { return 4 }
        return 8
    }
}
