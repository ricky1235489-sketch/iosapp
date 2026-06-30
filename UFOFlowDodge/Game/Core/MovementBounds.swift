import CoreGraphics

struct MovementBounds {
    let size: CGSize
    let inset: CGFloat

    func clamp(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: min(max(point.x, inset), size.width - inset),
            y: min(max(point.y, inset), size.height - inset)
        )
    }
}
