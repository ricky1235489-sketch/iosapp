import UIKit

final class HapticsManager {
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()

    init() {
        lightImpact.prepare()
        heavyImpact.prepare()
        notification.prepare()
    }

    func playStart() {
        lightImpact.impactOccurred()
        lightImpact.prepare()
    }

    func playCrash() {
        notification.notificationOccurred(.error)
        heavyImpact.impactOccurred()
        notification.prepare()
        heavyImpact.prepare()
    }

    func playRestart() {
        lightImpact.impactOccurred()
        lightImpact.prepare()
    }
}
