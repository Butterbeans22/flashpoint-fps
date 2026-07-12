import SwiftUI

struct GameOverView: View {
    let score: Int
    let missionComplete: Bool
    let onRestart: () -> Void

    private var accentColor: Color {
        missionComplete ? Color(red: 0.3, green: 0.7, blue: 1.0) : Color(red: 0.9, green: 0.2, blue: 0.1)
    }
    private var titleText: String { missionComplete ? "MISSION COMPLETE" : "OPERATOR DOWN" }
    private var subtitleText: String { missionComplete ? "Hostage rescued. All clear." : "You have been eliminated." }
    private var buttonText: String { missionComplete ? "PLAY AGAIN" : "TRY AGAIN" }

    var body: some View {
        ZStack {
            Color.black.opacity(0.82).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header bar
                Text("FLASHPOINT — OP: RESCUE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(accentColor.opacity(0.5))
                    .tracking(4)
                    .padding(.bottom, 28)

                Text(titleText)
                    .font(.system(size: 34, weight: .black, design: .monospaced))
                    .foregroundColor(accentColor)
                    .tracking(2)

                Text(subtitleText)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.white.opacity(0.45))
                    .padding(.top, 8)

                // Score block
                VStack(spacing: 4) {
                    Text("FINAL SCORE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(4)
                    Text(String(format: "%05d", score))
                        .font(.system(size: 44, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 28)

                Button(action: onRestart) {
                    Text(buttonText)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .tracking(3)
                        .padding(.horizontal, 44)
                        .padding(.vertical, 14)
                        .background(accentColor)
                        .clipShape(Capsule())
                }
            }
        }
    }
}
