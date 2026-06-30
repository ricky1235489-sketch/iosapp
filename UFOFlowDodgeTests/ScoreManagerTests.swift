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

    func testScoreIsIndependentOfFrameChunking() {
        let oneUpdate = ScoreManager(userDefaults: makeDefaults())
        oneUpdate.resetRun()
        oneUpdate.advance(deltaTime: 1.0, speed: 260)

        let sixtyUpdates = ScoreManager(userDefaults: makeDefaults())
        sixtyUpdates.resetRun()
        for _ in 0..<60 {
            sixtyUpdates.advance(deltaTime: 1.0 / 60.0, speed: 260)
        }

        XCTAssertEqual(oneUpdate.currentScore, 260)
        XCTAssertEqual(sixtyUpdates.currentScore, 260)
        XCTAssertEqual(sixtyUpdates.currentScore, oneUpdate.currentScore)
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
