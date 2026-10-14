import SwiftUI

struct ControlsPanel: View {
    @ObservedObject var viewModel: CandleViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("蜡烛样式")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))

            Picker("蜡烛样式", selection: $viewModel.mode) {
                ForEach(CandleLayoutMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if viewModel.mode == .count {
                HStack {
                    Text("数量 \(viewModel.candleCount)")
                    Slider(value: Binding(
                        get: { Double(viewModel.candleCount) },
                        set: { viewModel.candleCount = Int($0.rounded()) }
                    ), in: 1...20, step: 1)
                }
            } else {
                HStack {
                    Text("年龄")
                    Stepper(value: $viewModel.age, in: 0...99) {
                        Text("\(viewModel.age) 岁")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }

            Toggle("背景音乐（生日快乐）", isOn: Binding(
                get: { viewModel.musicEnabled },
                set: { viewModel.setMusicEnabled($0) }
            ))
            .tint(Color(red: 1, green: 0.42, blue: 0.62))

            HStack(spacing: 10) {
                Button("点燃蜡烛") {
                    viewModel.lightAll()
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("重新布置") {
                    viewModel.rebuildCandles()
                }
                .buttonStyle(GhostButtonStyle())
            }

            Button(viewModel.micEnabled ? "关闭吹气" : "开启吹气（麦克风）") {
                Task { await viewModel.toggleMic() }
            }
            .buttonStyle(AccentButtonStyle(isActive: viewModel.micEnabled))

            if viewModel.micEnabled {
                VStack(alignment: .leading, spacing: 6) {
                    Text("吹气强度")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.55))
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.black.opacity(0.35))
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.mint, .yellow, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * viewModel.blowLevel)
                        }
                    }
                    .frame(height: 8)
                }
            } else {
                Text("吹气需授权麦克风。安静环境下对着底部麦克风吹，强度条升高时会熄灭火焰。")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                LinearGradient(colors: [Color.orange, Color.red.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: Capsule()
            )
            .foregroundStyle(Color(red: 0.1, green: 0.04, blue: 0.03))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.white.opacity(0.08), in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.15)))
            .foregroundStyle(.white)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct AccentButtonStyle: ButtonStyle {
    var isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(
                LinearGradient(colors: [Color.purple, Color.pink], startPoint: .leading, endPoint: .trailing),
                in: Capsule()
            )
            .foregroundStyle(.white)
            .overlay(
                Capsule()
                    .stroke(isActive ? Color.white.opacity(0.5) : .clear, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
