import SpriteKit

final class HUDLayer: SKNode {
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let bestLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let centerLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")

    override init() {
        super.init()

        scoreLabel.fontSize = 34
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .center

        bestLabel.fontSize = 15
        bestLabel.fontColor = .white.withAlphaComponent(0.72)
        bestLabel.horizontalAlignmentMode = .center

        centerLabel.fontSize = 34
        centerLabel.fontColor = .white
        centerLabel.horizontalAlignmentMode = .center

        subtitleLabel.fontSize = 17
        subtitleLabel.fontColor = .white.withAlphaComponent(0.78)
        subtitleLabel.horizontalAlignmentMode = .center

        addChild(scoreLabel)
        addChild(bestLabel)
        addChild(centerLabel)
        addChild(subtitleLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layout(size: CGSize) {
        let compactWidth = size.width < 380
        scoreLabel.fontSize = compactWidth ? 30 : 34
        bestLabel.fontSize = compactWidth ? 13 : 15
        centerLabel.fontSize = compactWidth ? 29 : 34
        subtitleLabel.fontSize = compactWidth ? 15 : 17

        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 76)
        bestLabel.position = CGPoint(x: size.width / 2, y: size.height - 102)
        centerLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.56)
        subtitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.56 - 38)
    }

    func updateScore(current: Int, best: Int) {
        scoreLabel.text = "\(current)"
        bestLabel.text = "BEST \(best)"
    }

    func showReady() {
        centerLabel.text = "UFO DODGE"
        subtitleLabel.text = "DRAG TO START"
    }

    func showPlaying() {
        centerLabel.text = ""
        subtitleLabel.text = ""
    }

    func showGameOver(score: Int) {
        centerLabel.text = "CRASHED \(score)"
        subtitleLabel.text = "TAP TO RESTART"
    }
}
