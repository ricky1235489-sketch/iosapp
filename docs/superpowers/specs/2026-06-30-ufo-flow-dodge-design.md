# UFO Flow Dodge Design

Date: 2026-06-30

## Summary

Build a native iOS SpriteKit arcade game where the player controls a UFO that continuously travels forward through neon areas. The player drags anywhere on the screen to move the UFO and dodge obstacles. The first version focuses on a fast, addictive endless run loop: play quickly, crash quickly, restart quickly, and chase a higher score.

## Product Direction

The MVP is an arcade-first endless dodge game.

- Core loop: dodge obstacles, survive longer, score higher, restart instantly.
- Control feel: direct drag with no noticeable inertia.
- Progression structure: endless zones that change as distance increases.
- Visual direction: neon arcade with high contrast, glow, particles, and clear obstacle silhouettes.
- First technical route: native iOS with Swift and SpriteKit.

## Gameplay

The game uses portrait orientation. The UFO appears near the lower-middle area of the screen while the world scrolls toward the player, creating the feeling that the UFO is moving forward toward distant destinations.

The player can touch and drag anywhere on the screen. The UFO follows the finger position directly while staying inside the playable safe bounds. Obstacles move toward the UFO. If the UFO collides with an obstacle, the run ends and the game shows the score, best score, and a tap-to-restart prompt.

The score increases with distance survived. As the score rises, the game gradually increases obstacle speed, reduces safe spacing slightly, and introduces more difficult obstacle patterns. Every distance threshold switches the current neon zone. The MVP can represent zones with background colour changes, particle effects, starfield variation, and obstacle palette/shape changes rather than handcrafted levels.

## MVP Features

- Playable SpriteKit game scene.
- UFO direct drag control.
- Screen bounds clamping for UFO movement.
- Continuous forward-motion effect through scrolling background and incoming obstacles.
- Random obstacle generation.
- Obstacle cleanup after leaving the screen.
- Distance-based score.
- Local best score persistence.
- Speed and difficulty scaling over time.
- Endless zone switching by distance threshold.
- Collision detection between UFO and obstacles.
- Game states: ready, playing, game over.
- Tap-to-restart after crash.
- Basic HUD for current score, best score, and game over prompt.
- Placeholder-ready hooks for sound/haptics, with sound assets optional for the MVP.

## Out Of Scope For MVP

- App Store in-app purchases.
- Ads.
- Game Center leaderboards.
- Account system.
- Complex mission system.
- UFO skin unlocks.
- Tutorial levels.
- Full music and sound pack.
- Handcrafted level map or campaign.
- Multiplayer or online sync.

## Technical Architecture

Use Swift and SpriteKit in a native iOS app.

### Main Components

`GameScene`

- Owns the SpriteKit scene lifecycle.
- Holds the update loop.
- Routes touch input to the UFO controller.
- Coordinates game state, obstacle spawning, score updates, and collision handling.

`UFOController`

- Creates and owns the UFO node.
- Applies direct drag movement.
- Clamps movement to playable bounds.
- Defines a collision body slightly smaller than the visible UFO.
- Resets UFO position when a run restarts.

`ObstacleSpawner`

- Generates obstacle patterns based on the current difficulty.
- Moves obstacles toward the player.
- Removes obstacles after they leave the screen.
- Adjusts spawn timing, speed, and gap sizes as difficulty rises.

`ZoneManager`

- Tracks the current zone from distance thresholds.
- Provides zone-specific background colours, particle style, and obstacle palette.
- Keeps zone transitions lightweight for the MVP.

`ScoreManager`

- Tracks current distance score.
- Reads and writes local best score with `UserDefaults`.
- Exposes formatted score values for the HUD.

`GameState`

- Represents `ready`, `playing`, and `gameOver`.
- Prevents update, collision, and restart behaviour from overlapping.

`HUDLayer`

- Displays current score and best score.
- Displays game over and tap-to-restart prompts.
- Keeps HUD layout responsive across supported iPhone sizes.

## Data Flow

During `GameScene.update`, the scene advances the run only while the game state is `playing`.

1. Calculate delta time.
2. Increase distance score.
3. Ask `ZoneManager` for the current zone based on distance.
4. Ask `ObstacleSpawner` to spawn, move, and clean up obstacles using the current speed and zone styling.
5. Update background scrolling and particles.
6. Update HUD score labels.

When the player touches or drags, `GameScene` passes the touch location to `UFOController`. The controller maps the touch into scene coordinates and moves the UFO directly to the clamped target location.

When SpriteKit reports a contact between the UFO and an obstacle, `GameScene` switches to `gameOver`, stops spawning new obstacles, records the best score if needed, plays a short crash effect or placeholder hook, and shows the restart UI.

## Visual Design

The visual style is neon arcade:

- Dark space background.
- Cyan/white glowing UFO.
- Bright obstacle colours such as pink, yellow, green, and purple.
- Clear obstacle silhouettes that remain readable at speed.
- Scrolling stars, scan lines, or particles to sell forward motion.
- Zone changes through palette and background shifts rather than detailed scenery.

Readability is more important than decoration. Obstacles must stand out clearly from the background, and the UFO must remain visible when effects are active.

## Control And Fairness

- The UFO follows the finger directly without visible drift.
- Touch can begin anywhere on the screen.
- Movement stays inside safe screen bounds.
- The UFO collision shape is slightly smaller than the visible glow.
- Obstacle collision bodies may be slightly smaller than their visible shape.
- The player should feel that near misses are fair and intentional.

## Difficulty Tuning

Difficulty should scale gradually:

- Base speed starts approachable.
- Speed increases with distance.
- Spawn timing becomes tighter with distance.
- Gap sizes shrink slightly but never become impossible.
- Later zones can introduce pattern variation, such as paired blocks, staggered blocks, and moving hazards.

The MVP should prefer simple patterns with strong tuning over many obstacle types.

## Testing And Verification

Verify the MVP on iPhone simulator and, when available, a physical iPhone.

- UFO follows drag input accurately.
- UFO cannot leave playable bounds.
- Obstacles spawn continuously.
- Obstacles are removed after leaving the screen.
- Collision reliably enters game over.
- Restart clears obstacles, resets speed, resets score, and repositions the UFO.
- Score increases during play and stops at game over.
- Best score persists between app launches.
- Zone changes happen at the expected distance thresholds.
- HUD remains readable across common iPhone screen sizes.
- The game remains smooth during extended play.

## Success Criteria

The MVP is successful when a player can launch the app, understand the control immediately, survive by dodging obstacles, crash, see their score, and restart within one tap. The first build should make the core loop feel good before adding monetisation, unlocks, missions, or complex progression.
