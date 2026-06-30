import XCTest
@testable import UFOFlowDodge

final class DifficultyCurveTests: XCTestCase {
    func testSpeedIncreasesWithScoreButIsCapped() {
        let curve = DifficultyCurve()
        XCTAssertEqual(curve.speed(forScore: 0), 260, accuracy: 0.01)
        XCTAssertGreaterThan(curve.speed(forScore: 1_000), curve.speed(forScore: 0))
        XCTAssertEqual(curve.speed(forScore: 100_000), 620, accuracy: 0.01)
    }

    func testSpawnIntervalShrinksButIsCapped() {
        let curve = DifficultyCurve()
        XCTAssertEqual(curve.spawnInterval(forScore: 0), 0.95, accuracy: 0.01)
        XCTAssertLessThan(curve.spawnInterval(forScore: 2_000), curve.spawnInterval(forScore: 0))
        XCTAssertEqual(curve.spawnInterval(forScore: 100_000), 0.42, accuracy: 0.01)
    }

    func testObstacleGapShrinksButIsCapped() {
        let curve = DifficultyCurve()
        XCTAssertEqual(curve.obstacleGap(forScore: 0), 210, accuracy: 0.01)
        XCTAssertLessThan(curve.obstacleGap(forScore: 2_000), curve.obstacleGap(forScore: 0))
        XCTAssertEqual(curve.obstacleGap(forScore: 100_000), 132, accuracy: 0.01)
    }
}
