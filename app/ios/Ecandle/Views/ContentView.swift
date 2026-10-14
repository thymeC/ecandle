import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CandleViewModel()

    var body: some View {
        ZStack {
            backgroundGradient

            ScrollView {
                VStack(spacing: 20) {
                    header
                    ControlsPanel(viewModel: viewModel)
                    CakeSceneView(
                        candles: viewModel.candles,
                        onTapCandle: { viewModel.toggleLight($0) }
                    )
                    Text(viewModel.statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
            }

            if viewModel.showCelebration {
                CelebrationOverlay()
                    .transition(.opacity.combined(with: .scale))
            }

            ConfettiView(isActive: viewModel.showCelebration)
                .allowsHitTesting(false)
        }
        .animation(.spring(duration: 0.5), value: viewModel.showCelebration)
        .onChange(of: viewModel.mode) { _, _ in viewModel.rebuildCandles() }
        .onChange(of: viewModel.candleCount) { _, _ in
            if viewModel.mode == .count { viewModel.rebuildCandles() }
        }
        .onChange(of: viewModel.age) { _, _ in
            if viewModel.mode == .digits { viewModel.rebuildCandles() }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.16, green: 0.08, blue: 0.22), Color(red: 0.07, green: 0.04, blue: 0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("电子生日蜡烛")
                .font(.title.bold())
            Text("没有打火机？点这里。对着 iPhone 吹气，蜡烛会灭。")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ContentView()
}
