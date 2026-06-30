# UFO Polish Pack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a focused polish pass to UFO Flow Dodge: richer ready/game-over overlays, UFO idle pulse, crash flash, and lightweight haptic feedback.

**Architecture:** Keep presentation state in `HUDLayer`, UFO animation in `UFOController`, haptic calls in a new `HapticsManager`, and orchestration in `GameScene`. Avoid new menus, asset files, settings, or progression systems.

**Tech Stack:** Swift, SpriteKit, UIKit haptics, XCTest, XcodeGen, GitHub Actions iOS CI.

---

## File Structure

- Modify `UFOFlowDodge/Game/Rendering/HUDLayer.swift`: richer ready and game-over overlays.
- Modify `UFOFlowDodge/Game/Entities/UFOController.swift`: idle pulse start/stop.
- Create `UFOFlowDodge/Game/Feedback/HapticsManager.swift`: best-effort haptic wrapper.
- Modify `UFOFlowDodge/Game/Scenes/GameScene.swift`: wire HUD states, idle pulse, haptics, crash flash.
- Modify no docs/spec files during implementation unless behaviour changes from the approved spec.

## Task 1: Rich HUD Overlay States

**Files:**
- Modify: `UFOFlowDodge/Game/Rendering/HUDLayer.swift`

- [ ] **Step 1: Replace HUDLayer with richer overlay labels**

Replace `UFOFlowDodge/Game/Rendering/HUDLayer.swift` with:

```swift
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
```

- [ ] **Step 2: Run available static checks**

Run:

```bash
git diff --check
```

Expected: no whitespace errors. On Windows, LF/CRLF warnings may appear and are acceptable if there are no whitespace error lines.

- [ ] **Step 3: Commit**

```bash
git add UFOFlowDodge/Game/Rendering/HUDLayer.swift
git commit -m "polish: enrich ready and game over HUD"
```

## Task 2: UFO Idle Pulse

**Files:**
- Modify: `UFOFlowDodge/Game/Entities/UFOController.swift`

- [ ] **Step 1: Add idle pulse methods**

In `UFOFlowDodge/Game/Entities/UFOController.swift`, add these methods inside `UFOController` after `move(to:within:)`:

```swift
    func startIdlePulse() {
        node.removeAction(forKey: "idlePulse")
        node.setScale(1.0)
        let pulse = SKAction.sequence([
            .scale(to: 1.06, duration: 0.45),
            .scale(to: 1.0, duration: 0.45)
        ])
        node.run(.repeatForever(pulse), withKey: "idlePulse")
    }

    func stopIdlePulse() {
        node.removeAction(forKey: "idlePulse")
        node.run(.scale(to: 1.0, duration: 0.08))
    }
```

- [ ] **Step 2: Run available static checks**

Run:

```bash
git diff --check
```

Expected: no whitespace errors. On Windows, LF/CRLF warnings may appear and are acceptable if there are no whitespace error lines.

- [ ] **Step 3: Commit**

```bash
git add UFOFlowDodge/Game/Entities/UFOController.swift
git commit -m "polish: add UFO idle pulse"
```

## Task 3: Haptics Manager

**Files:**
- Create: `UFOFlowDodge/Game/Feedback/HapticsManager.swift`

- [ ] **Step 1: Add haptics manager**

Create `UFOFlowDodge/Game/Feedback/HapticsManager.swift`:

```swift
import UIKit

final class HapticsManager {
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()

    init() {
        lightImpact.prepare()
        heavyImpact.prepare()
        notification.prepare()
    }

    func playStart() {
        lightImpact.impactOccurred()
        lightImpact.prepare()
    }

    func playCrash() {
        notification.notificationOccurred(.error)
        heavyImpact.impactOccurred()
        notification.prepare()
        heavyImpact.prepare()
    }

    func playRestart() {
        lightImpact.impactOccurred()
        lightImpact.prepare()
    }
}
```

- [ ] **Step 2: Run available static checks**

Run:

```bash
git diff --check
```

Expected: no whitespace errors. On Windows, LF/CRLF warnings may appear and are acceptable if there are no whitespace error lines.

- [ ] **Step 3: Commit**

```bash
git add UFOFlowDodge/Game/Feedback/HapticsManager.swift
git commit -m "polish: add haptic feedback manager"
```

## Task 4: Wire Polish Into GameScene

