import SpriteKit

// MARK: - Physics categories
struct PhysicsCategory {
    static let none:    UInt32 = 0
    static let player:  UInt32 = 0b00001
    static let enemy:   UInt32 = 0b00010
    static let bullet:  UInt32 = 0b00100
    static let wall:    UInt32 = 0b01000
    static let hostage: UInt32 = 0b10000
}

// MARK: - GameScene
class GameScene: SKScene, SKPhysicsContactDelegate {

    weak var gameState: GameState?

    // Core nodes
    private var playerNode: SKNode!
    private var cameraNode: SKCameraNode!
    private var reticleNode: SKNode!

    // HUD controls (camera-space)
    private var joystickBase: SKShapeNode!
    private var joystickThumb: SKShapeNode!
    private var joystickOrigin = CGPoint.zero

    // Touch state
    private var moveTouchID: UITouch?
    private var aimTouchID:  UITouch?
    private var joystickVec  = CGVector.zero
    private var isFiring     = false
    private var lastFireTime: TimeInterval = 0
    private let fireInterval: TimeInterval = 0.18

    // Game
    private var lastUpdateTime: TimeInterval = 0
    private let playerSpeed: CGFloat = 190
    private let bulletSpeed: CGFloat = 680
    private var hostageNode: SKNode?

    // ---------------------------------------------------------------
    // Map layout (SpriteKit Y-up; rooms stacked downward = negative Y)
    //
    //  Room 0  [ENTRY]         y:  -190…+190   x: -300…+300
    //  Hall 0                  y:  -445…-190   x:  -50…+50
    //  Room 1  [GUARD POST]    y:  -825…-445   x: -350…+350
    //  Hall 1                  y: -1080…-825   x:  -50…+50
    //  Room 2  [MAIN HALL]     y: -1480…-1080  x: -350…+350
    //  Hall 2                  y: -1735…-1480  x:  -50…+50
    //  Room 3  [HOSTAGE ROOM]  y: -2155…-1735  x: -400…+400
    // ---------------------------------------------------------------

    private let floorRects: [CGRect] = [
        CGRect(x: -300, y:  -190, width: 600, height: 380),
        CGRect(x:  -50, y:  -445, width: 100, height: 255),
        CGRect(x: -350, y:  -825, width: 700, height: 380),
        CGRect(x:  -50, y: -1080, width: 100, height: 255),
        CGRect(x: -350, y: -1480, width: 700, height: 400),
        CGRect(x:  -50, y: -1735, width: 100, height: 255),
        CGRect(x: -400, y: -2155, width: 800, height: 420),
    ]

