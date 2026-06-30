import Foundation

struct DifficultyCurve {
    func speed(forScore score: Int) -> Double {
        min(620, 260 + Double(score) * 0.08)
    }

    func spawnInterval(forScore score: Int) -> TimeInterval {
        max(0.42, 0.95 - Double(score) * 0.00012)
    }

    func obstacleGap(forScore score: Int) -> Double {
        max(132, 210 - Double(score) * 0.015)
    }
}
