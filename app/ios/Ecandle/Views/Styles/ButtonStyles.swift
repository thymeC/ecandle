import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.62, blue: 0.28),
                        Color(red: 0.95, green: 0.35, blue: 0.28),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .foregroundStyle(Color(red: 0.14, green: 0.06, blue: 0.04))
            .shadow(color: Color.orange.opacity(configuration.isPressed ? 0.15 : 0.35), radius: 10, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                Color.white.opacity(configuration.isPressed ? 0.06 : 0.08),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.14), lineWidth: 1)
            )
            .foregroundStyle(.white.opacity(0.92))
    }
}

struct AccentButtonStyle: ButtonStyle {
    var isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: isActive
                        ? [Color(red: 0.45, green: 0.72, blue: 0.55), Color(red: 0.25, green: 0.55, blue: 0.48)]
                        : [Color(red: 0.62, green: 0.38, blue: 0.92), Color(red: 0.95, green: 0.42, blue: 0.62)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .foregroundStyle(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isActive ? Color.white.opacity(0.45) : .clear, lineWidth: 1.5)
            )
            .shadow(
                color: (isActive ? Color.mint : Color.pink).opacity(configuration.isPressed ? 0.12 : 0.28),
                radius: 10,
                y: 4
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
