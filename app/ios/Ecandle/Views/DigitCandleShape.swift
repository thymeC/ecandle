import SwiftUI

/// Birthday number candle — wax body is the digit silhouette, not a bar with a label.
struct DigitCandleShape: View {
    let digit: String
    var isOut: Bool

    private let fontSize: CGFloat = 88
    private let frameWidth: CGFloat = 68
    private let frameHeight: CGFloat = 92

    private var digitFont: Font {
        .system(size: fontSize, weight: .heavy, design: .rounded)
    }

    /// Keep pink wax when extinguished — only the flame goes out.
    private var wax: some ShapeStyle {
        LinearGradient(
            colors: [
                Color(red: 1, green: 0.86, blue: 0.9),
                Color(red: 1, green: 0.42, blue: 0.62),
                Color(red: 0.78, green: 0.12, blue: 0.4),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        Text(digit)
            .font(digitFont)
            .foregroundStyle(wax)
            .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
            .overlay {
                Text(digit)
                    .font(digitFont)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.45),
                                .clear,
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .mask {
                        Text(digit)
                            .font(digitFont)
                    }
            }
            .opacity(isOut ? 0.92 : 1)
            .frame(width: frameWidth, height: frameHeight)
            .accessibilityLabel("数字蜡烛 \(digit)")
    }
}
