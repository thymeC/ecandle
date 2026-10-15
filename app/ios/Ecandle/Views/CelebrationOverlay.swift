import SwiftUI

struct CelebrationOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

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
            .padding(32)
        }
    }
}
