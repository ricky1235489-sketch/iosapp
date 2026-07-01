import SpriteKit

final class HUDLayer: SKNode {
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let bestLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let detailLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")

    override init() {
        super.init()

        scoreLabel.fontSize = 34
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .center

        bestLabel.fontSize = 15
        bestLabel.fontColor = .white.withAlphaComponent(0.72)
        bestLabel.horizontalAlignmentMode = .center

        titleLabel.fontSize = 38
        titleLabel.fontColor = .white
        titleLabel.horizontalAlignmentMode = .center

        subtitleLabel.fontSize = 18
        subtitleLabel.fontColor = .white.withAlphaComponent(0.86)
        subtitleLabel.horizontalAlignmentMode = .center

        detailLabel.fontSize = 16
        detailLabel.fontColor = .white.withAlphaComponent(0.78)
        detailLabel.horizontalAlignmentMode = .center

        hintLabel.fontSize = 14
        hintLabel.fontColor = .white.withAlphaComponent(0.62)
        hintLabel.horizontalAlignmentMode = .center

        addChild(scoreLabel)
        addChild(bestLabel)
        addChild(titleLabel)
        addChild(subtitleLabel)
        addChild(detailLabel)
        addChild(hintLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layout(size: CGSize) {
        let compactWidth = size.width < 380
        scoreLabel.fontSize = compactWidth ? 30 : 34
        bestLabel.fontSize = compactWidth ? 13 : 15
        titleLabel.fontSize = compactWidth ? 32 : 38
        subtitleLabel.fontSize = compactWidth ? 16 : 18
        detailLabel.fontSize = compactWidth ? 14 : 16
        hintLabel.fontSize = compactWidth ? 12 : 14

        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 76)
        bestLabel.position = CGPoint(x: size.width / 2, y: size.height - 102)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.62)
        subtitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.62 - 42)
        detailLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.62 - 72)
        hintLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.62 - 104)
    }

    func updateScore(current: Int, best: Int) {
        scoreLabel.text = "\(current)"
        bestLabel.text = "BEST \(best)"
    }

    func showReady(best: Int) {
        scoreLabel.text = ""
        bestLabel.text = ""
        titleLabel.text = "UFO DODGE"
        subtitleLabel.text = "DRAG TO START"
        detailLabel.text = "BEST \(best)"
        hintLabel.text = "Avoid neon barriers"
        runOverlayPulse()
    }

    func showPlaying() {
        titleLabel.removeAllActions()
        titleLabel.setScale(1.0)
        titleLabel.text = ""
        subtitleLabel.text = ""
        detailLabel.text = ""
        hintLabel.text = ""
    }

    func showGameOver(score: Int, best: Int) {
        titleLabel.text = "CRASHED"
        subtitleLabel.text = "SCORE \(score)"
        detailLabel.text = "BEST \(best)"
        hintLabel.text = "TAP TO RESTART"
        runOverlayPulse()
    }

    private func runOverlayPulse() {
        titleLabel.removeAllActions()
        titleLabel.setScale(1.0)
        let pulse = SKAction.sequence([
            .scale(to: 1.04, duration: 0.28),
            .scale(to: 1.0, duration: 0.28)
        ])
        titleLabel.run(.repeatForever(pulse), withKey: "overlayPulse")
    }
}
