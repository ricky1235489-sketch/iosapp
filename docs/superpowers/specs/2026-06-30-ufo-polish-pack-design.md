# UFO Flow Dodge Polish Pack Design

Date: 2026-06-30

## Summary

Improve the first playable UFO Flow Dodge MVP so it feels more like a real mobile arcade game. This polish pack focuses on the first-run experience, game over presentation, and tactile feedback. It does not add menus, monetisation, unlocks, or new progression systems.

## Goals

- Make the ready state feel intentional rather than like placeholder text.
- Make game over clearer and more satisfying.
- Add lightweight haptic feedback for start, near-instant crash feedback, and restart.
- Keep the one-tap restart loop fast.
- Avoid adding external audio assets or complex settings.

## Player Experience

### Ready State

When the app opens or a run resets, the player sees a focused start overlay:

- Title: `UFO DODGE`
- Subtitle: `DRAG TO START`
- Best score line: `BEST <score>`
- Small hint: `Avoid neon barriers`

The UFO remains visible near the lower-middle screen. While waiting, the UFO has a subtle pulse animation so the screen feels alive. The background starfield stays visible.

Touching anywhere starts the run immediately, hides the overlay, triggers a light haptic, and moves the UFO to the touch location.

### Playing State

During play, the HUD remains minimal:

- Current score at top center.
- Best score below current score.

No extra instructions appear during play. The visual field stays clear for dodging.

### Game Over State

On collision, the game shows a more explicit crash overlay:

- Title: `CRASHED`
- Score line: `SCORE <score>`
- Best line: `BEST <best>`
- Restart prompt: `TAP TO RESTART`

Collision triggers:

- Short UFO flash, keeping the existing visual feedback.
- Strong haptic feedback.
- A brief screen flash or HUD pulse, implemented with SpriteKit nodes rather than image assets.

Tapping once after game over resets and immediately starts the next run, preserving the existing one-tap restart behaviour.

## Haptics

Add a small `HapticsManager` wrapper around UIKit haptic APIs:

- `playStart()` uses light impact feedback.
- `playCrash()` uses notification/error feedback or heavy impact feedback.
- `playRestart()` uses light impact feedback.

Haptics should be best-effort. If the device or environment does not support haptics, the game should continue silently without errors.

The MVP does not include a haptics toggle. A settings screen can come later.

## Visual Feedback

Add only small SpriteKit-native effects:

- UFO idle pulse in ready state.
- Stop idle pulse when play starts.
- Crash overlay appears immediately after collision.
- Optional short full-screen translucent flash on crash.

All effects must avoid blocking restart. Animations should be short and should not delay input.

## Architecture

### `HUDLayer`

Extend `HUDLayer` so it can present richer overlay states:

- Ready overlay with title, subtitle, best score, hint.
- Playing state that hides overlay text.
- Game over overlay with score, best score, and restart prompt.

Keep score labels and overlay labels inside `HUDLayer`. `GameScene` should only call methods such as `showReady(best:)`, `showPlaying()`, and `showGameOver(score:best:)`.

### `UFOController`

Add methods for idle animation control:

- `startIdlePulse()`
- `stopIdlePulse()`

The pulse should affect scale or alpha subtly. It must not interfere with direct drag movement or collision body behaviour.

### `HapticsManager`

Create a small focused type responsible only for haptic feedback. `GameScene` owns one instance and calls it during state transitions.

### `GameScene`

`GameScene` remains the coordinator:

- On reset: show ready HUD, reset UFO, start idle pulse.
- On start: hide overlay, stop idle pulse, play start haptic.
- On collision: end run, show game over HUD, play crash haptic, show crash flash.
- On one-tap restart: reset, immediately start, move UFO to touch, play restart haptic.

## Out Of Scope

- Audio files or music.
- Sound settings.
- Main menu screen.
- Pause screen.
- Skin unlocks.
- Coins or rewards.
- New obstacle types.
- Game Center.
- App icon and launch screen art.

## Testing And Verification

Automated tests:

- Existing score/core tests should still pass.
- Add unit tests only if logic is moved into testable pure Swift types. SpriteKit visual animation can be verified by static review and simulator smoke tests.

Manual simulator checks:

- Ready overlay shows title, start prompt, best score, and hint.
- UFO pulses while ready.
- Dragging starts play immediately and removes overlay.
- Crash shows `CRASHED`, score, best, and restart prompt.
- Tapping once after crash starts a new run immediately.
- Haptics calls do not crash in simulator.
- HUD text remains readable on compact iPhone widths.

## Success Criteria

The game should feel more intentional within the first five seconds: the player understands what to do, gets tactile feedback when starting and crashing, sees a clear game over result, and can restart instantly without menu friction.
