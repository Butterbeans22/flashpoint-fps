import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var gameState = GameState()

    var scene: GameScene {
        let s = GameScene()
        s.size = UIScreen.main.bounds.size
        s.scaleMode = .resizeFill
        s.gameState = gameState
        return s
    }

    var body: some View {
        ZStack {
            // Game
            SpriteView(scene: scene)
                .ignoresSafeArea()

            // Vignette — dark radial gradient to mimic scope / gun-sight look
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear,                                        location: 0.30),
                    .init(color: .black.opacity(0.38),                          location: 0.74),
                    .init(color: .black.opacity(0.72),                          location: 1.00),
                ]),
                center: .center,
                startRadius: 0,
                endRadius: max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.75
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Scan-line overlay (tactical CRT feel)
            ScanLineOverlay()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // Tactical HUD
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    // Health
                    VStack(alignment: .leading, spacing: 3) {
                        Text("HEALTH")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.1, green: 0.8, blue: 0.25).opacity(0.6))
                            .tracking(3)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(red: 0.1, green: 0.8, blue: 0.25).opacity(0.12))
                                Rectangle()
                                    .fill(Color(red: 0.1, green: 0.8, blue: 0.25).opacity(0.7))
                                    .frame(width: geo.size.width * CGFloat(gameState.health) / 100)
                                    .animation(.easeOut(duration: 0.15), value: gameState.health)
                            }
                            .overlay(
                                Rectangle()
                                    .strokeBorder(Color(red: 0.1, green: 0.8, blue: 0.25).opacity(0.35), lineWidth: 1)
                            )
                        }
                        .frame(width: 120, height: 6)
                    }

                    Spacer()

                    // Score
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("SCORE")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.1, green: 0.8, blue: 0.25).opacity(0.6))
                            .tracking(3)
                        Text(String(format: "%05d", gameState.score))
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.15, green: 0.95, blue: 0.30))
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)

                Spacer()

                // Enemies remaining indicator
                Text(gameState.missionComplete ? "MISSION COMPLETE" : "ELIMINATE ALL THREATS")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(gameState.missionComplete
                        ? Color(red: 0.3, green: 0.7, blue: 1.0).opacity(0.7)
                        : Color(red: 0.1, green: 0.8, blue: 0.25).opacity(0.25))
                    .tracking(4)
                    .padding(.bottom, 10)
            }

            // End screens
            if gameState.isGameOver {
                GameOverView(score: gameState.score, missionComplete: false) {
                    gameState.reset()
                }
            } else if gameState.missionComplete {
                GameOverView(score: gameState.score, missionComplete: true) {
                    gameState.reset()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Scan line overlay
struct ScanLineOverlay: View {
    var body: some View {
        Canvas { ctx, size in
            let spacing: CGFloat = 4
            var y: CGFloat = 0
            while y < size.height {
                ctx.fill(
                    Path(CGRect(x: 0, y: y, width: size.width, height: 1)),
                    with: .color(.black.opacity(0.04))
                )
                y += spacing
            }
        }
    }
}
