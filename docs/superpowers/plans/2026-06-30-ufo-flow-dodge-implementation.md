# UFO Flow Dodge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first playable native iOS SpriteKit MVP for UFO Flow Dodge: drag a UFO, dodge obstacles, score distance, crash, save best score, and restart instantly.

**Architecture:** Use a small UIKit-hosted SpriteKit app. Keep testable gameplay rules in focused Swift types (`GameState`, `ScoreManager`, `ZoneManager`, `DifficultyCurve`, `MovementBounds`) and let `GameScene` compose SpriteKit nodes, input, spawning, collision, HUD, and restart flow.

**Tech Stack:** Swift, UIKit, SpriteKit, XCTest, XcodeGen project configuration for repeatable Xcode project generation.

---

## File Structure

- Create `project.yml`: XcodeGen project definition for an iOS app target and a unit test target.
- Create `UFOFlowDodge/App/AppDelegate.swift`: UIKit app entry point.
- Create `UFOFlowDodge/App/SceneDelegate.swift`: window setup and root view controller.
- Create `UFOFlowDodge/App/GameViewController.swift`: presents the SpriteKit `GameScene`.
- Create `UFOFlowDodge/App/Info.plist`: app metadata, portrait orientation, scene manifest.
- Create `UFOFlowDodge/Game/Core/GameState.swift`: ready/playing/gameOver state enum.
- Create `UFOFlowDodge/Game/Core/MovementBounds.swift`: testable screen-bound clamping.
- Create `UFOFlowDodge/Game/Core/DifficultyCurve.swift`: score-to-speed/spawn tuning.
- Create `UFOFlowDodge/Game/Core/ScoreManager.swift`: current score and local best score persistence.
- Create `UFOFlowDodge/Game/Core/ZoneManager.swift`: distance-to-zone mapping and neon palettes.
- Create `UFOFlowDodge/Game/Rendering/BackgroundLayer.swift`: scrolling starfield and zone colours.
- Create `UFOFlowDodge/Game/Rendering/HUDLayer.swift`: score, best score, and restart labels.
- Create `UFOFlowDodge/Game/Entities/UFOController.swift`: UFO node creation, direct drag movement, collision body.
- Create `UFOFlowDodge/Game/Entities/ObstacleSpawner.swift`: obstacle generation, movement, cleanup, and collision bodies.
- Create `UFOFlowDodge/Game/Scenes/GameScene.swift`: main SpriteKit scene, update loop, touch handling, collisions, game states.
- Create `UFOFlowDodgeTests/MovementBoundsTests.swift`: clamp behaviour tests.
- Create `UFOFlowDodgeTests/DifficultyCurveTests.swift`: difficulty scaling tests.
- Create `UFOFlowDodgeTests/ScoreManagerTests.swift`: score and best-score tests.
- Create `UFOFlowDodgeTests/ZoneManagerTests.swift`: zone threshold tests.

## Task 1: Project Foundation

**Files:**
- Create: `project.yml`
- Create: `UFOFlowDodge/App/AppDelegate.swift`
- Create: `UFOFlowDodge/App/SceneDelegate.swift`
- Create: `UFOFlowDodge/App/GameViewController.swift`
- Create: `UFOFlowDodge/App/Info.plist`
- Create: `UFOFlowDodge/Game/Scenes/GameScene.swift`

- [ ] **Step 1: Add XcodeGen configuration**

Create `project.yml`:

```yaml
name: UFOFlowDodge
options:
  bundleIdPrefix: com.ricky1235489
  deploymentTarget:
    iOS: "16.0"
settings:
  base:
    SWIFT_VERSION: "5.9"
targets:
  UFOFlowDodge:
    type: application
    platform: iOS
    sources:
      - UFOFlowDodge
    info:
      path: UFOFlowDodge/App/Info.plist
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.ricky1235489.UFOFlowDodge
        INFOPLIST_FILE: UFOFlowDodge/App/Info.plist
        TARGETED_DEVICE_FAMILY: "1"
  UFOFlowDodgeTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - UFOFlowDodgeTests
    dependencies:
      - target: UFOFlowDodge
```

- [ ] **Step 2: Add the app delegate**

Create `UFOFlowDodge/App/AppDelegate.swift`:

```swift
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
```

- [ ] **Step 3: Add the scene delegate**

Create `UFOFlowDodge/App/SceneDelegate.swift`:

```swift
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = GameViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
}
```

- [ ] **Step 4: Add the initial view controller**

Create `UFOFlowDodge/App/GameViewController.swift`:

