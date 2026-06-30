import SpriteKit

enum PhysicsCategory {
    static let ufo: UInt32 = 1 << 0
    static let obstacle: UInt32 = 1 << 1
}

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let ufoController = UFOController()
    private let backgroundLayer = BackgroundLayer()
    private let hudLayer = HUDLayer()
    private let scoreManager = ScoreManager()
    private let zoneManager = ZoneManager()

    private var state: GameState = .ready
    private var movementBounds = MovementBounds(size: .zero, inset: 48)

    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        backgroundLayer.zPosition = 0
        ufoController.node.zPosition = 10
        hudLayer.zPosition = 100

        addChild(backgroundLayer)
        addChild(ufoController.node)
        addChild(hudLayer)

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

    private func resetScene() {
        state = .ready
        movementBounds = MovementBounds(size: size, inset: 48)
        backgroundLayer.configure(size: size)
        backgroundLayer.apply(zone: zoneManager.zone(forScore: 0), to: self)
        scoreManager.resetRun()
        ufoController.reset(in: size)
        hudLayer.layout(size: size)
        hudLayer.updateScore(current: scoreManager.currentScore, best: scoreManager.bestScore)
        hudLayer.showReady()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if state == .gameOver {
            resetScene()
            return
        }

        state = .playing
        hudLayer.showPlaying()
        moveUFO(with: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveUFO(with: touches)
    }

    private func moveUFO(with touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        ufoController.move(to: touch.location(in: self), within: movementBounds)
    }
}
