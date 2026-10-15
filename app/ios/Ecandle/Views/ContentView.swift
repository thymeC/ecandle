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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        ScrollView(.vertical, showsIndicators: false) {
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
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var immersiveLayout: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.28)) {
                        viewModel.expandSettings()
                    }
                }

            VStack {
                Spacer(minLength: 0)
                CakeSceneView(
                    candles: viewModel.candles,
                    immersive: true,
                    onTapCandle: { viewModel.toggleLight($0) }
                )
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .allowsHitTesting(true)

            ImmersiveChrome(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("电子生日蜡烛")
                .font(.title.bold())
            Text("没有打火机？点这里。对着 iPhone 吹气，蜡烛会灭。")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}
