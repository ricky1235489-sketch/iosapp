import XCTest
@testable import UFOFlowDodge

final class ScoreManagerTests: XCTestCase {
    func testScoreAdvancesBySpeedAndDeltaTime() {
        let defaults = UserDefaults(suiteName: "ScoreManagerTests-\(UUID().uuidString)")!
        let manager = ScoreManager(userDefaults: defaults)
        manager.resetRun()
        manager.advance(deltaTime: 0.5, speed: 200)
        XCTAssertEqual(manager.currentScore, 100)
    }

    func testBestScorePersists() {
        let defaults = UserDefaults(suiteName: "ScoreManagerTests-\(UUID().uuidString)")!
        let first = ScoreManager(userDefaults: defaults)
        first.resetRun()
        first.advance(deltaTime: 1.0, speed: 345)
        first.finishRun()

        let second = ScoreManager(userDefaults: defaults)
        XCTAssertEqual(second.bestScore, 345)
    }
}
