import SwiftUI

struct CandleView: View {
    let candle: CandleItem
    /// Optional uniform scale when many candles must fit on the cake / tray.
    var scale: CGFloat = 1

    private var bodyWidth: CGFloat {
        candle.isDigit ? 68 : 12
    }

    var body: some View {
        VStack(spacing: 0) {
            flameSlot
            WickView(isLit: candle.isLit && !candle.isOut, isOut: candle.isOut)
                .frame(width: bodyWidth)

            if candle.isDigit, let label = candle.digitLabel {
                DigitCandleShape(digit: label, isOut: candle.isOut)
            } else {
                stickBody
            }
        }
        .frame(width: bodyWidth)
        .scaleEffect(scale, anchor: .bottom)
        .frame(width: bodyWidth * scale, alignment: .bottom)
        .animation(.easeInOut(duration: 0.4), value: candle.isLit)
        .animation(.easeInOut(duration: 0.45), value: candle.isOut)
    }

    @ViewBuilder
    private var flameSlot: some View {
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
        .frame(width: bodyWidth, height: 36)
    }

    private var stickBody: some View {
        // Wax stays colorful when out — only flame / wick change.
        RoundedRectangle(cornerRadius: 2.5)
            .fill(
                LinearGradient(
                    colors: [.white, .pink, .white, .pink],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 11, height: 44)
            .overlay(alignment: .top) {
                Capsule()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 13, height: 4)
                    .offset(y: -1)
            }
            .opacity(candle.isOut ? 0.92 : 1)
    }
}

/// Visible wick — charcoal tip when unlit / out; tucked under the flame when lit.
private struct WickView: View {
    var isLit: Bool
    var isOut: Bool

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: isOut
                            ? [Color(white: 0.25), Color(white: 0.12)]
                            : [Color(red: 0.22, green: 0.14, blue: 0.1), .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: isLit ? 1.6 : 2.4, height: isLit ? 5 : 10)
                .opacity(isOut ? 0.75 : 1)

            if !isLit {
                Capsule()
                    .fill(Color.black.opacity(0.85))
                    .frame(width: 3.2, height: 2)
                    .offset(y: -1)
            }
        }
        .frame(height: isLit ? 5 : 12)
        .padding(.bottom, 1)
    }
}
