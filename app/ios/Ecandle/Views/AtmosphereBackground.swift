import SwiftUI

/// Dark room gradient with a soft candlelight bloom that tracks lit strength.
struct AtmosphereBackground: View {
    var glowStrength: Double

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.04, blue: 0.08),
                    Color(red: 0.03, green: 0.02, blue: 0.04),
                    Color(red: 0.02, green: 0.015, blue: 0.03),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Warm ambient wash — stronger when candles are lit.
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.55, blue: 0.18).opacity(0.22 * glowStrength),
                    Color(red: 0.85, green: 0.35, blue: 0.08).opacity(0.10 * glowStrength),
                    .clear,
                ],
                center: UnitPoint(x: 0.5, y: 0.42),
                startRadius: 20,
                endRadius: 340
            )
            .animation(.easeInOut(duration: 0.8), value: glowStrength)

            // Subtle vignette so the cake sits in a quiet pool of light.
            RadialGradient(
                colors: [.clear, Color.black.opacity(0.55)],
                center: .center,
                startRadius: 120,
                endRadius: 520
            )
        }
        .ignoresSafeArea()
    }
}
