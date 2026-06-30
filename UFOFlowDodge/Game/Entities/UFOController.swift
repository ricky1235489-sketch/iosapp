import SpriteKit

final class UFOController {
    let node = SKNode()
    private let bodySize = CGSize(width: 44, height: 24)

    init() {
        let glow = SKShapeNode(ellipseOf: CGSize(width: 72, height: 32))
        glow.fillColor = SKColor(red: 0.10, green: 0.85, blue: 1.00, alpha: 0.22)
        glow.strokeColor = .clear
        glow.glowWidth = 18
        glow.zPosition = -1

        let saucer = SKShapeNode(ellipseOf: CGSize(width: 58, height: 22))
        saucer.fillColor = SKColor(red: 0.10, green: 0.85, blue: 1.00, alpha: 1.0)
        saucer.strokeColor = .white
        saucer.lineWidth = 2
        saucer.glowWidth = 10

        let dome = SKShapeNode(rectOf: CGSize(width: 28, height: 18), cornerRadius: 9)
        dome.position = CGPoint(x: 0, y: 10)
        dome.fillColor = .white
        dome.strokeColor = .clear

        node.addChild(glow)
        node.addChild(saucer)
        node.addChild(dome)

        let trail = SKShapeNode(ellipseOf: CGSize(width: 28, height: 72))
        trail.position = CGPoint(x: 0, y: -34)
        trail.fillColor = SKColor(red: 0.10, green: 0.85, blue: 1.00, alpha: 0.12)
        trail.strokeColor = .clear
        trail.glowWidth = 16
        trail.zPosition = -2
        node.addChild(trail)

        node.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.ufo
        node.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        node.physicsBody?.collisionBitMask = 0
    }

    func reset(in size: CGSize) {
        node.position = CGPoint(x: size.width / 2, y: size.height * 0.28)
    }

    func move(to point: CGPoint, within bounds: MovementBounds) {
        node.position = bounds.clamp(point)
    }
}
