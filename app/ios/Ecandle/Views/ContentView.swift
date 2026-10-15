import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CandleViewModel()

    var body: some View {
        ZStack {
            AtmosphereBackground(glowStrength: viewModel.glowStrength)

            if viewModel.isImmersive {
                immersiveLayout
            } else {
                setupLayout
            }

            if viewModel.showCelebration {
                CelebrationOverlay()
                    .transition(.opacity.combined(with: .scale))
            }

            ConfettiView(isActive: viewModel.showCelebration)
                .allowsHitTesting(false)
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.isSettingsExpanded)
        .animation(.spring(duration: 0.5), value: viewModel.showCelebration)
        .statusBarHidden(viewModel.isImmersive)
        .onChange(of: viewModel.mode) { _, _ in viewModel.rebuildCandles() }
        .onChange(of: viewModel.candleCount) { _, _ in
            if viewModel.mode == .count { viewModel.rebuildCandles() }
        }
        .onChange(of: viewModel.age) { _, _ in
            if viewModel.mode == .digits { viewModel.rebuildCandles() }
        }
    }

    private var setupLayout: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                ControlsPanel(viewModel: viewModel) {
                    withAnimation(.easeInOut(duration: 0.28)) {
                        viewModel.collapseSettingsForBlow()
                    }
                }
                CakeSceneView(
                    candles: viewModel.candles,
                    immersive: false,
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
    }

    private var immersiveLayout: some View {
        ZStack {
            // Tap empty space to reveal settings — candles keep their own taps.
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.28)) {
                        viewModel.expandSettings()
                    }
                }

            VStack {
                Spacer()
                CakeSceneView(
                    candles: viewModel.candles,
                    immersive: true,
                    onTapCandle: { viewModel.toggleLight($0) }
                )
                Spacer()
            }
            .allowsHitTesting(true)

            ImmersiveChrome(viewModel: viewModel)
        }
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
