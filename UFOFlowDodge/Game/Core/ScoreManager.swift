import Foundation

final class ScoreManager {
    private let bestScoreKey = "bestScore"
    private let userDefaults: UserDefaults

    private(set) var currentScore: Int = 0
    private(set) var bestScore: Int

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        bestScore = userDefaults.integer(forKey: bestScoreKey)
    }

    func resetRun() {
        currentScore = 0
    }

    func advance(deltaTime: TimeInterval, speed: Double) {
        currentScore += Int((deltaTime * speed).rounded())
    }

    func finishRun() {
        guard currentScore > bestScore else { return }
        bestScore = currentScore
        userDefaults.set(bestScore, forKey: bestScoreKey)
    }
}