    private let wallEdges: [(CGPoint, CGPoint)] = [
        // Room 0
        (CGPoint(x: -300, y:  190), CGPoint(x:  300, y:  190)),
        (CGPoint(x: -300, y: -190), CGPoint(x: -300, y:  190)),
        (CGPoint(x:  300, y: -190), CGPoint(x:  300, y:  190)),
        (CGPoint(x: -300, y: -190), CGPoint(x:  -50, y: -190)),
        (CGPoint(x:   50, y: -190), CGPoint(x:  300, y: -190)),
        // Hall 0
        (CGPoint(x:  -50, y: -445), CGPoint(x:  -50, y: -190)),
        (CGPoint(x:   50, y: -445), CGPoint(x:   50, y: -190)),
        // Room 1
        (CGPoint(x: -350, y: -445), CGPoint(x:  -50, y: -445)),
        (CGPoint(x:   50, y: -445), CGPoint(x:  350, y: -445)),
        (CGPoint(x: -350, y: -825), CGPoint(x: -350, y: -445)),
        (CGPoint(x:  350, y: -825), CGPoint(x:  350, y: -445)),
        (CGPoint(x: -350, y: -825), CGPoint(x:  -50, y: -825)),
        (CGPoint(x:   50, y: -825), CGPoint(x:  350, y: -825)),
        // Hall 1
        (CGPoint(x:  -50, y:-1080), CGPoint(x:  -50, y: -825)),
        (CGPoint(x:   50, y:-1080), CGPoint(x:   50, y: -825)),
        // Room 2
        (CGPoint(x: -350, y:-1080), CGPoint(x:  -50, y:-1080)),
        (CGPoint(x:   50, y:-1080), CGPoint(x:  350, y:-1080)),
        (CGPoint(x: -350, y:-1480), CGPoint(x: -350, y:-1080)),
        (CGPoint(x:  350, y:-1480), CGPoint(x:  350, y:-1080)),
        (CGPoint(x: -350, y:-1480), CGPoint(x:  -50, y:-1480)),
        (CGPoint(x:   50, y:-1480), CGPoint(x:  350, y:-1480)),
        // Hall 2
        (CGPoint(x:  -50, y:-1735), CGPoint(x:  -50, y:-1480)),
        (CGPoint(x:   50, y:-1735), CGPoint(x:   50, y:-1480)),
        // Room 3
        (CGPoint(x: -400, y:-1735), CGPoint(x:  -50, y:-1735)),
        (CGPoint(x:   50, y:-1735), CGPoint(x:  400, y:-1735)),
        (CGPoint(x: -400, y:-2155), CGPoint(x: -400, y:-1735)),
        (CGPoint(x:  400, y:-2155), CGPoint(x:  400, y:-1735)),
        (CGPoint(x: -400, y:-2155), CGPoint(x:  400, y:-2155)),
    ]

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.04, green: 0.04, blue: 0.06, alpha: 1)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        setupCamera()
        buildFloors()
        buildWalls()
        addRoomLabels()
        setupPlayer()
        setupReticle()
        setupHUDControls()
        spawnEnemiesAndHostage()
    }

    // MARK: - Camera

    private func setupCamera() {
        cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode
    }

    // MARK: - Map

    private func buildFloors() {
        for rect in floorRects {
            let floor = SKShapeNode(rect: rect)
            floor.fillColor = SKColor(red: 0.10, green: 0.10, blue: 0.13, alpha: 1)
            floor.strokeColor = .clear
            floor.zPosition = -10
            addChild(floor)

            let tileSize: CGFloat = 56
            let gridColor = SKColor(white: 1, alpha: 0.03)
            var x = (rect.minX / tileSize).rounded(.up) * tileSize
            while x <= rect.maxX {
                let line = SKShapeNode(rect: CGRect(x: x, y: rect.minY, width: 0.6, height: rect.height))
                line.fillColor = gridColor; line.strokeColor = .clear; line.zPosition = -9
                addChild(line); x += tileSize
            }
            var y = (rect.minY / tileSize).rounded(.up) * tileSize
            while y <= rect.maxY {
                let line = SKShapeNode(rect: CGRect(x: rect.minX, y: y, width: rect.width, height: 0.6))
                line.fillColor = gridColor; line.strokeColor = .clear; line.zPosition = -9
                addChild(line); y += tileSize
            }
        }
    }

    private func buildWalls() {
        for (start, end) in wallEdges {
            let path = CGMutablePath()
            path.move(to: start); path.addLine(to: end)

            let wall = SKShapeNode(path: path)
            wall.strokeColor = SKColor(red: 0.30, green: 0.30, blue: 0.38, alpha: 1)
            wall.lineWidth = 10
            wall.lineCap = .square
            wall.zPosition = 5
            wall.physicsBody = SKPhysicsBody(edgeFrom: start, to: end)
            wall.physicsBody?.isDynamic = false
            wall.physicsBody?.categoryBitMask    = PhysicsCategory.wall
            wall.physicsBody?.collisionBitMask   = PhysicsCategory.player | PhysicsCategory.enemy
            wall.physicsBody?.contactTestBitMask = PhysicsCategory.none
            addChild(wall)

            let highlight = SKShapeNode(path: path)
            highlight.strokeColor = SKColor(red: 0.55, green: 0.55, blue: 0.70, alpha: 0.2)
            highlight.lineWidth = 2
            highlight.zPosition = 6
            addChild(highlight)
        }
    }

    private func addRoomLabels() {
        let labels: [(String, CGPoint)] = [
            ("[ ENTRY ]",        CGPoint(x:    0, y:  155)),
            ("[ GUARD POST ]",   CGPoint(x:    0, y: -480)),
            ("[ MAIN HALL ]",    CGPoint(x:    0, y:-1115)),
            ("[ HOSTAGE ROOM ]", CGPoint(x:    0, y:-1770)),
        ]
        for (text, pos) in labels {
            let node = SKLabelNode(text: text)
            node.fontName = "Courier-Bold"
            node.fontSize = 11
            node.fontColor = SKColor(red: 0.12, green: 0.70, blue: 0.22, alpha: 0.30)
            node.position = pos
            node.zPosition = 1
            addChild(node)
        }
    }

    // MARK: - Player

    private func setupPlayer() {
        playerNode = SKNode()
        playerNode.position = CGPoint(x: 0, y: 80)
        playerNode.zPosition = 10

        let body = SKShapeNode(rectOf: CGSize(width: 18, height: 28), cornerRadius: 4)
        body.fillColor = SKColor(red: 0.10, green: 0.50, blue: 0.16, alpha: 0.9)
        body.strokeColor = SKColor(red: 0.20, green: 1.00, blue: 0.35, alpha: 1)
        body.lineWidth = 1.5
        playerNode.addChild(body)

        let head = SKShapeNode(circleOfRadius: 9)
        head.fillColor = SKColor(red: 0.10, green: 0.50, blue: 0.16, alpha: 0.9)
        head.strokeColor = SKColor(red: 0.20, green: 1.00, blue: 0.35, alpha: 0.9)
        head.lineWidth = 1.5
        head.position = CGPoint(x: 0, y: 19)
        playerNode.addChild(head)

        let pip = SKShapeNode(rect: CGRect(x: -2, y: 27, width: 4, height: 8), cornerRadius: 2)
        pip.fillColor = SKColor(red: 0.20, green: 1.00, blue: 0.35, alpha: 0.9)
        pip.strokeColor = .clear
        playerNode.addChild(pip)

        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: 14)
        playerNode.physicsBody?.categoryBitMask    = PhysicsCategory.player
        playerNode.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.hostage
        playerNode.physicsBody?.collisionBitMask   = PhysicsCategory.wall
        playerNode.physicsBody?.allowsRotation     = false
        playerNode.physicsBody?.linearDamping      = 12
        addChild(playerNode)
    }

    // MARK: - Reticle (gun sight)

    private func setupReticle() {
        reticleNode = SKNode()
        reticleNode.position = .zero
        reticleNode.zPosition = 100

        let green    = SKColor(red: 0.08, green: 0.95, blue: 0.25, alpha: 1.0)
        let dimGreen = SKColor(red: 0.08, green: 0.95, blue: 0.25, alpha: 0.28)

        let outer = SKShapeNode(circleOfRadius: 40)
        outer.fillColor = .clear
        outer.strokeColor = dimGreen
        outer.lineWidth = 1.5
        reticleNode.addChild(outer)

        let mid = SKShapeNode(circleOfRadius: 18)
        mid.fillColor = .clear
        mid.strokeColor = SKColor(red: 0.08, green: 0.95, blue: 0.25, alpha: 0.45)
        mid.lineWidth = 1
        reticleNode.addChild(mid)

        let dot = SKShapeNode(circleOfRadius: 2.5)
        dot.fillColor = green
        dot.strokeColor = .clear
        reticleNode.addChild(dot)

        // Crosshair arms with gap
        let gap: CGFloat = 22, arm: CGFloat = 18
        let arms: [(CGPoint, CGPoint)] = [
            (CGPoint(x: 0, y: gap),      CGPoint(x: 0, y: gap + arm)),
            (CGPoint(x: 0, y: -gap),     CGPoint(x: 0, y: -(gap + arm))),
            (CGPoint(x: gap, y: 0),      CGPoint(x: gap + arm, y: 0)),
            (CGPoint(x: -gap, y: 0),     CGPoint(x: -(gap + arm), y: 0)),
        ]
        for (s, e) in arms {
            let p = CGMutablePath(); p.move(to: s); p.addLine(to: e)
            let n = SKShapeNode(path: p)
            n.strokeColor = green; n.lineWidth = 2; n.lineCap = .round
            reticleNode.addChild(n)
        }

        // Tick marks on outer ring
        for deg in stride(from: 0.0, to: 360.0, by: 45.0) {
            let r = CGFloat(deg) * .pi / 180
            let p = CGMutablePath()
            p.move(to: CGPoint(x: cos(r)*42, y: sin(r)*42))
            p.addLine(to: CGPoint(x: cos(r)*52, y: sin(r)*52))
            let n = SKShapeNode(path: p)
            n.strokeColor = dimGreen; n.lineWidth = 1
            reticleNode.addChild(n)
        }

        // Range stadia lines
        for offset: CGFloat in [-62, 62] {
            let p = CGMutablePath()
            p.move(to: CGPoint(x: -7, y: offset))
            p.addLine(to: CGPoint(x: 7, y: offset))
            let n = SKShapeNode(path: p)
            n.strokeColor = dimGreen; n.lineWidth = 1
            reticleNode.addChild(n)
        }

        cameraNode.addChild(reticleNode)
    }

    // MARK: - HUD Controls

    private func setupHUDControls() {
        guard let view else { return }
        let w = view.bounds.width, h = view.bounds.height

        joystickBase = SKShapeNode(circleOfRadius: 52)
        joystickBase.position = CGPoint(x: -w/2 + 95, y: -h/2 + 110)
        joystickBase.fillColor = SKColor(red: 0.08, green: 0.70, blue: 0.18, alpha: 0.08)
        joystickBase.strokeColor = SKColor(red: 0.12, green: 0.90, blue: 0.22, alpha: 0.22)
        joystickBase.lineWidth = 1.5
        joystickBase.zPosition = 60
        cameraNode.addChild(joystickBase)

        joystickThumb = SKShapeNode(circleOfRadius: 24)
        joystickThumb.position = joystickBase.position
        joystickThumb.fillColor = SKColor(red: 0.12, green: 0.90, blue: 0.22, alpha: 0.22)
        joystickThumb.strokeColor = SKColor(red: 0.12, green: 0.90, blue: 0.22, alpha: 0.65)
        joystickThumb.lineWidth = 1.5
        joystickThumb.zPosition = 61
        cameraNode.addChild(joystickThumb)

        let hint = SKLabelNode(text: "‹ MOVE    AIM / FIRE ›")
        hint.fontName = "Courier"
        hint.fontSize = 9
        hint.fontColor = SKColor(red: 0.15, green: 0.75, blue: 0.25, alpha: 0.28)
        hint.position = CGPoint(x: 0, y: -h/2 + 16)
        hint.zPosition = 60
        cameraNode.addChild(hint)
    }

    // MARK: - Enemy / Hostage spawning

    private func spawnEnemiesAndHostage() {
        for i in 0..<3 {
            let angle = CGFloat(i) * 2.09
            spawnEnemy(at: CGPoint(x: cos(angle)*130, y: -635 + sin(angle)*55))
        }
        for i in 0..<4 {
            let angle = CGFloat(i) * 1.57
            spawnEnemy(at: CGPoint(x: cos(angle)*140, y: -1280 + sin(angle)*60))
        }
        for i in 0..<5 {
            let angle = CGFloat(i) * 1.26
            spawnEnemy(at: CGPoint(x: cos(angle)*165, y: -1945 + sin(angle)*65))
        }
        spawnHostage(at: CGPoint(x: 0, y: -1945))
    }

    private func spawnEnemy(at position: CGPoint) {
        let node = SKNode()
        node.name = "enemy"
        node.position = position
        node.zPosition = 8

        let body = SKShapeNode(rectOf: CGSize(width: 19, height: 30), cornerRadius: 3)
        body.fillColor = SKColor(red: 0.62, green: 0.10, blue: 0.06, alpha: 0.9)
        body.strokeColor = SKColor(red: 1.00, green: 0.30, blue: 0.18, alpha: 0.70)
        body.lineWidth = 1.5
        body.position = CGPoint(x: 0, y: -4)
        node.addChild(body)

        let head = SKShapeNode(circleOfRadius: 10)
        head.fillColor = SKColor(red: 0.60, green: 0.08, blue: 0.05, alpha: 0.9)
        head.strokeColor = SKColor(red: 1.00, green: 0.30, blue: 0.18, alpha: 0.60)
        head.lineWidth = 1.5
        head.position = CGPoint(x: 0, y: 20)
        node.addChild(head)

        let glow = SKShapeNode(circleOfRadius: 24)
        glow.fillColor = SKColor(red: 1, green: 0, blue: 0, alpha: 0.04)
        glow.strokeColor = .clear
        node.addChild(glow)

        node.physicsBody = SKPhysicsBody(circleOfRadius: 17)
        node.physicsBody?.categoryBitMask    = PhysicsCategory.enemy
        node.physicsBody?.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        node.physicsBody?.collisionBitMask   = PhysicsCategory.wall | PhysicsCategory.enemy
        node.physicsBody?.allowsRotation     = false
        node.physicsBody?.linearDamping      = 2
        addChild(node)
    }

    private func spawnHostage(at position: CGPoint) {
        let node = SKNode()
        node.name = "hostage"
        node.position = position
        node.zPosition = 8

        let body = SKShapeNode(rectOf: CGSize(width: 17, height: 27), cornerRadius: 3)
        body.fillColor = SKColor(red: 0.12, green: 0.32, blue: 0.78, alpha: 0.9)
        body.strokeColor = SKColor(red: 0.38, green: 0.68, blue: 1.00, alpha: 0.9)
        body.lineWidth = 1.5
        body.position = CGPoint(x: 0, y: -3)
        node.addChild(body)

        let head = SKShapeNode(circleOfRadius: 9)
        head.fillColor = SKColor(red: 0.12, green: 0.32, blue: 0.78, alpha: 0.9)
        head.strokeColor = SKColor(red: 0.38, green: 0.68, blue: 1.00, alpha: 0.9)
        head.lineWidth = 1.5
        head.position = CGPoint(x: 0, y: 17)
        node.addChild(head)

        let label = SKLabelNode(text: "▼ RESCUE")
        label.fontName = "Courier-Bold"
        label.fontSize = 11
        label.fontColor = SKColor(red: 0.38, green: 0.70, blue: 1.00, alpha: 0.9)
        label.position = CGPoint(x: 0, y: 34)
        label.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2,  duration: 0.7),
            SKAction.fadeAlpha(to: 0.95, duration: 0.7),
        ])))
        node.addChild(label)

        node.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.06, duration: 0.7),
            SKAction.scale(to: 0.94, duration: 0.7),
        ])))

        node.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask    = PhysicsCategory.hostage
        node.physicsBody?.contactTestBitMask = PhysicsCategory.player
        node.physicsBody?.collisionBitMask   = PhysicsCategory.none

        hostageNode = node
        addChild(node)
    }

    // MARK: - Shooting

    private func fireTowardReticle() {
        let reticleCam = reticleNode.position
        let worldTarget = CGPoint(x: playerNode.position.x + reticleCam.x,
                                  y: playerNode.position.y + reticleCam.y)
        let dx = worldTarget.x - playerNode.position.x
        let dy = worldTarget.y - playerNode.position.y
        let dist = hypot(dx, dy)
        guard dist > 8 else { return }

        let bullet = SKShapeNode(circleOfRadius: 4)
        bullet.fillColor = SKColor(red: 1.0, green: 0.94, blue: 0.44, alpha: 1)
        bullet.strokeColor = .clear
        bullet.position = playerNode.position
        bullet.zPosition = 9
        bullet.name = "bullet"
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        bullet.physicsBody?.categoryBitMask    = PhysicsCategory.bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        bullet.physicsBody?.collisionBitMask   = PhysicsCategory.wall
        bullet.physicsBody?.affectedByGravity  = false
        bullet.physicsBody?.linearDamping      = 0
        bullet.physicsBody?.velocity = CGVector(dx: (dx/dist)*bulletSpeed, dy: (dy/dist)*bulletSpeed)
        addChild(bullet)
        bullet.run(SKAction.sequence([.wait(forDuration: 1.3), .removeFromParent()]))

        let flash = SKShapeNode(circleOfRadius: 11)
        flash.fillColor = SKColor(red: 1, green: 0.88, blue: 0.48, alpha: 0.9)
        flash.strokeColor = .clear
        flash.position = playerNode.position
        flash.zPosition = 11
        flash.run(SKAction.sequence([.fadeOut(withDuration: 0.06), .removeFromParent()]))
        addChild(flash)

        playerNode.zRotation = atan2(dy, dx) - .pi / 2
    }

    // MARK: - Collisions

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.node, b = contact.bodyB.node

        if (a?.name == "bullet" && b?.name == "enemy") || (a?.name == "enemy" && b?.name == "bullet") {
            destroyEnemy(a?.name == "enemy" ? a : b, bullet: a?.name == "bullet" ? a : b)
        }
        if (a?.name == "enemy" && b == playerNode) || (b?.name == "enemy" && a == playerNode) {
            enemyContactsPlayer(a?.name == "enemy" ? a : b)
        }
        if (a?.name == "hostage" || b?.name == "hostage"),
           (a == playerNode || b == playerNode) {
            attemptRescue()
        }
    }

    private func destroyEnemy(_ enemy: SKNode?, bullet: SKNode?) {
        guard let enemy, enemy.parent != nil else { return }
        bullet?.removeFromParent()

        for _ in 0..<10 {
            let shard = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            shard.fillColor = SKColor(red: 0.75, green: 0.08, blue: 0.06, alpha: 0.9)
            shard.strokeColor = .clear
            shard.position = enemy.position
            shard.zPosition = 12
            shard.physicsBody = SKPhysicsBody(circleOfRadius: 3)
            shard.physicsBody?.categoryBitMask  = PhysicsCategory.none
            shard.physicsBody?.collisionBitMask = PhysicsCategory.none
            shard.physicsBody?.velocity = CGVector(dx: CGFloat.random(in: -100...100),
                                                   dy: CGFloat.random(in: -100...100))
            shard.physicsBody?.linearDamping = 4
            addChild(shard)
            shard.run(SKAction.sequence([
                .wait(forDuration: 0.4), .fadeOut(withDuration: 0.2), .removeFromParent()
            ]))
        }
        enemy.removeFromParent()

        DispatchQueue.main.async { [weak self] in self?.gameState?.addScore(25) }
    }

    private func enemyContactsPlayer(_ enemy: SKNode?) {
        guard let enemy, enemy.parent != nil else { return }
        enemy.removeFromParent()

        let flash = SKSpriteNode(color: SKColor(red: 1, green: 0, blue: 0, alpha: 0.26),
                                  size: CGSize(width: 2000, height: 2000))
        flash.zPosition = 90
        cameraNode.addChild(flash)
        flash.run(SKAction.sequence([.fadeOut(withDuration: 0.24), .removeFromParent()]))

        DispatchQueue.main.async { [weak self] in self?.gameState?.takeDamage(20) }
    }

    private func attemptRescue() {
        let remaining = children.filter { $0.name == "enemy" }.count
        guard remaining == 0 else {
            hostageNode?.run(SKAction.sequence([
                SKAction.colorize(with: .red, colorBlendFactor: 0.7, duration: 0.08),
                SKAction.colorize(withColorBlendFactor: 0, duration: 0.25),
            ]))
            return
        }
        hostageNode?.removeFromParent()

        let flash = SKSpriteNode(color: SKColor(red: 0.18, green: 0.55, blue: 1, alpha: 0.32),
                                  size: CGSize(width: 2000, height: 2000))
        flash.zPosition = 90
        cameraNode.addChild(flash)
        flash.run(SKAction.sequence([.fadeOut(withDuration: 0.7), .removeFromParent()]))

        DispatchQueue.main.async { [weak self] in self?.gameState?.rescueHostage() }
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        guard !(gameState?.isGameOver ?? false),
              !(gameState?.missionComplete ?? false) else { return }

        let dt = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 0.05)
        lastUpdateTime = currentTime

        if joystickVec != .zero {
            playerNode.position.x += joystickVec.dx * playerSpeed * CGFloat(dt)
            playerNode.position.y += joystickVec.dy * playerSpeed * CGFloat(dt)
        }

        let target = playerNode.position
        cameraNode.position = CGPoint(
            x: cameraNode.position.x + (target.x - cameraNode.position.x) * 0.10,
            y: cameraNode.position.y + (target.y - cameraNode.position.y) * 0.10
        )

        enumerateChildNodes(withName: "enemy") { [weak self] node, _ in
            guard let self else { return }
            let dx = self.playerNode.position.x - node.position.x
            let dy = self.playerNode.position.y - node.position.y
            let dist = hypot(dx, dy)
            guard dist > 1 else { return }
            node.physicsBody?.velocity = CGVector(dx: (dx/dist)*72, dy: (dy/dist)*72)
            node.zRotation = atan2(dy, dx) - .pi / 2
        }

        if isFiring, currentTime - lastFireTime >= fireInterval {
            lastFireTime = currentTime
            fireTowardReticle()
        }
    }

    // MARK: - Touch input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view else { return }
        for touch in touches {
            let loc = touch.location(in: view)
            if loc.x < view.bounds.width / 2 {
                if moveTouchID == nil {
                    moveTouchID = touch
                    joystickOrigin = touch.location(in: cameraNode)
                    joystickBase.position  = joystickOrigin
                    joystickThumb.position = joystickOrigin
                }
            } else {
                if aimTouchID == nil { aimTouchID = touch }
                isFiring = true
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view else { return }
        let hw = view.bounds.width  / 2 - 20
        let hh = view.bounds.height / 2 - 20

        for touch in touches {
            if touch == moveTouchID {
                let loc = touch.location(in: cameraNode)
                let dx = loc.x - joystickOrigin.x
                let dy = loc.y - joystickOrigin.y
                let dist = hypot(dx, dy)
                let maxR: CGFloat = 44
                let cx = dist > maxR ? (dx/dist)*maxR : dx
                let cy = dist > maxR ? (dy/dist)*maxR : dy
                joystickThumb.position = CGPoint(x: joystickOrigin.x + cx,
                                                  y: joystickOrigin.y + cy)
                let norm = min(dist / maxR, 1.0)
                joystickVec = dist > 5
                    ? CGVector(dx: (cx/maxR)*norm, dy: (cy/maxR)*norm)
                    : .zero
            }
            if touch == aimTouchID {
                let loc = touch.location(in: cameraNode)
                reticleNode.position = CGPoint(
                    x: loc.x.clamped(to: -hw...hw),
                    y: loc.y.clamped(to: -hh...hh)
                )
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == moveTouchID {
                moveTouchID = nil
                joystickVec = .zero
                joystickThumb.position = joystickBase.position
            }
            if touch == aimTouchID {
                aimTouchID = nil
                isFiring = false
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    override func willMove(from view: SKView) { removeAllActions() }
}

// MARK: - Helpers
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
