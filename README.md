# Flashpoint FPS

A fast-paced 2D top-down shooter for iPhone built with Swift + SpriteKit.

## Gameplay

- **Move** — left-side virtual joystick
- **Shoot** — tap anywhere on the right side; auto-fires toward the nearest enemy while moving
- Survive waves of enemies. Each 100 points advances the wave, increasing spawn rate and enemy speed.

## Stack

| Layer | Technology |
|---|---|
| Language | Swift 5 |
| UI | SwiftUI |
| Game engine | SpriteKit |
| Min iOS | 17.0 |

## Project structure

```
flashpoint-fps/
├── Flashpoint.xcodeproj/
└── Flashpoint/
    ├── FlashpointApp.swift    # App entry point
    ├── ContentView.swift      # SwiftUI root + HUD overlay
    ├── GameState.swift        # Observable score/health/game-over state
    ├── GameScene.swift        # SpriteKit scene — all game logic
    ├── GameOverView.swift     # Game over screen
    └── Assets.xcassets/
```

## Getting started

1. Open `Flashpoint.xcodeproj` in Xcode 15+
2. Select your iPhone or simulator target
3. Build & run (`⌘R`)

## Origins

Inspired by *Bang Bang #2* — a classic Flash-based shooter from 2008, originally embedded in an Excel spreadsheet.
