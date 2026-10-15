import SwiftUI

struct CandleView: View {
    let candle: CandleItem
    @State private var flicker = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                if candle.isLit && !candle.isOut {
                    FlameView()
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: 28)

            Rectangle()
                .fill(Color.black.opacity(0.85))
                .frame(width: 2, height: 6)

            if candle.isDigit, let label = candle.digitLabel {
                Text(label)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(minWidth: 28, minHeight: 48)
                    .background(
                        LinearGradient(
                            colors: [Color.pink, Color(red: 0.76, green: 0.09, blue: 0.36)],
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
        .animation(.easeInOut(duration: 0.35), value: candle.isLit)
        .animation(.easeInOut(duration: 0.35), value: candle.isOut)
    }
}

struct FlameView: View {
    @State private var phase = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [.white, .yellow, .orange, .clear],
                        center: .center,
                        startRadius: 1,
                        endRadius: 18
                    )
                )
                .frame(width: phase ? 15 : 13, height: phase ? 24 : 21)
                .blur(radius: 0.3)
                .offset(y: phase ? -1 : 0)

            Capsule()
                .fill(Color(red: 1, green: 0.98, blue: 0.8))
                .frame(width: 5, height: 9)
                .offset(y: -6)
        }
        .shadow(color: .orange.opacity(0.8), radius: 6)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.32).repeatForever(autoreverses: true)) {
                phase = true
            }
        }
    }
}
