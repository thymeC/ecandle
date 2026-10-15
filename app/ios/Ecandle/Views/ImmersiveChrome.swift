import SwiftUI

/// Minimal overlays shown while settings are collapsed (blow / memorial mode).
struct ImmersiveChrome: View {
    @ObservedObject var viewModel: CandleViewModel

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.28)) {
                        viewModel.expandSettings()
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(10)
                        .background(.white.opacity(0.08), in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.12), lineWidth: 1))
                }
                .accessibilityLabel("打开设置")
                .padding(.trailing, 16)
                .padding(.top, 8)
            }

            Spacer()
                .allowsHitTesting(false)

            VStack(spacing: 10) {
                if viewModel.micEnabled {
                    BlowLevelBar(level: viewModel.blowLevel)
                        .frame(width: 120)
                        .opacity(0.7)
                }

                Text(viewModel.statusMessage)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 28)
            .allowsHitTesting(false)
        }
    }
}
