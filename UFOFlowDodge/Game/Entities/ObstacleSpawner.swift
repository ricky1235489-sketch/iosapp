import SpriteKit

final class ObstacleSpawner {
    private var elapsedSinceSpawn: TimeInterval = 0
    private(set) var obstacles: [SKShapeNode] = []

    func reset() {
        elapsedSinceSpawn = 0
        obstacles.forEach { $0.removeFromParent() }
        obstacles.removeAll()
    }

    func update(
        deltaTime: TimeInterval,
        in scene: SKScene,
        speed: Double,
        spawnInterval: TimeInterval,
        gap: Double,
        zone: Zone
    ) {
        elapsedSinceSpawn += deltaTime

        if elapsedSinceSpawn >= spawnInterval {
            elapsedSinceSpawn = 0
            spawnPair(in: scene, gap: CGFloat(gap), color: zone.obstacleColor)
        }

        moveObstacles(deltaTime: deltaTime, speed: speed)
        cleanupObstacles()
    }

    private func spawnPair(in scene: SKScene, gap: CGFloat, color: SKColor) {
        let sceneWidth = scene.size.width
        let minimumSideWidth = CGFloat(24)
        let maximumGap = sceneWidth - minimumSideWidth * 2
        guard maximumGap > 0 else { return }

        let obstacleWidth = CGFloat.random(in: 46...82)
        let effectiveGap = min(max(gap, 0), maximumGap)
        let halfGap = effectiveGap / 2
        let lowerCenterX = halfGap + minimumSideWidth
        let upperCenterX = sceneWidth - halfGap - minimumSideWidth
        let centerX = lowerCenterX <= upperCenterX ? CGFloat.random(in: lowerCenterX...upperCenterX) : sceneWidth / 2
        let leftWidth = centerX - halfGap
        let rightX = centerX + halfGap
        let rightWidth = sceneWidth - rightX
        let height = CGFloat.random(in: 70...150)
        let y = scene.size.height + height

        addObstacle(size: CGSize(width: leftWidth, height: height), position: CGPoint(x: leftWidth / 2, y: y), color: color, in: scene)
        addObstacle(size: CGSize(width: rightWidth, height: height), position: CGPoint(x: rightX + rightWidth / 2, y: y), color: color, in: scene)

        if Int.random(in: 0...3) == 0 {
            let block = CGSize(width: obstacleWidth, height: CGFloat.random(in: 46...86))
            if let blockX = optionalBlockCenterX(sceneWidth: sceneWidth, gapCenterX: centerX, effectiveGap: effectiveGap, blockWidth: block.width) {
                addObstacle(size: block, position: CGPoint(x: blockX, y: y + 180), color: color.withAlphaComponent(0.85), in: scene)
            }
        }
    }

    private func optionalBlockCenterX(sceneWidth: CGFloat, gapCenterX: CGFloat, effectiveGap: CGFloat, blockWidth: CGFloat) -> CGFloat? {
        let ufoBodyWidth = CGFloat(44)
        let protectedPathMargin = CGFloat(24)
        let protectedHalfWidth = max(effectiveGap / 2, ufoBodyWidth / 2 + protectedPathMargin)
        let protectedMinX = gapCenterX - protectedHalfWidth
        let protectedMaxX = gapCenterX + protectedHalfWidth
        let blockHalfWidth = blockWidth / 2

        var ranges: [ClosedRange<CGFloat>] = []
        let leftUpperBound = protectedMinX - blockHalfWidth
        if blockHalfWidth <= leftUpperBound {
            ranges.append(blockHalfWidth...leftUpperBound)
        }

        let rightLowerBound = protectedMaxX + blockHalfWidth
        let rightUpperBound = sceneWidth - blockHalfWidth
        if rightLowerBound <= rightUpperBound {
            ranges.append(rightLowerBound...rightUpperBound)
        }

        guard let range = ranges.randomElement() else { return nil }
        return CGFloat.random(in: range)
    }

    private func addObstacle(size: CGSize, position: CGPoint, color: SKColor, in scene: SKScene) {
        let obstacle = SKShapeNode(rectOf: size, cornerRadius: 8)
        obstacle.position = position
        obstacle.fillColor = color
        obstacle.strokeColor = .white.withAlphaComponent(0.35)
        obstacle.lineWidth = 1
        obstacle.glowWidth = 8
        obstacle.zPosition = 5
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.92, height: size.height * 0.92))
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.ufo
        obstacle.physicsBody?.collisionBitMask = 0
        scene.addChild(obstacle)
        obstacles.append(obstacle)
    }

    private func moveObstacles(deltaTime: TimeInterval, speed: Double) {
        let fall = CGFloat(speed * deltaTime)
        for obstacle in obstacles {
            obstacle.position.y -= fall
        }
    }

    private func cleanupObstacles() {
        obstacles.removeAll { obstacle in
            if obstacle.position.y < -240 {
                obstacle.removeFromParent()
                return true
            }
            return false
        }
    }
}
