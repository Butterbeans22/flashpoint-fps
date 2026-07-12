import Foundation
import Combine

class GameState: ObservableObject {
    @Published var score: Int = 0
    @Published var health: Int = 100
    @Published var isGameOver: Bool = false
    @Published var missionComplete: Bool = false

    func addScore(_ points: Int) {
        score += points
    }

    func takeDamage(_ amount: Int) {
        health = max(0, health - amount)
        if health == 0 { isGameOver = true }
    }

    func rescueHostage() {
        missionComplete = true
    }

    func reset() {
        score = 0
        health = 100
        isGameOver = false
        missionComplete = false
    }
}