```swift
import SpriteKit
import UIKit

final class GameViewController: UIViewController {
    override func loadView() {
        view = SKView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = view as? SKView else { return }
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
```

- [ ] **Step 5: Add app metadata**

Create `UFOFlowDodge/App/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
        <key>UISceneConfigurations</key>
        <dict>
            <key>UIWindowSceneSessionRoleApplication</key>
            <array>
                <dict>
                    <key>UISceneConfigurationName</key>
                    <string>Default Configuration</string>
                    <key>UISceneDelegateClassName</key>
                    <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
                </dict>
            </array>
        </dict>
    </dict>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>UILaunchScreen</key>
    <dict/>
</dict>
</plist>
```

- [ ] **Step 6: Add a compile-ready placeholder game scene**

Create `UFOFlowDodge/Game/Scenes/GameScene.swift`:

```swift
import SpriteKit

final class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.03, green: 0.05, blue: 0.10, alpha: 1.0)
    }
}
```

- [ ] **Step 7: Generate the Xcode project**

Run on macOS with XcodeGen installed:

```bash
xcodegen generate
```

Expected: `UFOFlowDodge.xcodeproj` is created with app and test targets.

- [ ] **Step 8: Build the empty app**

Run on macOS:

```bash
xcodebuild -project UFOFlowDodge.xcodeproj -scheme UFOFlowDodge -destination 'platform=iOS Simulator,name=iPhone 15' build
```

Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 9: Commit**

```bash
git add project.yml UFOFlowDodge
git commit -m "feat: scaffold SpriteKit iOS app"
```

## Task 2: Testable Core Rules

**Files:**
- Create: `UFOFlowDodge/Game/Core/GameState.swift`
- Create: `UFOFlowDodge/Game/Core/MovementBounds.swift`
- Create: `UFOFlowDodge/Game/Core/DifficultyCurve.swift`
- Create: `UFOFlowDodge/Game/Core/ScoreManager.swift`
- Create: `UFOFlowDodge/Game/Core/ZoneManager.swift`
- Create: `UFOFlowDodgeTests/MovementBoundsTests.swift`
- Create: `UFOFlowDodgeTests/DifficultyCurveTests.swift`
- Create: `UFOFlowDodgeTests/ScoreManagerTests.swift`
- Create: `UFOFlowDodgeTests/ZoneManagerTests.swift`

- [ ] **Step 1: Write movement bounds tests**

Create `UFOFlowDodgeTests/MovementBoundsTests.swift`:

```swift
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
```

- [ ] **Step 2: Write difficulty curve tests**

Create `UFOFlowDodgeTests/DifficultyCurveTests.swift`:

```swift
import XCTest
@testable import UFOFlowDodge

final class DifficultyCurveTests: XCTestCase {
    func testSpeedIncreasesWithScoreButIsCapped() {
        let curve = DifficultyCurve()
        XCTAssertEqual(curve.speed(forScore: 0), 260, accuracy: 0.01)
        XCTAssertGreaterThan(curve.speed(forScore: 1_000), curve.speed(forScore: 0))
        XCTAssertEqual(curve.speed(forScore: 100_000), 620, accuracy: 0.01)
    }

    func testSpawnIntervalShrinksButIsCapped() {
        let curve = DifficultyCurve()
        XCTAssertEqual(curve.spawnInterval(forScore: 0), 0.95, accuracy: 0.01)
        XCTAssertLessThan(curve.spawnInterval(forScore: 2_000), curve.spawnInterval(forScore: 0))
        XCTAssertEqual(curve.spawnInterval(forScore: 100_000), 0.42, accuracy: 0.01)
    }
}
```

- [ ] **Step 3: Write score manager tests**

Create `UFOFlowDodgeTests/ScoreManagerTests.swift`:

```swift
import XCTest
@testable import UFOFlowDodge

final class ScoreManagerTests: XCTestCase {
    func testScoreAdvancesBySpeedAndDeltaTime() {
        let defaults = UserDefaults(suiteName: "ScoreManagerTests-\(UUID().uuidString)")!
        let manager = ScoreManager(userDefaults: defaults)
        manager.resetRun()
        manager.advance(deltaTime: 0.5, speed: 200)
        XCTAssertEqual(manager.currentScore, 100)
    }

    func testBestScorePersists() {
        let defaults = UserDefaults(suiteName: "ScoreManagerTests-\(UUID().uuidString)")!
        let first = ScoreManager(userDefaults: defaults)
        first.resetRun()
        first.advance(deltaTime: 1.0, speed: 345)
        first.finishRun()

        let second = ScoreManager(userDefaults: defaults)
        XCTAssertEqual(second.bestScore, 345)
    }
}
```

