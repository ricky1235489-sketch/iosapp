import SpriteKit

enum PhysicsCategory {
    static let ufo: UInt32 = 1 << 0
    static let obstacle: UInt32 = 1 << 1
}

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let ufoController = UFOController()
    private let obstacleSpawner = ObstacleSpawner()
    private let backgroundLayer = BackgroundLayer()
    private let hudLayer = HUDLayer()
    private let scoreManager = ScoreManager()
    private let zoneManager = ZoneManager()
    private let difficultyCurve = DifficultyCurve()
    private let hapticsManager = HapticsManager()

    private var state: GameState = .ready
    private var movementBounds = MovementBounds(size: .zero, inset: 48)
    private var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        backgroundLayer.zPosition = 0
        ufoController.node.zPosition = 10
        hudLayer.zPosition = 100

        if backgroundLayer.parent == nil {
            addChild(backgroundLayer)
        }
        if ufoController.node.parent == nil {
            addChild(ufoController.node)
        }
        if hudLayer.parent == nil {
            addChild(hudLayer)
        }

        resetScene()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        movementBounds = MovementBounds(size: size, inset: 48)
        backgroundLayer.configure(size: size)
        hudLayer.layout(size: size)
        if state == .ready {
            ufoController.reset(in: size)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 1.0 / 30.0)
        lastUpdateTime = currentTime

        guard state == .playing else { return }

        let speed = difficultyCurve.speed(forScore: scoreManager.currentScore)
        scoreManager.advance(deltaTime: deltaTime, speed: speed)

        let zone = zoneManager.zone(forScore: scoreManager.currentScore)
        backgroundLayer.apply(zone: zone, to: self)
        backgroundLayer.update(deltaTime: deltaTime, speed: speed, size: size)
        obstacleSpawner.update(
            deltaTime: deltaTime,
            in: self,
            speed: speed,
            spawnInterval: difficultyCurve.spawnInterval(forScore: scoreManager.currentScore),
            gap: difficultyCurve.obstacleGap(forScore: scoreManager.currentScore),
            zone: zone
        )
        hudLayer.updateScore(current: scoreManager.currentScore, best: scoreManager.bestScore)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if state == .gameOver {
            resetScene()
            startRun()
            hapticsManager.playRestart()
            moveUFO(with: touches)
            return
        }

        if state == .ready {
            startRun()
            hapticsManager.playStart()
        }
        moveUFO(with: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard state == .playing else { return }
        moveUFO(with: touches)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard state == .playing else { return }
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        guard mask == (PhysicsCategory.ufo | PhysicsCategory.obstacle) else { return }
        endRun()
    }

    private func resetScene() {
        state = .ready
        lastUpdateTime = 0
        movementBounds = MovementBounds(size: size, inset: 48)
        obstacleSpawner.reset()
        backgroundLayer.configure(size: size)
        backgroundLayer.apply(zone: zoneManager.zone(forScore: 0), to: self)
        scoreManager.resetRun()
        ufoController.reset(in: size)
        hudLayer.layout(size: size)
        hudLayer.updateScore(current: scoreManager.currentScore, best: scoreManager.bestScore)
        hudLayer.showReady(best: scoreManager.bestScore)
        ufoController.startIdlePulse()
    }

    private func startRun() {
        state = .playing
        ufoController.stopIdlePulse()
        hudLayer.showPlaying()
    }

    private func moveUFO(with touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        ufoController.move(to: touch.location(in: self), within: movementBounds)
    }

    private func endRun() {
        state = .gameOver
        scoreManager.finishRun()
        hudLayer.updateScore(current: scoreManager.currentScore, best: scoreManager.bestScore)
        hudLayer.showGameOver(score: scoreManager.currentScore, best: scoreManager.bestScore)
        hapticsManager.playCrash()
        showCrashFlash()

        let flash = SKAction.sequence([
            .fadeAlpha(to: 0.25, duration: 0.04),
            .fadeAlpha(to: 1.0, duration: 0.08)
        ])
        ufoController.node.run(flash)
    }

    private func showCrashFlash() {
        let flashNode = SKShapeNode(rectOf: size)
        flashNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flashNode.fillColor = .white.withAlphaComponent(0.18)
        flashNode.strokeColor = .clear
        flashNode.zPosition = 90
        addChild(flashNode)
        flashNode.run(.sequence([
            .fadeOut(withDuration: 0.16),
            .removeFromParent()
        ]))
    }
}
