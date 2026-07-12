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
            SpriteView(scene: scene)
                .ignoresSafeArea()

            VStack {
                HStack {
                    // Health bar
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        ProgressView(value: Double(gameState.health), total: 100)
                            .frame(width: 100)
                            .tint(.red)
                    }
                    Spacer()
                    // Score
                    Text("Score: \(gameState.score)")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()
            }

            if gameState.isGameOver {
                GameOverView(score: gameState.score) {
                    gameState.reset()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