- [ ] **Step 4: Write zone manager tests**

Create `UFOFlowDodgeTests/ZoneManagerTests.swift`:

```swift
import XCTest
@testable import UFOFlowDodge

final class ZoneManagerTests: XCTestCase {
    func testZoneChangesAtDistanceThresholds() {
        let manager = ZoneManager()
        XCTAssertEqual(manager.zone(forScore: 0).name, "Neon Drift")
        XCTAssertEqual(manager.zone(forScore: 1_499).name, "Neon Drift")
        XCTAssertEqual(manager.zone(forScore: 1_500).name, "Cyber Canyon")
        XCTAssertEqual(manager.zone(forScore: 3_000).name, "Asteroid Bloom")
        XCTAssertEqual(manager.zone(forScore: 4_500).name, "Aurora Gate")
        XCTAssertEqual(manager.zone(forScore: 6_000).name, "Neon Drift")
    }
}
```

- [ ] **Step 5: Run tests and verify they fail**

Run:

```bash
xcodebuild test -project UFOFlowDodge.xcodeproj -scheme UFOFlowDodge -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: tests fail because `MovementBounds`, `DifficultyCurve`, `ScoreManager`, and `ZoneManager` do not exist.

- [ ] **Step 6: Implement game state**

Create `UFOFlowDodge/Game/Core/GameState.swift`:

```swift
enum GameState: Equatable {
    case ready
    case playing
    case gameOver
}
```

- [ ] **Step 7: Implement movement bounds**

Create `UFOFlowDodge/Game/Core/MovementBounds.swift`:

```swift
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
```

- [ ] **Step 8: Implement difficulty curve**

Create `UFOFlowDodge/Game/Core/DifficultyCurve.swift`:

```swift
import Foundation

struct DifficultyCurve {
    func speed(forScore score: Int) -> Double {
        min(620, 260 + Double(score) * 0.08)
    }

    func spawnInterval(forScore score: Int) -> TimeInterval {
        max(0.42, 0.95 - Double(score) * 0.00012)
    }

    func obstacleGap(forScore score: Int) -> Double {
        max(132, 210 - Double(score) * 0.015)
    }
}
```

- [ ] **Step 9: Implement score manager**

Create `UFOFlowDodge/Game/Core/ScoreManager.swift`:

```swift
import Foundation

final class ScoreManager {
    private let bestScoreKey = "bestScore"
    private let userDefaults: UserDefaults

    private(set) var currentScore: Int = 0
    private(set) var bestScore: Int

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        bestScore = userDefaults.integer(forKey: bestScoreKey)
    }

    func resetRun() {
        currentScore = 0
    }

    func advance(deltaTime: TimeInterval, speed: Double) {
        currentScore += Int((deltaTime * speed).rounded())
    }

    func finishRun() {
        guard currentScore > bestScore else { return }
        bestScore = currentScore
        userDefaults.set(bestScore, forKey: bestScoreKey)
    }
}
```

- [ ] **Step 10: Implement zone manager**

Create `UFOFlowDodge/Game/Core/ZoneManager.swift`:

```swift
import SpriteKit

struct Zone: Equatable {
    let name: String
    let backgroundColor: SKColor
    let obstacleColor: SKColor
    let accentColor: SKColor
}

struct ZoneManager {
    private let zones: [Zone] = [
        Zone(
            name: "Neon Drift",
            backgroundColor: SKColor(red: 0.03, green: 0.05, blue: 0.10, alpha: 1),
            obstacleColor: SKColor(red: 1.00, green: 0.20, blue: 0.45, alpha: 1),
            accentColor: SKColor(red: 0.10, green: 0.85, blue: 1.00, alpha: 1)
        ),
        Zone(
            name: "Cyber Canyon",
            backgroundColor: SKColor(red: 0.05, green: 0.03, blue: 0.12, alpha: 1),
            obstacleColor: SKColor(red: 0.72, green: 0.35, blue: 1.00, alpha: 1),
            accentColor: SKColor(red: 1.00, green: 0.82, blue: 0.20, alpha: 1)
        ),
        Zone(
            name: "Asteroid Bloom",
            backgroundColor: SKColor(red: 0.02, green: 0.10, blue: 0.12, alpha: 1),
            obstacleColor: SKColor(red: 0.55, green: 1.00, blue: 0.35, alpha: 1),
            accentColor: SKColor(red: 1.00, green: 0.36, blue: 0.70, alpha: 1)
        ),
        Zone(
            name: "Aurora Gate",
            backgroundColor: SKColor(red: 0.04, green: 0.09, blue: 0.07, alpha: 1),
            obstacleColor: SKColor(red: 1.00, green: 0.62, blue: 0.20, alpha: 1),
            accentColor: SKColor(red: 0.45, green: 0.95, blue: 0.85, alpha: 1)
        )
    ]

