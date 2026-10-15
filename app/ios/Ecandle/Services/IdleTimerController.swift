import UIKit

/// Keeps the screen awake while candles are lit (memorial / dinner / meditation use).
enum IdleTimerController {
    static func setActive(_ active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = active
    }
}
