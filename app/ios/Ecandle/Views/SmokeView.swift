import SwiftUI

/// Brief rising smoke + fading ember after a candle is blown out.
struct SmokeView: View {
    let token: Int
    @State private var particles: [SmokeParticle] = []
    @State private var emberOpacity: Double = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(Color.orange.opacity(0.55))
                .frame(width: 5, height: 5)
                .blur(radius: 1.5)
                .opacity(emberOpacity)
                .offset(y: -2)

            TimelineView(.animation(minimumInterval: 1 / 30, paused: particles.isEmpty)) { timeline in
                Canvas { context, _ in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    for particle in particles {
                        let age = now - particle.birth
                        guard age < particle.lifetime else { continue }
                        let t = age / particle.lifetime
                        let x = particle.origin.x + particle.drift * age
                        let y = particle.origin.y - particle.rise * age
                        let size = particle.size * (1 + t * 1.4)
                        var ctx = context
                        ctx.opacity = (1 - t) * 0.45
                        let rect = CGRect(x: x - size / 2, y: y - size / 2, width: size, height: size)
                        ctx.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.7)))
                    }
                }
            }
            .frame(width: 36, height: 48)
        }
        .frame(width: 36, height: 48)
        .allowsHitTesting(false)
        .onChange(of: token) { _, _ in
            play()
        }
        .onAppear {
            if token > 0 {
                play()
            }
        }
    }

    private func play() {
        let now = Date.timeIntervalSinceReferenceDate
        particles = (0..<7).map { _ in
            SmokeParticle(
                origin: CGPoint(x: CGFloat.random(in: 14...22), y: 40),
                drift: CGFloat.random(in: -8...8),
                rise: CGFloat.random(in: 22...38),
                size: CGFloat.random(in: 4...8),
                lifetime: Double.random(in: 0.7...1.2),
                birth: now
            )
        }
        emberOpacity = 0.85
        withAnimation(.easeOut(duration: 1.1)) {
            emberOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            particles = []
        }
    }
}

private struct SmokeParticle {
    let origin: CGPoint
    let drift: CGFloat
    let rise: CGFloat
    let size: CGFloat
    let lifetime: Double
    let birth: TimeInterval
}
