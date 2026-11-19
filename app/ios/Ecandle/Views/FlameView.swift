import SwiftUI

/// Multi-layer flame with gentle sway and irregular flicker.
/// Layout width stays narrow so a row of lit candles cannot inflate ScrollView.
struct FlameView: View {
    @State private var sway: CGFloat = 0
    @State private var flickerScale: CGFloat = 1
    @State private var flickerTask: Task<Void, Never>?

    /// Ideal layout footprint (body width); glow draws outside without expanding parents.
    private let layoutWidth: CGFloat = 14
    private let layoutHeight: CGFloat = 28

    var body: some View {
        ZStack(alignment: .bottom) {
            // Soft halo — drawn larger than layout bounds on purpose.
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(0.55),
                            Color.orange.opacity(0.12),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 22
                    )
                )
                .frame(width: 34, height: 40)
                .blur(radius: 4)
                .offset(x: sway * 0.4, y: -4)
                .allowsHitTesting(false)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1, green: 0.98, blue: 0.85),
                            Color.yellow,
                            Color.orange,
                            Color(red: 0.95, green: 0.35, blue: 0.05).opacity(0.0),
                        ],
                        center: UnitPoint(x: 0.5, y: 0.65),
                        startRadius: 1,
                        endRadius: 16
                    )
                )
                .frame(width: 14 * flickerScale, height: 23 * flickerScale)
                .offset(x: sway, y: sway == 0 ? 0 : -1)

            Capsule()
                .fill(Color(red: 1, green: 0.99, blue: 0.92))
                .frame(width: 4.5, height: 8)
                .offset(x: sway * 0.5, y: -6)
                .blur(radius: 0.2)
        }
        .frame(width: layoutWidth, height: layoutHeight, alignment: .bottom)
        .shadow(color: .orange.opacity(0.75), radius: 8, y: 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                sway = 1.6
            }
            startFlickerLoop()
        }
        .onDisappear {
            flickerTask?.cancel()
            flickerTask = nil
        }
    }

    private func startFlickerLoop() {
        flickerTask?.cancel()
        flickerTask = Task { @MainActor in
            while !Task.isCancelled {
                let next = CGFloat.random(in: 0.88...1.12)
                withAnimation(.easeInOut(duration: Double.random(in: 0.08...0.22))) {
                    flickerScale = next
                }
                try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 0.09...0.28) * 1_000_000_000))
            }
        }
    }
}
