import XCTest
@testable import UFOFlowDodge

final class ZoneManagerTests: XCTestCase {
    func testZoneChangesAtDistanceThresholds() {
        let manager = ZoneManager()
        XCTAssertEqual(manager.zone(forScore: 0).name, "Neon Drift")
        XCTAssertEqual(manager.zone(forScore: 1_499).name, "Neon Drift")
        XCTAssertEqual(manager.zone(forScore: 1_500).name, "Cyber Canyon")
        XCTAssertEqual(manager.zone(forScore: 3_000).name, "Asteroid Bloom")
        XCTAssertEqual(manager.zone(forScore: 4_500).name, "Aurora Gate")
        XCTAssertEqual(manager.zone(forScore: 6_000).name, "Neon Drift")
    }
}
