import SwiftUI

struct CandleView: View {
    let candle: CandleItem

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
            .frame(height: 36)

            Rectangle()
                .fill(Color.black.opacity(0.85))
                .frame(width: 2, height: 6)
                .opacity(candle.isOut ? 0.55 : 1)

            if candle.isDigit, let label = candle.digitLabel {
                Text(label)
                    .font(.title2.bold())
                    .foregroundStyle(.white.opacity(candle.isOut ? 0.55 : 1))
                    .frame(minWidth: 28, minHeight: 48)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.pink.opacity(candle.isOut ? 0.55 : 1),
                                Color(red: 0.76, green: 0.09, blue: 0.36).opacity(candle.isOut ? 0.55 : 1),
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
                            colors: [
                                .white.opacity(candle.isOut ? 0.55 : 1),
                                .pink.opacity(candle.isOut ? 0.55 : 1),
                                .white.opacity(candle.isOut ? 0.55 : 1),
                                .pink.opacity(candle.isOut ? 0.55 : 1),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 10, height: 42)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: candle.isLit)
        .animation(.easeInOut(duration: 0.45), value: candle.isOut)
    }
}
