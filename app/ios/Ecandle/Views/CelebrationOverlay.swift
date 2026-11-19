import SwiftUI

struct CelebrationOverlay: View {
    var onReplay: () -> Void
    var onSetup: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer(minLength: 40)

                VStack(spacing: 10) {
                    Text("生日快乐！")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .yellow, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("愿望已经藏进星星里啦")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 24)

                VStack(spacing: 12) {
                    Button("再吹一次") {
                        onReplay()
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("重新布置") {
                        onSetup()
                    }
                    .buttonStyle(GhostButtonStyle())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}
