import SwiftUI

struct GameOverView: View {
    let score: Int
    let onRestart: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()

            VStack(spacing: 24) {
                Text("FLASHPOINT")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .tracking(6)

                Text("GAME OVER")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("Score: \(score)")
                    .font(.system(size: 22, weight: .semibold, design: .monospaced))
                    .foregroundColor(.orange)

                Button(action: onRestart) {
                    Text("PLAY AGAIN")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(Color.orange)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
    }
}
