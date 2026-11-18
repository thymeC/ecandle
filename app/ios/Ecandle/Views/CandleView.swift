import SwiftUI

struct CandleView: View {
    let candle: CandleItem
    /// Optional uniform scale when many candles must fit on the cake / tray.
    var scale: CGFloat = 1

    private var bodyWidth: CGFloat {
        candle.isDigit ? 28 : 10
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                if candle.isOut {
                    SmokeView(token: candle.extinguishToken)
                }

                if candle.isLit && !candle.isOut {
                    FlameView()
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.2).combined(with: .opacity),
                                removal: .opacity.combined(with: .scale(scale: 0.4))
                            )
                        )
                }
            }
            // Fixed layout width so lit flame halos cannot inflate HStack / ScrollView.
            .frame(width: bodyWidth, height: 36)

            // Wick darkens slightly when extinguished; wax color stays vivid.
            Rectangle()
                .fill(candle.isOut ? Color.black.opacity(0.7) : Color.black.opacity(0.85))
                .frame(width: 2, height: 6)

            if candle.isDigit, let label = candle.digitLabel {
                Text(label)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 48)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.pink,
                                Color(red: 0.76, green: 0.09, blue: 0.36),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        in: RoundedRectangle(cornerRadius: 4)
                    )
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [.white, .pink, .white, .pink],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 10, height: 42)
            }
        }
        .frame(width: bodyWidth)
        .scaleEffect(scale, anchor: .bottom)
        .frame(width: bodyWidth * scale, alignment: .bottom)
        .animation(.easeInOut(duration: 0.4), value: candle.isLit)
        .animation(.easeInOut(duration: 0.45), value: candle.isOut)
    }
}
