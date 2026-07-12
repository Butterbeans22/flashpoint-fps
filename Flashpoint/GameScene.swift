import SpriteKit

// MARK: - Physics categories
struct PhysicsCategory {
    static let none:    UInt32 = 0
    static let player:  UInt32 = 0b0001
    static let enemy:   UInt32 = 0b0010
    static let bullet:  UInt32 = 0b0100
    static let wall:    UInt32 = 0b1000
}

// MARK: - GameScene
class GameScene: SKScene, SKPhysicsContactDelegate {

    weak var gameState: GameState?

    // Nodes
    private var player: SKSpriteNode!
    private var joystickBase: SKShapeNode!
    private var joystickThumb: SKShapeNode!
    private var fireButton: SKShapeNode!

    // Touch tracking
    private var moveTouchID: UITouch?
    private var joystickVector = CGVector.zero

    // Timers
    private var enemySpawnTimer: Timer?
    private var lastFireTime: TimeInterval = 0
    private let fireInterval: TimeInterval = 0.25
    private var lastUpdateTime: TimeInterval = 0

    // Game config
    private let playerSpeed: CGFloat = 220
    private let bulletSpeed: CGFloat = 600
    private let enemyBaseSpeed: CGFloat = 80
    private var wave: Int = 1

    override func didMove(to view: SKView) {
        setupScene()
        setupPlayer()
        setupControls()
        startEnemySpawner()
    }

    // MARK: - Setup

    private func setupScene() {
        backgroundColor = SKColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        // Floor grid
        let grid = SKNode()
        let spacing: CGFloat = 60
        let lineColor = SKColor(white: 1, alpha: 0.05)
        for x in stride(from: CGFloat(0), through: size.width, by: spacing) {
            let line = SKShapeNode(rect: CGRect(x: x, y: 0, width: 1, height: size.height))
            line.fillColor = lineColor
            line.strokeColor = .clear
            grid.addChild(line)
        }
        for y in stride(from: CGFloat(0), through: size.height, by: spacing) {
            let line = SKShapeNode(rect: CGRect(x: 0, y: y, width: size.width, height: 1))
            line.fillColor = lineColor
            line.strokeColor = .clear
            grid.addChild(line)
        }
        addChild(grid)
    }