    func zone(forScore score: Int) -> Zone {
        let index = (max(score, 0) / 1_500) % zones.count
        return zones[index]
    }
}
```

- [ ] **Step 11: Run tests and verify they pass**

Run:

```bash
xcodebuild test -project UFOFlowDodge.xcodeproj -scheme UFOFlowDodge -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: `** TEST SUCCEEDED **`.

- [ ] **Step 12: Commit**

```bash
git add UFOFlowDodge/Game/Core UFOFlowDodgeTests
git commit -m "feat: add testable game core"
```

## Task 3: UFO, Background, And HUD Rendering

**Files:**
- Create: `UFOFlowDodge/Game/Entities/UFOController.swift`
- Create: `UFOFlowDodge/Game/Rendering/BackgroundLayer.swift`
- Create: `UFOFlowDodge/Game/Rendering/HUDLayer.swift`
- Modify: `UFOFlowDodge/Game/Scenes/GameScene.swift`

- [ ] **Step 1: Implement UFO controller**

Create `UFOFlowDodge/Game/Entities/UFOController.swift`:

```swift
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
```

- [ ] **Step 2: Implement background layer**

Create `UFOFlowDodge/Game/Rendering/BackgroundLayer.swift`:

```swift
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
```

- [ ] **Step 3: Implement HUD layer**

Create `UFOFlowDodge/Game/Rendering/HUDLayer.swift`:

```swift
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
```

- [ ] **Step 4: Add physics categories and render layers to the scene**

Replace `UFOFlowDodge/Game/Scenes/GameScene.swift` with:

```swift
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
```

- [ ] **Step 5: Build**

Run:

```bash
xcodebuild -project UFOFlowDodge.xcodeproj -scheme UFOFlowDodge -destination 'platform=iOS Simulator,name=iPhone 15' build
```

Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 6: Commit**

```bash
git add UFOFlowDodge/Game/Entities UFOFlowDodge/Game/Rendering UFOFlowDodge/Game/Scenes/GameScene.swift
git commit -m "feat: render UFO background and HUD"
```

## Task 4: Obstacles, Collision, Score, And Restart

**Files:**
- Create: `UFOFlowDodge/Game/Entities/ObstacleSpawner.swift`
- Modify: `UFOFlowDodge/Game/Scenes/GameScene.swift`

- [ ] **Step 1: Implement obstacle spawner**

Create `UFOFlowDodge/Game/Entities/ObstacleSpawner.swift`:

```swift
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
        let obstacleWidth = CGFloat.random(in: 46...82)
        let centerX = CGFloat.random(in: gap...(scene.size.width - gap))
        let leftWidth = max(24, centerX - gap / 2)
        let rightX = centerX + gap / 2
        let rightWidth = max(24, scene.size.width - rightX)
        let height = CGFloat.random(in: 70...150)
        let y = scene.size.height + height

        addObstacle(size: CGSize(width: leftWidth, height: height), position: CGPoint(x: leftWidth / 2, y: y), color: color, in: scene)
        addObstacle(size: CGSize(width: rightWidth, height: height), position: CGPoint(x: rightX + rightWidth / 2, y: y), color: color, in: scene)

        if Int.random(in: 0...3) == 0 {
            let block = CGSize(width: obstacleWidth, height: CGFloat.random(in: 46...86))
            let blockX = CGFloat.random(in: 50...(scene.size.width - 50))
            addObstacle(size: block, position: CGPoint(x: blockX, y: y + 180), color: color.withAlphaComponent(0.85), in: scene)
        }
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
```

- [ ] **Step 2: Integrate score, difficulty, zones, collisions, and restart**

Replace `UFOFlowDodge/Game/Scenes/GameScene.swift` with:

```swift
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

    private var state: GameState = .ready
    private var movementBounds = MovementBounds(size: .zero, inset: 48)
    private var lastUpdateTime: TimeInterval = 0

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
            return
        }

        if state == .ready {
            state = .playing
            hudLayer.showPlaying()
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
        guard mask == PhysicsCategory.ufo | PhysicsCategory.obstacle else { return }
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
        hudLayer.showReady()
    }

    private func moveUFO(with touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        ufoController.move(to: touch.location(in: self), within: movementBounds)
    }

    private func endRun() {
        state = .gameOver
        scoreManager.finishRun()
        hudLayer.updateScore(current: scoreManager.currentScore, best: scoreManager.bestScore)
        hudLayer.showGameOver(score: scoreManager.currentScore)

        let flash = SKAction.sequence([
            .fadeAlpha(to: 0.25, duration: 0.04),
            .fadeAlpha(to: 1.0, duration: 0.08)
        ])
        ufoController.node.run(flash)
    }
}
```

