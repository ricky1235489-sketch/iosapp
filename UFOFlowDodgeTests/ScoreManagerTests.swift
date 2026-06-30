import XCTest
@testable import UFOFlowDodge

final class ScoreManagerTests: XCTestCase {
    private var suiteNames: [String] = []

    override func tearDown() {
        for suiteName in suiteNames {
            UserDefaults.standard.removePersistentDomain(forName: suiteName)
        }
        suiteNames.removeAll()
        super.tearDown()
    }

    func testScoreAdvancesBySpeedAndDeltaTime() {
        let defaults = makeDefaults()
        let manager = ScoreManager(userDefaults: defaults)
        manager.resetRun()
        manager.advance(deltaTime: 0.5, speed: 200)
        XCTAssertEqual(manager.currentScore, 100)
    }

    func testBestScorePersists() {
        let defaults = makeDefaults()
        let first = ScoreManager(userDefaults: defaults)
        first.resetRun()
        first.advance(deltaTime: 1.0, speed: 345)
        first.finishRun()

        let second = ScoreManager(userDefaults: defaults)
        XCTAssertEqual(second.bestScore, 345)
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "ScoreManagerTests-\(UUID().uuidString)"
        suiteNames.append(suiteName)
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
