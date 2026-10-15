import Combine
import SwiftUI
import UIKit

struct ConfettiView: View {
    let isActive: Bool
    @State private var particles: [ConfettiParticle] = []
    @State private var now: TimeInterval = Date.timeIntervalSinceReferenceDate

    var body: some View {
        Canvas { context, _ in
            for particle in particles {
                let age = now - particle.birth
                guard age < particle.lifetime else { continue }
                let t = age / particle.lifetime
                let x = particle.origin.x + particle.velocity.dx * age
                let y = particle.origin.y + particle.velocity.dy * age + 180 * age * age
                let rect = CGRect(x: x, y: y, width: particle.size, height: particle.size * 0.6)
                var ctx = context
                ctx.opacity = 1 - t
                ctx.fill(Path(roundedRect: rect, cornerRadius: 1), with: .color(particle.color))
            }
        }
        .ignoresSafeArea()
        .onReceive(Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()) { date in
            guard isActive else { return }
            now = date.timeIntervalSinceReferenceDate
        }
        .onChange(of: isActive) { _, active in
            if active {
                spawn()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    spawn(intensity: 0.6)
                }
            } else {
                particles = []
            }
        }
    }

    private func spawn(intensity: Double = 1) {
        let colors: [Color] = [.pink, .yellow, .purple, .mint, .orange, .white]
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        let origin = CGPoint(x: w * 0.5, y: h * 0.35)
        let count = Int(120 * intensity)
        let birth = Date.timeIntervalSinceReferenceDate
        particles.append(contentsOf: (0..<count).map { _ in
            ConfettiParticle(
                origin: origin,
                velocity: CGVector(
                    dx: CGFloat.random(in: -180...180),
                    dy: CGFloat.random(in: -320 ... -120)
                ),
                size: CGFloat.random(in: 5...11),
                color: colors.randomElement() ?? .yellow,
                lifetime: Double.random(in: 1.6...2.8),
                birth: birth
            )
        })
    }
}

private struct ConfettiParticle {
    let origin: CGPoint
    let velocity: CGVector
    let size: CGFloat
    let color: Color
    let lifetime: Double
    let birth: TimeInterval
}