- [ ] **Step 3: Build and run unit tests**

Run:

```bash
xcodebuild test -project UFOFlowDodge.xcodeproj -scheme UFOFlowDodge -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: `** TEST SUCCEEDED **`.

- [ ] **Step 4: Manual simulator smoke test**

Run the app in Xcode or with:

```bash
xcodebuild -project UFOFlowDodge.xcodeproj -scheme UFOFlowDodge -destination 'platform=iOS Simulator,name=iPhone 15' build
```

Expected manual results:

- App opens to a dark neon scene.
- UFO appears near lower-middle screen.
- Dragging anywhere starts the run and moves the UFO directly.
- Obstacles scroll downward continuously.
- Score increases while playing.
- Collision shows `CRASHED <score>` and `TAP TO RESTART`.
- Tapping once after game over resets score, clears obstacles, and returns UFO to start.

- [ ] **Step 5: Commit**

```bash
git add UFOFlowDodge/Game/Entities/ObstacleSpawner.swift UFOFlowDodge/Game/Scenes/GameScene.swift
git commit -m "feat: add endless dodge gameplay loop"
```

## Task 5: Polish, Responsiveness, And Final Verification

**Files:**
- Modify: `UFOFlowDodge/Game/Rendering/HUDLayer.swift`
- Modify: `UFOFlowDodge/Game/Rendering/BackgroundLayer.swift`
- Modify: `UFOFlowDodge/Game/Entities/ObstacleSpawner.swift`
- Modify: `docs/superpowers/specs/2026-06-30-ufo-flow-dodge-design.md` only if implementation reality differs from the approved spec.

- [ ] **Step 1: Add safer HUD scaling**

In `HUDLayer.layout(size:)`, replace fixed font sizes and positions with size-aware values:

```swift
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
```

- [ ] **Step 2: Add a stronger UFO trail**

In `UFOController.init()`, after `node.addChild(dome)`, add:

```swift
let trail = SKShapeNode(ellipseOf: CGSize(width: 28, height: 72))
trail.position = CGPoint(x: 0, y: -34)
trail.fillColor = SKColor(red: 0.10, green: 0.85, blue: 1.00, alpha: 0.12)
trail.strokeColor = .clear
trail.glowWidth = 16
trail.zPosition = -2
node.addChild(trail)
```

- [ ] **Step 3: Rebuild and smoke test on two simulator sizes**

Run:

```bash
xcodebuild -project UFOFlowDodge.xcodeproj -scheme UFOFlowDodge -destination 'platform=iOS Simulator,name=iPhone SE (3rd generation)' build
xcodebuild -project UFOFlowDodge.xcodeproj -scheme UFOFlowDodge -destination 'platform=iOS Simulator,name=iPhone 15' build
```

Expected: both builds succeed.

Manual checks:

- HUD text does not overlap on iPhone SE.
- UFO remains visible and controllable on iPhone SE.
- Obstacles leave fair gaps on iPhone SE and iPhone 15.
- The scene is not blank after rotation is locked to portrait.
- Restart works after at least three crashes in a row.

- [ ] **Step 4: Run final tests**

Run:

```bash
xcodebuild test -project UFOFlowDodge.xcodeproj -scheme UFOFlowDodge -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: `** TEST SUCCEEDED **`.

- [ ] **Step 5: Commit**

```bash
git add UFOFlowDodge
git commit -m "polish: tune first playable UFO dodge build"
```

## Self-Review

- Spec coverage: The plan covers SpriteKit app setup, direct drag UFO movement, forward-motion background, random obstacle generation, obstacle cleanup, score, best score persistence, difficulty scaling, zone switching, collision game over, restart flow, HUD, responsiveness, and simulator verification.
- Out-of-scope controls: Ads, IAP, Game Center, missions, skins, tutorials, music packs, campaigns, multiplayer, and online sync are not included.
- Placeholder scan: No placeholder markers or deferred implementation instructions remain.
- Type consistency: `GameState`, `MovementBounds`, `DifficultyCurve`, `ScoreManager`, `ZoneManager`, `UFOController`, `ObstacleSpawner`, `BackgroundLayer`, `HUDLayer`, and `GameScene` names are consistent across tasks.
