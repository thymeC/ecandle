import SwiftUI

struct CakeSceneView: View {
    let candles: [CandleItem]
    let onTapCandle: (UUID) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.92), Color(white: 0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 320, height: 22)
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
                        .frame(width: 260, height: 88)

                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 1, green: 0.71, blue: 0.78))
                        .frame(width: 268, height: 26)
                        .offset(y: -12)
                }
            }
            .padding(.bottom, 10)
        }
        .frame(height: 280)
    }

    private var spacing: CGFloat {
        let count = max(candles.count, 1)
        if count > 12 { return 2 }
        if count > 8 { return 4 }
        return 8
    }
}
