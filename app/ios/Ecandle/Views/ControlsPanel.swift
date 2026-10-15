import SwiftUI

struct ControlsPanel: View {
    @ObservedObject var viewModel: CandleViewModel
    var onCollapse: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("蜡烛样式")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                if let onCollapse {
                    Button {
                        onCollapse()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.55))
                            .padding(6)
                            .background(.white.opacity(0.08), in: Circle())
                    }
                    .accessibilityLabel("收起设置")
                }
            }

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

            Toggle("柔和音效", isOn: Binding(
                get: { viewModel.softSoundEnabled },
                set: { viewModel.setSoftSoundEnabled($0) }
            ))
            .tint(Color(red: 1, green: 0.62, blue: 0.35))

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
                    BlowLevelBar(level: viewModel.blowLevel)
                }
            } else {
                Text("吹气需授权麦克风。安静环境下对着底部麦克风吹，强度条升高时会熄灭火焰。点燃或开启吹气后设置会自动收起，轻点屏幕或右上角按钮可再打开。")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct BlowLevelBar: View {
    var level: Double

    var body: some View {
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
                    .frame(width: geo.size.width * level)
            }
        }
        .frame(height: 8)
    }
}