**Files:**
- Modify: `UFOFlowDodge/Game/Scenes/GameScene.swift`

- [ ] **Step 1: Add haptics manager property**

In `UFOFlowDodge/Game/Scenes/GameScene.swift`, add this property after `difficultyCurve`:

```swift
    private let hapticsManager = HapticsManager()
```

- [ ] **Step 2: Update start and restart flow**

Replace `touchesBegan(_:with:)` with:

```swift
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
```

- [ ] **Step 3: Add startRun helper**

Add this private method before `moveUFO(with:)`:

```swift
    private func startRun() {
        state = .playing
        ufoController.stopIdlePulse()
        hudLayer.showPlaying()
    }
```

- [ ] **Step 4: Update resetScene ready presentation**

Inside `resetScene()`, replace:

```swift
        hudLayer.updateScore(current: scoreManager.currentScore, best: scoreManager.bestScore)
        hudLayer.showReady()
```

with:

```swift
        hudLayer.updateScore(current: scoreManager.currentScore, best: scoreManager.bestScore)
        hudLayer.showReady(best: scoreManager.bestScore)
        ufoController.startIdlePulse()
```

- [ ] **Step 5: Update endRun crash presentation**

Inside `endRun()`, replace:

```swift
        hudLayer.showGameOver(score: scoreManager.currentScore)
```

with:

```swift
        hudLayer.showGameOver(score: scoreManager.currentScore, best: scoreManager.bestScore)
        hapticsManager.playCrash()
        showCrashFlash()
```

- [ ] **Step 6: Add crash flash helper**

Add this private method before the final closing brace of `GameScene`:

```swift
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
```

- [ ] **Step 7: Run available static checks**

Run:

```bash
git diff --check
```

Expected: no whitespace errors. On Windows, LF/CRLF warnings may appear and are acceptable if there are no whitespace error lines.

- [ ] **Step 8: Commit**

```bash
git add UFOFlowDodge/Game/Scenes/GameScene.swift
git commit -m "polish: wire HUD haptics and crash flash"
```

## Task 5: CI Verification And Manual Checklist

**Files:**
- No source changes expected.

- [ ] **Step 1: Run local available checks**

Run:

```bash
git status --short --branch
git diff --check HEAD~4..HEAD
```

Expected: clean worktree and no whitespace errors. On Windows, LF/CRLF warnings may appear and are acceptable if there are no whitespace error lines.

- [ ] **Step 2: Push branch and check GitHub Actions**

Run:

```bash
git push
```

Expected: branch pushes successfully and GitHub Actions starts an iOS CI run.

- [ ] **Step 3: Mac/iOS CI verification**

Check GitHub Actions for the pushed branch.

Expected:

- XcodeGen project generation succeeds.
- `xcodebuild build` succeeds.
- `xcodebuild test` succeeds.

- [ ] **Step 4: Manual smoke checklist**

When a simulator or cloud Mac is available, verify:

- Ready overlay shows `UFO DODGE`, `DRAG TO START`, `BEST <score>`, and `Avoid neon barriers`.
- UFO pulses while ready.
- Dragging starts play immediately and hides overlay.
- Crash shows `CRASHED`, `SCORE <score>`, `BEST <best>`, and `TAP TO RESTART`.
- One tap after crash starts the next run immediately.
- Haptics calls do not crash in simulator.
- HUD text remains readable on compact iPhone widths.

- [ ] **Step 5: Commit only if checklist docs are changed**

No commit is required if this task only verifies. If a verification note file is intentionally added later, commit it separately with a message describing that note.

## Self-Review

- Spec coverage: The plan covers ready overlay, playing HUD, game-over overlay, haptics, UFO idle pulse, crash flash, one-tap restart integration, compact HUD readability, and verification.
- Out-of-scope controls: No audio files, music, settings screen, main menu, pause screen, unlocks, coins, new obstacle types, Game Center, app icon, or launch art are included.
- Placeholder scan: No placeholder markers or deferred implementation instructions remain.
- Type consistency: `HUDLayer.showReady(best:)`, `HUDLayer.showGameOver(score:best:)`, `UFOController.startIdlePulse()`, `UFOController.stopIdlePulse()`, `HapticsManager.playStart()`, `HapticsManager.playCrash()`, and `HapticsManager.playRestart()` are used consistently.
