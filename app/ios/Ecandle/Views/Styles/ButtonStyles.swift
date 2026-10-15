import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.red.opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
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
