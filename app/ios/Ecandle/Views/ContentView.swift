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
                CelebrationOverlay(
                    onReplay: {
                        withAnimation(.spring(duration: 0.45)) {
                            viewModel.replayCelebration()
                        }
                    },
                    onSetup: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            viewModel.finishCelebrationToSetup()
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale))
                .zIndex(10)
            }

            ConfettiView(isActive: viewModel.showCelebration)
                .allowsHitTesting(false)
                .zIndex(11)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.35), value: viewModel.isSettingsExpanded)
        .animation(.spring(duration: 0.5), value: viewModel.showCelebration)
        .animation(.easeInOut(duration: 0.28), value: viewModel.showCake)
        .statusBarHidden(viewModel.isImmersive)
        .onChange(of: viewModel.mode) { _, _ in viewModel.rebuildCandles() }
        .onChange(of: viewModel.candleCount) { _, _ in
            if viewModel.mode == .count { viewModel.rebuildCandles() }
        }
        .onChange(of: viewModel.age) { _, _ in
            if viewModel.mode == .digits { viewModel.rebuildCandles() }
        }
    }

    /// Top half: settings (scrollable). Bottom half: live candle / cake preview.
    private var setupLayout: some View {
        GeometryReader { geo in
            // Settings a bit taller so all controls fit; preview stays in the lower third.
            let topHeight = geo.size.height * 0.58
            let bottomHeight = geo.size.height - topHeight

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        header
                        ControlsPanel(viewModel: viewModel) {
                            withAnimation(.easeInOut(duration: 0.28)) {
                                viewModel.collapseSettingsForBlow()
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: topHeight)

                VStack(spacing: 8) {
                    CakeSceneView(
                        candles: viewModel.candles,
                        immersive: false,
                        showCake: viewModel.showCake,
                        compact: true,
                        onTapCandle: { id in
                            viewModel.toggleLight(id)
                        }
                    )

                    Text(viewModel.statusMessage)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }
                .frame(width: geo.size.width, height: bottomHeight)
                .background(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.12),
                            Color.clear,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
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
                    showCake: viewModel.showCake,
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
        VStack(spacing: 4) {
            Text("电子蜡烛")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .tracking(1)
            Text("许愿 · 纪念 · 慢慢吹灭")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}
