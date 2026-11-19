import SwiftUI

struct ControlsPanel: View {
    @ObservedObject var viewModel: CandleViewModel
    var onCollapse: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow

            sectionCard {
                Picker("场景", selection: $viewModel.showCake) {
                    Text("只要蜡烛").tag(false)
                    Text("蜡烛 + 蛋糕").tag(true)
                }
                .pickerStyle(.segmented)

                Picker("蜡烛样式", selection: $viewModel.mode) {
                    ForEach(CandleLayoutMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                if viewModel.mode == .count {
                    HStack {
                        Text("数量 \(viewModel.candleCount)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
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
                } else {
                    HStack {
                        Text("年龄")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                        Spacer()
                        Stepper(value: $viewModel.age, in: 0...99) {
                            Text("\(viewModel.age) 岁")
                                .font(.subheadline.weight(.semibold).monospacedDigit())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
            }

            sectionCard {
                toggleRow(
                    title: "生日快乐音乐",
                    isOn: Binding(
                        get: { viewModel.musicEnabled },
                        set: { viewModel.setMusicEnabled($0) }
                    ),
                    tint: Color(red: 1, green: 0.42, blue: 0.62)
                )
                Divider().overlay(Color.white.opacity(0.08))
                toggleRow(
                    title: "柔和音效",
                    isOn: Binding(
                        get: { viewModel.softSoundEnabled },
                        set: { viewModel.setSoftSoundEnabled($0) }
                    ),
                    tint: Color(red: 1, green: 0.62, blue: 0.35)
                )
            }

            HStack(spacing: 8) {
                Button {
                    Task { await viewModel.lightAll() }
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

            Text("点燃后会请求麦克风权限，对着手机吹气即可熄灭蜡烛。")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }

    private var headerRow: some View {
        HStack {
            Text("设置")
                .font(.subheadline.weight(.semibold))
            Spacer()
            if let onCollapse {
                Button(action: onCollapse) {
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.08), in: Circle())
                }
                .accessibilityLabel("收起设置")
            }
        }
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.22))
        )
    }

    private func toggleRow(title: String, isOn: Binding<Bool>, tint: Color) -> some View {
        Toggle(title, isOn: isOn)
            .font(.subheadline)
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
