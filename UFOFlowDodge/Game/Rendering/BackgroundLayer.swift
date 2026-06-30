import SpriteKit

final class BackgroundLayer: SKNode {
    private var stars: [SKShapeNode] = []

    func configure(size: CGSize) {
        removeAllChildren()
        stars.removeAll()

        for index in 0..<70 {
            let radius = CGFloat((index % 3) + 1)
            let star = SKShapeNode(circleOfRadius: radius)
            star.fillColor = .white.withAlphaComponent(0.55)
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            stars.append(star)
            addChild(star)
        }
    }

    func apply(zone: Zone, to scene: SKScene) {
        scene.backgroundColor = zone.backgroundColor
    }

    func update(deltaTime: TimeInterval, speed: Double, size: CGSize) {
        let fall = CGFloat(speed * 0.22 * deltaTime)
        for star in stars {
            star.position.y -= fall
            if star.position.y < -8 {
                star.position.y = size.height + 8
                star.position.x = CGFloat.random(in: 0...size.width)
            }
        }
    }
}