    private func setupPlayer() {
        player = SKSpriteNode(color: .clear, size: CGSize(width: 44, height: 44))
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        player.zPosition = 10

        // Crosshair shape
        let body = SKShapeNode(circleOfRadius: 18)
        body.fillColor = SKColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1)
        body.strokeColor = SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1)
        body.lineWidth = 2
        player.addChild(body)

        let cross = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -22, y: 0)); path.addLine(to: CGPoint(x: 22, y: 0))
        path.move(to: CGPoint(x: 0, y: -22)); path.addLine(to: CGPoint(x: 0, y: 22))
        cross.path = path
        cross.strokeColor = SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 0.6)
        cross.lineWidth = 1
        player.addChild(cross)

        // Physics
        player.physicsBody = SKPhysicsBody(circleOfRadius: 18)
        player.physicsBody?.categoryBitMask    = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        player.physicsBody?.collisionBitMask   = PhysicsCategory.wall
        player.physicsBody?.allowsRotation     = false
        player.physicsBody?.linearDamping      = 8

        addChild(player)
    }

    private func setupControls() {
        let margin: CGFloat = 80
        let baseRadius: CGFloat = 52

        // Left joystick
        joystickBase = SKShapeNode(circleOfRadius: baseRadius)
        joystickBase.position = CGPoint(x: margin + baseRadius, y: margin + baseRadius)
        joystickBase.fillColor = SKColor(white: 1, alpha: 0.08)
        joystickBase.strokeColor = SKColor(white: 1, alpha: 0.2)
        joystickBase.zPosition = 20
        addChild(joystickBase)

        joystickThumb = SKShapeNode(circleOfRadius: 26)
        joystickThumb.position = joystickBase.position
        joystickThumb.fillColor = SKColor(white: 1, alpha: 0.3)
        joystickThumb.strokeColor = SKColor(white: 1, alpha: 0.5)
        joystickThumb.zPosition = 21
        addChild(joystickThumb)

        // Right fire button
        fireButton = SKShapeNode(circleOfRadius: 40)
        fireButton.position = CGPoint(x: size.width - margin - 40, y: margin + 40)
        fireButton.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.2, alpha: 0.25)
        fireButton.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 0.6)
        fireButton.zPosition = 20

        let fireLabel = SKLabelNode(text: "FIRE")
        fireLabel.fontName = "Helvetica-Bold"
        fireLabel.fontSize = 14
        fireLabel.fontColor = SKColor(red: 1, green: 0.5, blue: 0.4, alpha: 1)
        fireLabel.verticalAlignmentMode = .center
        fireButton.addChild(fireLabel)
        addChild(fireButton)
    }

    private func startEnemySpawner() {
        enemySpawnTimer?.invalidate()
        let interval = max(0.6, 2.0 - Double(wave) * 0.1)
        enemySpawnTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.spawnEnemy()
        }
    }

    // MARK: - Spawning

    private func spawnEnemy() {
        guard !(gameState?.isGameOver ?? true) else { return }

        let enemy = SKSpriteNode(color: .clear, size: CGSize(width: 36, height: 36))

        // Spawn at a random edge
        let edge = Int.random(in: 0...3)
        switch edge {
        case 0: enemy.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height + 20)
        case 1: enemy.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: -20)
        case 2: enemy.position = CGPoint(x: -20, y: CGFloat.random(in: 0...size.height))
        default: enemy.position = CGPoint(x: size.width + 20, y: CGFloat.random(in: 0...size.height))
        }

        let dot = SKShapeNode(circleOfRadius: 14)
        dot.fillColor = SKColor(red: 1.0, green: 0.25, blue: 0.15, alpha: 1)
        dot.strokeColor = SKColor(red: 1.0, green: 0.5, blue: 0.4, alpha: 1)
        dot.lineWidth = 2
        enemy.addChild(dot)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 14)
        enemy.physicsBody?.categoryBitMask    = PhysicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        enemy.physicsBody?.collisionBitMask   = PhysicsCategory.enemy
        enemy.physicsBody?.linearDamping      = 1
        enemy.name = "enemy"

        addChild(enemy)

        // Chase player
        let speed = enemyBaseSpeed + CGFloat(wave) * 8
        chasePlayer(node: enemy, speed: speed)
    }

    private func chasePlayer(node: SKSpriteNode, speed: CGFloat) {
        guard !isBeingRemoved(node) else { return }
        let dx = player.position.x - node.position.x
        let dy = player.position.y - node.position.y
        let dist = hypot(dx, dy)
        guard dist > 1 else { return }
        let vx = (dx / dist) * speed
        let vy = (dy / dist) * speed
        node.physicsBody?.velocity = CGVector(dx: vx, dy: vy)

        let delay = SKAction.wait(forDuration: 0.4)
        let update = SKAction.run { [weak self, weak node] in
            guard let self, let node, node.parent != nil else { return }
            self.chasePlayer(node: node, speed: speed)
        }
        node.run(SKAction.sequence([delay, update]), withKey: "chase")
    }

    private func isBeingRemoved(_ node: SKNode) -> Bool {
        node.parent == nil
    }

    // MARK: - Shooting

    private func fireToward(point: CGPoint) {
        let dx = point.x - player.position.x
        let dy = point.y - player.position.y
        let dist = hypot(dx, dy)
        guard dist > 10 else { return }

        let bullet = SKShapeNode(circleOfRadius: 5)
        bullet.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1)
        bullet.strokeColor = .clear
        bullet.position = player.position
        bullet.zPosition = 8
        bullet.name = "bullet"

        bullet.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        bullet.physicsBody?.categoryBitMask    = PhysicsCategory.bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        bullet.physicsBody?.collisionBitMask   = PhysicsCategory.none
        bullet.physicsBody?.affectedByGravity  = false
        bullet.physicsBody?.linearDamping      = 0
        bullet.physicsBody?.velocity = CGVector(
            dx: (dx / dist) * bulletSpeed,
            dy: (dy / dist) * bulletSpeed
        )

        addChild(bullet)

        // Remove bullet after 1.5s if it misses
        bullet.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.removeFromParent()
        ]))

        // Muzzle flash
        let flash = SKShapeNode(circleOfRadius: 10)
        flash.fillColor = SKColor(red: 1, green: 0.9, blue: 0.5, alpha: 0.8)
        flash.strokeColor = .clear
        flash.position = player.position
        flash.zPosition = 9
        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.07),
            SKAction.removeFromParent()
        ]))
        addChild(flash)
    }

    // MARK: - Collisions

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.node
        let b = contact.bodyB.node

        if (a?.name == "bullet" && b?.name == "enemy") ||
           (a?.name == "enemy"  && b?.name == "bullet") {
            let enemy  = a?.name == "enemy"  ? a : b
            let bullet = a?.name == "bullet" ? a : b
            hitEnemy(enemy, bullet: bullet)
        }

        if (a?.name == "enemy" && b == player) || (b?.name == "enemy" && a == player) {
            let enemy = a?.name == "enemy" ? a : b
            enemyReachedPlayer(enemy)
        }
    }

    private func hitEnemy(_ enemy: SKNode?, bullet: SKNode?) {
        guard let enemy else { return }
        bullet?.removeFromParent()

        // Pop effect
        let pop = SKEmitterNode()
        pop.position = enemy.position
        if let sparks = makeSparkEmitter() {
            sparks.position = enemy.position
            addChild(sparks)
            sparks.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.4),
                SKAction.removeFromParent()
            ]))
        }

        enemy.removeFromParent()

        DispatchQueue.main.async { [weak self] in
            self?.gameState?.addScore(10 + self!.wave * 2)
            // Level up every 10 kills
            let score = self?.gameState?.score ?? 0
            let newWave = max(1, score / 100 + 1)
            if newWave != self?.wave {
                self?.wave = newWave
                self?.startEnemySpawner()
            }
        }
    }

    private func enemyReachedPlayer(_ enemy: SKNode?) {
        enemy?.removeFromParent()
        DispatchQueue.main.async { [weak self] in
            self?.gameState?.takeDamage(20)
        }
        // Screen flash red
        let flash = SKSpriteNode(color: SKColor(red: 1, green: 0, blue: 0, alpha: 0.3),
                                  size: size)
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 50
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Simple spark emitter

    private func makeSparkEmitter() -> SKEmitterNode? {
        let e = SKEmitterNode()
        e.particleBirthRate = 80
        e.numParticlesToEmit = 20
        e.particleLifetime = 0.35
        e.particleSpeed = 120
        e.particleSpeedRange = 80
        e.emissionAngleRange = .pi * 2
        e.particleScale = 0.08
        e.particleScaleRange = 0.04
        e.particleScaleSpeed = -0.2
        e.particleColor = SKColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 1)
        e.particleColorBlendFactor = 1
        e.particleAlpha = 1
        e.particleAlphaSpeed = -3
        e.particleBlendMode = .add
        return e
    }

    // MARK: - Update loop

    override func update(_ currentTime: TimeInterval) {
        guard !(gameState?.isGameOver ?? true) else { return }

        let dt = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Apply joystick movement
        if joystickVector != .zero {
            let dx = joystickVector.dx * playerSpeed * CGFloat(dt)
            let dy = joystickVector.dy * playerSpeed * CGFloat(dt)
            var newPos = CGPoint(x: player.position.x + dx,
                                 y: player.position.y + dy)
            newPos.x = newPos.x.clamped(to: 20...(size.width  - 20))
            newPos.y = newPos.y.clamped(to: 20...(size.height - 20))
            player.position = newPos
        }

        // Auto-fire toward nearest enemy if joystick moving
        if joystickVector != .zero {
            if currentTime - lastFireTime >= fireInterval {
                lastFireTime = currentTime
                if let nearest = nearestEnemy() {
                    fireToward(point: nearest.position)
                }
            }
        }
    }

    private func nearestEnemy() -> SKNode? {
        var nearest: SKNode?
        var minDist = CGFloat.infinity
        enumerateChildNodes(withName: "enemy") { node, _ in
            let d = hypot(node.position.x - self.player.position.x,
                          node.position.y - self.player.position.y)
            if d < minDist { minDist = d; nearest = node }
        }
        return nearest
    }

    // MARK: - Touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            let isLeft = loc.x < size.width / 2
            if isLeft && moveTouchID == nil {
                moveTouchID = touch
                updateJoystick(touch: touch)
            } else if !isLeft {
                // Fire toward tap point
                fireToward(point: loc)
                lastFireTime = CACurrentMediaTime()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches where touch == moveTouchID {
            updateJoystick(touch: touch)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches where touch == moveTouchID {
            moveTouchID = nil
            joystickVector = .zero
            joystickThumb.position = joystickBase.position
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func updateJoystick(touch: UITouch) {
        let loc = touch.location(in: self)
        let base = joystickBase.position
        let maxRadius: CGFloat = 40
        var dx = loc.x - base.x
        var dy = loc.y - base.y
        let dist = hypot(dx, dy)
        if dist > maxRadius {
            dx = (dx / dist) * maxRadius
            dy = (dy / dist) * maxRadius
        }
        joystickThumb.position = CGPoint(x: base.x + dx, y: base.y + dy)
        let norm = dist > 0 ? min(dist / maxRadius, 1.0) : 0
        joystickVector = dist > 4 ? CGVector(dx: (dx / maxRadius) * norm,
                                              dy: (dy / maxRadius) * norm) : .zero
    }

    // MARK: - Cleanup

    override func willMove(from view: SKView) {
        enemySpawnTimer?.invalidate()
        enemySpawnTimer = nil
    }
}

// MARK: - Comparable clamp helper
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
