import SwiftUI

struct ControlsPanel: View {
    @ObservedObject var viewModel: CandleViewModel
    var onCollapse: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerRow

            sectionCard(title: "场景", systemImage: "sparkles") {
                Picker("场景", selection: $viewModel.showCake) {
                    Text("只要蜡烛").tag(false)
                    Text("蜡烛 + 蛋糕").tag(true)
                }
                .pickerStyle(.segmented)
            }

            sectionCard(title: "蜡烛样式", systemImage: "flame") {
                Picker("蜡烛样式", selection: $viewModel.mode) {
                    ForEach(CandleLayoutMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                if viewModel.mode == .count {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("数量")
                                .foregroundStyle(.white.opacity(0.7))
                            Spacer()
                            Text("\(viewModel.candleCount)")
                                .font(.title3.weight(.semibold).monospacedDigit())
                                .foregroundStyle(.white)
                        }
                        Slider(
                            value: Binding(
                                get: { Double(viewModel.candleCount) },
                                set: { viewModel.candleCount = Int($0.rounded()) }
                            ),
                            in: 1...20,
                            step: 1
                        )
                        .tint(Color(red: 1, green: 0.55, blue: 0.35))
                    }
                    .padding(.top, 4)
                } else {
                    HStack {
                        Text("年龄")
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Stepper(value: $viewModel.age, in: 0...99) {
                            Text("\(viewModel.age) 岁")
                                .font(.title3.weight(.semibold).monospacedDigit())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding(.top, 4)
                }
            }

            sectionCard(title: "声音", systemImage: "speaker.wave.2") {
                toggleRow(
                    title: "生日快乐音乐",
                    subtitle: "点燃后轻声循环",
                    isOn: Binding(
                        get: { viewModel.musicEnabled },
                        set: { viewModel.setMusicEnabled($0) }
                    ),
                    tint: Color(red: 1, green: 0.42, blue: 0.62)
                )
                Divider().overlay(Color.white.opacity(0.08))
                toggleRow(
                    title: "柔和音效",
                    subtitle: "点燃 / 吹灭短促反馈",
                    isOn: Binding(
                        get: { viewModel.softSoundEnabled },
                        set: { viewModel.setSoftSoundEnabled($0) }
                    ),
                    tint: Color(red: 1, green: 0.62, blue: 0.35)
                )
            }

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button {
                        viewModel.lightAll()
                    } label: {
                        Label("点燃", systemImage: "flame.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button {
                        viewModel.rebuildCandles()
                    } label: {
                        Label("重布", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(GhostButtonStyle())
                }

                Button {
                    Task { await viewModel.toggleMic() }
                } label: {
                    Label(
                        viewModel.micEnabled ? "关闭吹气" : "开启吹气",
                        systemImage: viewModel.micEnabled ? "mic.fill" : "mic"
                    )
                }
                .buttonStyle(AccentButtonStyle(isActive: viewModel.micEnabled))

                if viewModel.micEnabled {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("吹气强度")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white.opacity(0.55))
                        BlowLevelBar(level: viewModel.blowLevel)
                    }
                    .padding(.top, 2)
                } else {
                    Text("授权麦克风后，对着底部话筒轻吹即可熄灭。点燃或开启吹气后设置会收起，轻点屏幕可再打开。")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.18), .white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var headerRow: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("设置")
                    .font(.headline.weight(.semibold))
                Text("调好再点燃，沉浸许愿")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            if let onCollapse {
                Button(action: onCollapse) {
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.08), in: Circle())
                }
                .accessibilityLabel("收起设置")
            }
        }
    }

    private func sectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.55))
                .labelStyle(.titleAndIcon)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.22))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func toggleRow(
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        tint: Color
    ) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .tint(tint)
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
                            colors: [
                                Color(red: 0.45, green: 0.9, blue: 0.75),
                                Color(red: 1.0, green: 0.86, blue: 0.4),
                                Color(red: 1.0, green: 0.55, blue: 0.7),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geo.size.width * level))
            }
        }
        .frame(height: 8)
    }
}
