import CoreGraphics
import XCTest
@testable import UFOFlowDodge

final class MovementBoundsTests: XCTestCase {
    func testClampKeepsPointInsideInsets() {
        let bounds = MovementBounds(size: CGSize(width: 300, height: 600), inset: 40)
        XCTAssertEqual(bounds.clamp(CGPoint(x: -10, y: 700)), CGPoint(x: 40, y: 560))
        XCTAssertEqual(bounds.clamp(CGPoint(x: 500, y: -20)), CGPoint(x: 260, y: 40))
    }

    func testClampLeavesInteriorPointUnchanged() {
        let bounds = MovementBounds(size: CGSize(width: 300, height: 600), inset: 40)
        XCTAssertEqual(bounds.clamp(CGPoint(x: 120, y: 220)), CGPoint(x: 120, y: 220))
    }
}
