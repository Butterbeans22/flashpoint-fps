import SpriteKit
import UIKit

final class StaticPropActor {
    let node: SKSpriteNode
    let depth: CGFloat
    let lane: CGFloat
    let baseScale: CGFloat

    init(node: SKSpriteNode, depth: CGFloat, lane: CGFloat, baseScale: CGFloat = 1) {
        self.node = node
        self.depth = depth
        self.lane = lane
        self.baseScale = baseScale
    }
}

final class EnemyActor {
    let node: SKSpriteNode
    var depth: CGFloat
    let lane: CGFloat
    let speed: CGFloat
    let points: Int
    var alive = true

    init(node: SKSpriteNode, depth: CGFloat, lane: CGFloat, speed: CGFloat, points: Int) {
        self.node = node
        self.depth = depth
        self.lane = lane
        self.speed = speed
        self.points = points
    }
}

final class BulletActor {
    let node: SKSpriteNode
    var velocity: CGVector
    var life: CGFloat

    init(node: SKSpriteNode, velocity: CGVector, life: CGFloat = 1.2) {
        self.node = node
        self.velocity = velocity
        self.life = life
    }
}

final class ArtFactory {
    static let shared = ArtFactory()

    private init() {}

    func hallwayTexture(size: CGSize) -> SKTexture {
        imageTexture(size: size) { ctx in
            let cg = ctx.cgContext

            cg.setFillColor(UIColor(red: 0.03, green: 0.03, blue: 0.04, alpha: 1).cgColor)
            cg.fill(CGRect(origin: .zero, size: size))

            drawGradient(in: cg, rect: CGRect(origin: .zero, size: size),
                         top: UIColor(red: 0.06, green: 0.07, blue: 0.10, alpha: 1),
                         bottom: UIColor(red: 0.01, green: 0.01, blue: 0.02, alpha: 1))

            let vanishing = CGPoint(x: size.width * 0.5, y: size.height * 0.38)

            let ceiling = CGMutablePath()
            ceiling.move(to: CGPoint(x: 0, y: size.height * 0.02))
            ceiling.addLine(to: CGPoint(x: size.width, y: size.height * 0.02))
            ceiling.addLine(to: CGPoint(x: size.width * 0.66, y: vanishing.y))
            ceiling.addLine(to: CGPoint(x: size.width * 0.34, y: vanishing.y))
            ceiling.closeSubpath()
            cg.setFillColor(UIColor(red: 0.08, green: 0.09, blue: 0.11, alpha: 1).cgColor)
            cg.addPath(ceiling)
            cg.fillPath()

            let floor = CGMutablePath()
            floor.move(to: CGPoint(x: 0, y: size.height))
            floor.addLine(to: CGPoint(x: size.width, y: size.height))
            floor.addLine(to: CGPoint(x: size.width * 0.68, y: vanishing.y))
            floor.addLine(to: CGPoint(x: size.width * 0.32, y: vanishing.y))
            floor.closeSubpath()
            cg.setFillColor(UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1).cgColor)
            cg.addPath(floor)
            cg.fillPath()

            let leftWall = CGMutablePath()
            leftWall.move(to: CGPoint(x: 0, y: size.height * 0.02))
            leftWall.addLine(to: CGPoint(x: size.width * 0.34, y: vanishing.y))
            leftWall.addLine(to: CGPoint(x: size.width * 0.32, y: vanishing.y))
            leftWall.addLine(to: CGPoint(x: 0, y: size.height))
            leftWall.closeSubpath()
            cg.setFillColor(UIColor(red: 0.10, green: 0.11, blue: 0.14, alpha: 1).cgColor)
            cg.addPath(leftWall)
            cg.fillPath()

            let rightWall = CGMutablePath()
            rightWall.move(to: CGPoint(x: size.width, y: size.height * 0.02))
            rightWall.addLine(to: CGPoint(x: size.width * 0.66, y: vanishing.y))
            rightWall.addLine(to: CGPoint(x: size.width * 0.68, y: vanishing.y))
            rightWall.addLine(to: CGPoint(x: size.width, y: size.height))
            rightWall.closeSubpath()
            cg.setFillColor(UIColor(red: 0.09, green: 0.10, blue: 0.13, alpha: 1).cgColor)
            cg.addPath(rightWall)
            cg.fillPath()

            let corridor = CGMutablePath()
            corridor.move(to: CGPoint(x: size.width * 0.26, y: size.height * 0.98))
            corridor.addLine(to: CGPoint(x: size.width * 0.74, y: size.height * 0.98))
            corridor.addLine(to: CGPoint(x: size.width * 0.62, y: vanishing.y))
            corridor.addLine(to: CGPoint(x: size.width * 0.38, y: vanishing.y))
            corridor.closeSubpath()
            cg.setFillColor(UIColor(red: 0.12, green: 0.12, blue: 0.15, alpha: 1).cgColor)
            cg.addPath(corridor)
            cg.fillPath()

            cg.setStrokeColor(UIColor(white: 1, alpha: 0.08).cgColor)
            cg.setLineWidth(1)
            for row in 0..<14 {
                let t = CGFloat(row) / 13.0
                let y = vanishing.y + (size.height - vanishing.y) * t
                let inset = (1 - t) * size.width * 0.24
                cg.move(to: CGPoint(x: size.width * 0.5 - inset, y: y))
                cg.addLine(to: CGPoint(x: size.width * 0.5 + inset, y: y))
            }
            for col in -8...8 {
                let t = CGFloat(col) / 8.0
                cg.move(to: CGPoint(x: size.width * 0.5, y: size.height * 0.98))
                cg.addLine(to: CGPoint(x: size.width * 0.5 + t * size.width * 0.32, y: vanishing.y))
            }
            cg.strokePath()

            for i in 0..<6 {
                let t = CGFloat(i) / 5.0
                let w = size.width * (0.16 - t * 0.08)
                let h = 16 - t * 10
                let x = size.width * 0.5 - w * 0.5
                let y = size.height * 0.12 + t * size.height * 0.18
                let r = CGRect(x: x, y: y, width: w, height: max(4, h))
                cg.setFillColor(UIColor(red: 0.92, green: 0.92, blue: 0.74, alpha: 0.10 + t * 0.10).cgColor)
                cg.fill(r)
                cg.setFillColor(UIColor(red: 1, green: 1, blue: 0.88, alpha: 0.08 + t * 0.08).cgColor)
                cg.fill(r.insetBy(dx: 5, dy: 3))
            }

            let doorYPositions: [CGFloat] = [size.height * 0.26, size.height * 0.44, size.height * 0.64]
            for y in doorYPositions {
                drawDoorway(cg, rect: CGRect(x: size.width * 0.06, y: y, width: size.width * 0.16, height: 96), side: .left)
                drawDoorway(cg, rect: CGRect(x: size.width * 0.78, y: y, width: size.width * 0.16, height: 96), side: .right)
            }

            cg.setFillColor(UIColor(red: 0.14, green: 0.14, blue: 0.17, alpha: 1).cgColor)
            cg.fill(CGRect(x: size.width * 0.39, y: size.height * 0.03, width: size.width * 0.22, height: size.height * 0.18))
            cg.setFillColor(UIColor(red: 0.06, green: 0.06, blue: 0.07, alpha: 1).cgColor)
            cg.fill(CGRect(x: size.width * 0.42, y: size.height * 0.05, width: size.width * 0.16, height: size.height * 0.12))

            drawRadialVignette(cg, rect: CGRect(origin: .zero, size: size),
                               inner: UIColor.clear, outer: UIColor.black.withAlphaComponent(0.45))
        }
    }

    func enemyTexture(kind: Int) -> SKTexture {
        let size = CGSize(width: 220, height: 320)
        return imageTexture(size: size) { ctx in
            let cg = ctx.cgContext
            cg.clear(CGRect(origin: .zero, size: size))

            let skin = UIColor(red: 0.28, green: 0.20, blue: 0.18, alpha: 1)
            let jacketA = [UIColor(red: 0.16, green: 0.11, blue: 0.11, alpha: 1), UIColor(red: 0.06, green: 0.06, blue: 0.07, alpha: 1)]
            let jacketB = [UIColor(red: 0.20, green: 0.15, blue: 0.08, alpha: 1), UIColor(red: 0.08, green: 0.07, blue: 0.04, alpha: 1)]
            let jacket = kind % 2 == 0 ? jacketA : jacketB

            drawRadialVignette(cg, rect: CGRect(origin: .zero, size: size),
                               inner: UIColor.clear, outer: UIColor.black.withAlphaComponent(0.75))

            let torso = UIBezierPath(roundedRect: CGRect(x: 65, y: 116, width: 90, height: 130), cornerRadius: 12)
            drawLinearGradient(in: cg, rect: torso.bounds, colors: jacket)
            cg.addPath(torso.cgPath)
            cg.fillPath()

            let headRect = CGRect(x: 84, y: 42, width: 52, height: 62)
            let head = UIBezierPath(ovalIn: headRect)
            drawLinearGradient(in: cg, rect: headRect, colors: [UIColor(red: 0.42, green: 0.30, blue: 0.26, alpha: 1), skin])
            cg.addPath(head.cgPath)
            cg.fillPath()

            let hood = UIBezierPath(ovalIn: headRect.insetBy(dx: -6, dy: -4))
            cg.setFillColor(UIColor.black.withAlphaComponent(0.22).cgColor)
            cg.addPath(hood.cgPath)
            cg.fillPath()

            cg.setFillColor(UIColor.black.withAlphaComponent(0.45).cgColor)
            cg.fillEllipse(in: CGRect(x: 97, y: 62, width: 10, height: 4))
            cg.fillEllipse(in: CGRect(x: 113, y: 62, width: 10, height: 4))

            cg.setFillColor(UIColor(red: 0.05, green: 0.05, blue: 0.06, alpha: 1).cgColor)
            cg.fill(CGRect(x: 48, y: 142, width: 28, height: 18))
            cg.fill(CGRect(x: 144, y: 140, width: 30, height: 18))
            cg.fill(CGRect(x: 82, y: 170, width: 58, height: 10))
            cg.fill(CGRect(x: 128, y: 165, width: 50, height: 8))

            let pants = UIBezierPath(roundedRect: CGRect(x: 74, y: 220, width: 74, height: 70), cornerRadius: 10)
            drawLinearGradient(in: cg, rect: pants.bounds, colors: [UIColor(red: 0.06, green: 0.06, blue: 0.07, alpha: 1), UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)])
            cg.addPath(pants.cgPath)
            cg.fillPath()

            cg.setStrokeColor(UIColor(red: 1, green: 0.20, blue: 0.10, alpha: 0.25).cgColor)
            cg.setLineWidth(3)
            cg.strokeEllipse(in: CGRect(x: 52, y: 28, width: 116, height: 250))
        }
    }

    func hostageTexture() -> SKTexture {
        let size = CGSize(width: 210, height: 300)
        return imageTexture(size: size) { ctx in
            let cg = ctx.cgContext
            cg.clear(CGRect(origin: .zero, size: size))

            drawRadialVignette(cg, rect: CGRect(origin: .zero, size: size),
                               inner: UIColor.clear, outer: UIColor.black.withAlphaComponent(0.7))

            let shirt = UIBezierPath(roundedRect: CGRect(x: 70, y: 110, width: 70, height: 120), cornerRadius: 12)
            drawLinearGradient(in: cg, rect: shirt.bounds, colors: [UIColor(red: 0.12, green: 0.28, blue: 0.68, alpha: 1), UIColor(red: 0.24, green: 0.44, blue: 0.90, alpha: 1)])
            cg.addPath(shirt.cgPath)
            cg.fillPath()

            let headRect = CGRect(x: 84, y: 42, width: 42, height: 56)
            let head = UIBezierPath(ovalIn: headRect)
            drawLinearGradient(in: cg, rect: headRect, colors: [UIColor(red: 0.38, green: 0.30, blue: 0.28, alpha: 1), UIColor(red: 0.50, green: 0.38, blue: 0.34, alpha: 1)])
            cg.addPath(head.cgPath)
            cg.fillPath()

            cg.setFillColor(UIColor.white.withAlphaComponent(0.14).cgColor)
            cg.fillEllipse(in: CGRect(x: 82, y: 74, width: 46, height: 14))

            cg.setFillColor(UIColor(red: 0.26, green: 0.44, blue: 0.92, alpha: 1).cgColor)
            cg.fill(CGRect(x: 50, y: 98, width: 22, height: 58))
            cg.fill(CGRect(x: 138, y: 98, width: 22, height: 58))
            cg.setFillColor(UIColor(red: 0.42, green: 0.32, blue: 0.28, alpha: 1).cgColor)
            cg.fillEllipse(in: CGRect(x: 42, y: 88, width: 22, height: 22))
            cg.fillEllipse(in: CGRect(x: 146, y: 88, width: 22, height: 22))

            let pants = UIBezierPath(roundedRect: CGRect(x: 78, y: 220, width: 58, height: 60), cornerRadius: 10)
            drawLinearGradient(in: cg, rect: pants.bounds, colors: [UIColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1), UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1)])
            cg.addPath(pants.cgPath)
            cg.fillPath()

            cg.setStrokeColor(UIColor(red: 0.35, green: 0.70, blue: 1.0, alpha: 0.4).cgColor)
            cg.setLineWidth(3)
            cg.strokeEllipse(in: CGRect(x: 52, y: 28, width: 104, height: 246))
        }
    }

    func obstacleTexture(kind: Int) -> SKTexture {
        let size = CGSize(width: 200, height: 200)
        return imageTexture(size: size) { ctx in
            let cg = ctx.cgContext
            cg.clear(CGRect(origin: .zero, size: size))
            switch kind % 3 {
            case 0:
                let crate = UIBezierPath(roundedRect: CGRect(x: 26, y: 34, width: 148, height: 120), cornerRadius: 6)
                drawLinearGradient(in: cg, rect: crate.bounds, colors: [UIColor(red: 0.37, green: 0.27, blue: 0.16, alpha: 1), UIColor(red: 0.18, green: 0.12, blue: 0.06, alpha: 1)])
                cg.addPath(crate.cgPath)
                cg.fillPath()
                cg.setStrokeColor(UIColor(red: 0.78, green: 0.55, blue: 0.25, alpha: 0.55).cgColor)
                cg.setLineWidth(4)
                cg.stroke(crate.cgPath)
                cg.setStrokeColor(UIColor(red: 0.84, green: 0.62, blue: 0.32, alpha: 0.42).cgColor)
                cg.setLineWidth(3)
                cg.move(to: CGPoint(x: 26, y: 94)); cg.addLine(to: CGPoint(x: 174, y: 94))
                cg.move(to: CGPoint(x: 100, y: 34)); cg.addLine(to: CGPoint(x: 100, y: 154))
                cg.strokePath()
            case 1:
                let cabinet = UIBezierPath(roundedRect: CGRect(x: 52, y: 26, width: 100, height: 140), cornerRadius: 8)
                drawLinearGradient(in: cg, rect: cabinet.bounds, colors: [UIColor(red: 0.22, green: 0.24, blue: 0.28, alpha: 1), UIColor(red: 0.08, green: 0.09, blue: 0.11, alpha: 1)])
                cg.addPath(cabinet.cgPath)
                cg.fillPath()
                cg.setStrokeColor(UIColor(white: 1, alpha: 0.10).cgColor)
                cg.setLineWidth(3)
                cg.stroke(cabinet.cgPath)
                cg.setFillColor(UIColor.black.withAlphaComponent(0.4).cgColor)
                cg.fill(CGRect(x: 66, y: 46, width: 72, height: 16))
                cg.fill(CGRect(x: 66, y: 80, width: 72, height: 16))
                cg.fill(CGRect(x: 66, y: 114, width: 72, height: 16))
            default:
                let door = UIBezierPath(roundedRect: CGRect(x: 32, y: 18, width: 136, height: 156), cornerRadius: 4)
                drawLinearGradient(in: cg, rect: door.bounds, colors: [UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1), UIColor(red: 0.04, green: 0.04, blue: 0.05, alpha: 1)])
                cg.addPath(door.cgPath)
                cg.fillPath()
                cg.setStrokeColor(UIColor(red: 0.50, green: 0.50, blue: 0.55, alpha: 0.28).cgColor)
                cg.setLineWidth(4)
                cg.stroke(door.cgPath)
                cg.setFillColor(UIColor(red: 0.62, green: 0.62, blue: 0.68, alpha: 0.15).cgColor)
                cg.fill(CGRect(x: 46, y: 42, width: 108, height: 18))
                cg.fill(CGRect(x: 46, y: 108, width: 108, height: 18))
            }
        }
    }

    func bulletTexture() -> SKTexture {
        imageTexture(size: CGSize(width: 36, height: 36)) { ctx in
            let cg = ctx.cgContext
            let circle = CGRect(x: 7, y: 7, width: 22, height: 22)
            drawRadialVignette(cg, rect: CGRect(origin: .zero, size: circle.size),
                               inner: UIColor(red: 1, green: 1, blue: 0.65, alpha: 1),
                               outer: UIColor(red: 1, green: 0.85, blue: 0.20, alpha: 0.0))
            cg.setFillColor(UIColor(red: 1, green: 0.95, blue: 0.35, alpha: 1).cgColor)
            cg.fillEllipse(in: circle)
            cg.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
            cg.setLineWidth(2)
            cg.strokeEllipse(in: circle.insetBy(dx: 3, dy: 3))
        }
    }

    private enum DoorSide { case left, right }

    private func drawDoorway(_ cg: CGContext, rect: CGRect, side: DoorSide) {
        let frame = UIBezierPath(roundedRect: rect, cornerRadius: 6)
        drawLinearGradient(in: cg, rect: rect, colors: [UIColor(red: 0.16, green: 0.17, blue: 0.20, alpha: 1), UIColor(red: 0.05, green: 0.05, blue: 0.06, alpha: 1)])
        cg.addPath(frame.cgPath)
        cg.fillPath()

        cg.setStrokeColor(UIColor(red: 0.75, green: 0.75, blue: 0.80, alpha: 0.15).cgColor)
        cg.setLineWidth(4)
        cg.stroke(frame.cgPath)

        let opening = rect.insetBy(dx: rect.width * 0.18, dy: 14)
        cg.setFillColor(UIColor(red: 0.02, green: 0.02, blue: 0.03, alpha: 1).cgColor)
        cg.fill(opening)
        cg.setFillColor(UIColor(red: 0.15, green: 0.13, blue: 0.12, alpha: 1).cgColor)
        let trim = CGRect(x: opening.minX, y: opening.minY - 4, width: opening.width, height: 6)
        cg.fill(trim)

        if side == .left {
            cg.setFillColor(UIColor(red: 0.82, green: 0.55, blue: 0.30, alpha: 0.10).cgColor)
            cg.fill(CGRect(x: rect.maxX - 4, y: rect.minY + 8, width: 12, height: rect.height - 16))
        } else {
            cg.setFillColor(UIColor(red: 0.82, green: 0.55, blue: 0.30, alpha: 0.10).cgColor)
            cg.fill(CGRect(x: rect.minX - 8, y: rect.minY + 8, width: 12, height: rect.height - 16))
        }
    }

    private func imageTexture(size: CGSize, draw: (UIGraphicsImageRendererContext) -> Void) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            draw(context)
        }
        return SKTexture(image: image)
    }

    private func drawGradient(in cg: CGContext, rect: CGRect, top: UIColor, bottom: UIColor) {
        let colors = [top.cgColor, bottom.cgColor] as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0, 1]) else { return }
        cg.saveGState()
        cg.drawLinearGradient(gradient,
                              start: CGPoint(x: rect.midX, y: rect.minY),
                              end: CGPoint(x: rect.midX, y: rect.maxY),
                              options: [])
        cg.restoreGState()
    }

    private func drawLinearGradient(in cg: CGContext, rect: CGRect, colors: [UIColor]) {
        let gradientColors = colors.map { $0.cgColor } as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorsSpace: space, colors: gradientColors, locations: [0, 1]) else { return }
        cg.saveGState()
        cg.drawLinearGradient(gradient,
                              start: CGPoint(x: rect.minX, y: rect.minY),
                              end: CGPoint(x: rect.minX, y: rect.maxY),
                              options: [])
        cg.restoreGState()
    }

    private func drawRadialVignette(_ cg: CGContext, rect: CGRect, inner: UIColor, outer: UIColor) {
        let colors = [inner.cgColor, outer.cgColor] as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0, 1]) else { return }
        cg.saveGState()
        cg.drawRadialGradient(gradient,
                              startCenter: CGPoint(x: rect.midX, y: rect.midY),
                              startRadius: 0,
                              endCenter: CGPoint(x: rect.midX, y: rect.midY),
                              endRadius: max(rect.width, rect.height) * 0.65,
                              options: [])
        cg.restoreGState()
    }
}

final class GameScene: SKScene {
    weak var gameState: GameState?

    private let art = ArtFactory.shared

    private var cameraNode = SKCameraNode()
    private var backdropNode = SKSpriteNode()
    private var reticleNode = SKNode()

    private var joystickBase: SKShapeNode!
    private var joystickThumb: SKShapeNode!
    private var joystickOrigin = CGPoint.zero

    private var moveTouchID: UITouch?
    private var aimTouchID: UITouch?
    private var joystickVec = CGVector.zero
    private var isFiring = false
    private var lastFireTime: TimeInterval = 0
    private let fireInterval: TimeInterval = 0.16

    private var lastUpdateTime: TimeInterval = 0
    private var forwardProgress: CGFloat = 0
    private var cameraShift: CGFloat = 0
    private var missionAnnounced = false

    private var hallwayProps: [StaticPropActor] = []
    private var enemies: [EnemyActor] = []
    private var bullets: [BulletActor] = []
    private var hostage: StaticPropActor?

    private let visibleDepth: CGFloat = 2200

    override func didMove(to view: SKView) {
        removeAllChildren()
        backgroundColor = .black

        setupCamera()
        setupBackdrop()
        setupReticle()
        setupHUDControls()
        setupHallwaySetPieces()
        setupActors()
    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
    }

    private func setupBackdrop() {
        let texture = art.hallwayTexture(size: CGSize(width: 1536, height: 1536))
        backdropNode = SKSpriteNode(texture: texture)
        backdropNode.size = size
        backdropNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        backdropNode.zPosition = -100
        addChild(backdropNode)
    }

    private func setupHallwaySetPieces() {
        hallwayProps.removeAll()

        let propSpecs: [(CGFloat, CGFloat, Int, CGFloat)] = [
            (260, -0.70, 0, 0.80),
            (360,  0.72, 1, 0.78),
            (540, -0.58, 2, 0.85),
            (690,  0.56, 0, 0.82),
            (920, -0.44, 1, 0.90),
            (1110, 0.50, 2, 0.88),
            (1380, -0.62, 0, 0.96),
            (1560, 0.64, 1, 0.95),
            (1820, -0.10, 2, 1.15),
        ]

        for (depth, lane, kind, baseScale) in propSpecs {
            let node = SKSpriteNode(texture: art.obstacleTexture(kind: kind))
            node.zPosition = 0
            addChild(node)
            hallwayProps.append(StaticPropActor(node: node, depth: depth, lane: lane, baseScale: baseScale))
        }
    }

    private func setupActors() {
        enemies.removeAll()

        let enemySpecs: [(CGFloat, CGFloat, Int)] = [
            (340, -0.30, 0),
            (480,  0.35, 1),
            (620, -0.42, 2),
            (820,  0.22, 0),
            (980, -0.20, 1),
            (1200, 0.40, 2),
            (1450, -0.32, 0),
            (1670, 0.28, 1),
            (1920, 0.00, 2),
        ]

        for (depth, lane, kind) in enemySpecs {
            let node = SKSpriteNode(texture: art.enemyTexture(kind: kind))
            node.zPosition = 5
            addChild(node)
            enemies.append(EnemyActor(node: node, depth: depth, lane: lane, speed: 115 + CGFloat(kind) * 12, points: 25))
        }

        let hostageNode = SKSpriteNode(texture: art.hostageTexture())
        hostageNode.zPosition = 4
        addChild(hostageNode)
        hostage = StaticPropActor(node: hostageNode, depth: 1990, lane: 0.0, baseScale: 1.0)
    }

    private func setupReticle() {
        reticleNode.removeAllChildren()
        reticleNode.removeFromParent()
        reticleNode = SKNode()
        reticleNode.zPosition = 200
        camera?.addChild(reticleNode)

        let green = SKColor(red: 0.08, green: 0.95, blue: 0.25, alpha: 1)
        let dimGreen = SKColor(red: 0.08, green: 0.95, blue: 0.25, alpha: 0.30)

        let outer = SKShapeNode(circleOfRadius: 42)
        outer.strokeColor = dimGreen
        outer.lineWidth = 1.6
        outer.fillColor = .clear
        reticleNode.addChild(outer)

        let inner = SKShapeNode(circleOfRadius: 16)
        inner.strokeColor = SKColor(red: 0.08, green: 0.95, blue: 0.25, alpha: 0.45)
        inner.lineWidth = 1
        inner.fillColor = .clear
        reticleNode.addChild(inner)

        let dot = SKShapeNode(circleOfRadius: 2.5)
        dot.fillColor = green
        dot.strokeColor = .clear
        reticleNode.addChild(dot)

        let gap: CGFloat = 20
        let arm: CGFloat = 18
        let lines: [(CGPoint, CGPoint)] = [
            (CGPoint(x: 0, y: gap), CGPoint(x: 0, y: gap + arm)),
            (CGPoint(x: 0, y: -gap), CGPoint(x: 0, y: -(gap + arm))),
            (CGPoint(x: gap, y: 0), CGPoint(x: gap + arm, y: 0)),
            (CGPoint(x: -gap, y: 0), CGPoint(x: -(gap + arm), y: 0)),
        ]

        for (start, end) in lines {
            let path = CGMutablePath()
            path.move(to: start)
            path.addLine(to: end)
            let line = SKShapeNode(path: path)
            line.strokeColor = green
            line.lineWidth = 2
            line.lineCap = .round
            reticleNode.addChild(line)
        }

        for deg in stride(from: 0.0, to: 360.0, by: 45.0) {
            let r = CGFloat(deg) * .pi / 180
            let path = CGMutablePath()
            path.move(to: CGPoint(x: cos(r) * 44, y: sin(r) * 44))
            path.addLine(to: CGPoint(x: cos(r) * 56, y: sin(r) * 56))
            let tick = SKShapeNode(path: path)
            tick.strokeColor = dimGreen
            tick.lineWidth = 1
            reticleNode.addChild(tick)
        }

        for offset: CGFloat in [-64, 64] {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -8, y: offset))
            path.addLine(to: CGPoint(x: 8, y: offset))
            let stadia = SKShapeNode(path: path)
            stadia.strokeColor = dimGreen
            stadia.lineWidth = 1
            reticleNode.addChild(stadia)
        }
    }

    private func setupHUDControls() {
        guard let view else { return }
        let w = view.bounds.width
        let h = view.bounds.height

        joystickBase = SKShapeNode(circleOfRadius: 52)
        joystickBase.position = CGPoint(x: -w / 2 + 94, y: -h / 2 + 110)
        joystickBase.fillColor = SKColor(red: 0.06, green: 0.55, blue: 0.12, alpha: 0.12)
        joystickBase.strokeColor = SKColor(red: 0.10, green: 0.90, blue: 0.20, alpha: 0.25)
        joystickBase.lineWidth = 1.5
        joystickBase.zPosition = 100
        camera?.addChild(joystickBase)

        joystickThumb = SKShapeNode(circleOfRadius: 24)
        joystickThumb.position = joystickBase.position
        joystickThumb.fillColor = SKColor(red: 0.10, green: 0.90, blue: 0.22, alpha: 0.22)
        joystickThumb.strokeColor = SKColor(red: 0.10, green: 0.90, blue: 0.22, alpha: 0.65)
        joystickThumb.lineWidth = 1.5
        joystickThumb.zPosition = 101
        camera?.addChild(joystickThumb)

        let hint = SKLabelNode(text: "MOVE LEFT   AIM / FIRE RIGHT")
        hint.fontName = "Courier"
        hint.fontSize = 9
        hint.fontColor = SKColor(red: 0.15, green: 0.75, blue: 0.25, alpha: 0.28)
        hint.position = CGPoint(x: 0, y: -h / 2 + 16)
        hint.zPosition = 100
        camera?.addChild(hint)
    }

    override func update(_ currentTime: TimeInterval) {
        guard !(gameState?.isGameOver ?? false), !(gameState?.missionComplete ?? false) else { return }

        let dt = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 0.05)
        lastUpdateTime = currentTime

        if joystickVec != .zero {
            forwardProgress = (forwardProgress + joystickVec.dy * 260 * CGFloat(dt)).clamped(to: 0...2000)
            cameraShift = (cameraShift + joystickVec.dx * 220 * CGFloat(dt)).clamped(to: -180...180)
        }

        backdropNode.position = CGPoint(x: size.width * 0.5 + cameraShift * 0.05,
                                        y: size.height * 0.5 - forwardProgress * 0.01)

        projectEnvironment()
        updateEnemies(dt: dt)
        updateBullets(dt: dt)
        updateMissionState()

        if isFiring, currentTime - lastFireTime >= fireInterval {
            lastFireTime = currentTime
            fire()
        }
    }

    private func projectEnvironment() {
        for prop in hallwayProps {
            let projected = project(depth: prop.depth, lane: prop.lane)
            prop.node.position = projected.position
            prop.node.zPosition = projected.zPosition
            prop.node.setScale(projected.scale * prop.baseScale)
            prop.node.alpha = projected.alpha
        }

        if let hostage {
            let projected = project(depth: hostage.depth, lane: hostage.lane)
            hostage.node.position = projected.position
            hostage.node.zPosition = projected.zPosition - 1
            hostage.node.setScale(projected.scale * 1.06)
            hostage.node.alpha = projected.alpha
        }
    }

    private func updateEnemies(dt: TimeInterval) {
        for enemy in enemies where enemy.alive {
            enemy.depth = max(enemy.depth - enemy.speed * CGFloat(dt) * 0.18, forwardProgress + 40)
            let sway = sin(CGFloat(lastUpdateTime) * 2.2 + enemy.depth * 0.01) * 0.03
            let projected = project(depth: enemy.depth, lane: enemy.lane + sway)
            enemy.node.position = projected.position
            enemy.node.zPosition = projected.zPosition
            enemy.node.setScale(projected.scale)
            enemy.node.alpha = projected.alpha

            if enemy.depth - forwardProgress < 90 {
                enemy.alive = false
                enemy.node.removeFromParent()
                DispatchQueue.main.async { [weak self] in
                    self?.gameState?.takeDamage(20)
                }
            }
        }

        enemies.removeAll { !$0.alive }
    }

    private func updateBullets(dt: TimeInterval) {
        let reticle = reticleNode.position

        for bullet in bullets {
            bullet.node.position.x += bullet.velocity.dx * CGFloat(dt)
            bullet.node.position.y += bullet.velocity.dy * CGFloat(dt)
            bullet.life -= CGFloat(dt)

            for enemy in enemies where enemy.alive {
                let distance = hypot(bullet.node.position.x - enemy.node.position.x,
                                     bullet.node.position.y - enemy.node.position.y)
                if distance < 30 {
                    enemy.alive = false
                    enemy.node.removeFromParent()
                    bullet.life = 0
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.gameState?.addScore(enemy.points)
                    }
                    break
                }
            }

            if bullet.life <= 0 || abs(bullet.node.position.x) > size.width * 0.7 || abs(bullet.node.position.y) > size.height * 0.7 {
                bullet.node.removeFromParent()
            }

            if bullet.node.parent != nil {
                let dx = reticle.x - bullet.node.position.x
                let dy = reticle.y - bullet.node.position.y
                let length = max(1, hypot(dx, dy))
                bullet.node.zRotation = atan2(dy, dx)
                bullet.node.alpha = max(0.25, 1 - length / 450)
            }
        }

        bullets.removeAll { $0.life <= 0 || $0.node.parent == nil }
    }

    private func updateMissionState() {
        if !missionAnnounced, enemies.isEmpty, forwardProgress > 1500 {
            missionAnnounced = true
        }

        if missionAnnounced, let hostage, hostage.node.parent != nil {
            let target = project(depth: hostage.depth, lane: hostage.lane)
            let distance = hypot(reticleNode.position.x - target.position.x,
                                 reticleNode.position.y - target.position.y)
            if distance < 36 && forwardProgress > 1760 {
                hostage.node.removeFromParent()
                DispatchQueue.main.async { [weak self] in
                    self?.gameState?.rescueHostage()
                }
            }
        }
    }

    private func fire() {
        let muzzle = CGPoint(x: 0, y: -size.height * 0.18)
        let target = reticleNode.position
        let dx = target.x - muzzle.x
        let dy = target.y - muzzle.y
        let length = max(1, hypot(dx, dy))

        let bulletNode = SKSpriteNode(texture: art.bulletTexture())
        bulletNode.position = muzzle
        bulletNode.setScale(0.75)
        bulletNode.zPosition = 150
        camera?.addChild(bulletNode)

        let direction = CGVector(dx: dx / length, dy: dy / length)
        bullets.append(BulletActor(node: bulletNode, velocity: CGVector(dx: direction.dx * 980, dy: direction.dy * 980)))

        let flash = SKShapeNode(circleOfRadius: 10)
        flash.fillColor = SKColor(red: 1, green: 0.95, blue: 0.45, alpha: 0.9)
        flash.strokeColor = .clear
        flash.position = muzzle
        flash.zPosition = 151
        camera?.addChild(flash)
        flash.run(SKAction.sequence([.fadeOut(withDuration: 0.06), .removeFromParent()]))
    }

    private func project(depth: CGFloat, lane: CGFloat) -> (position: CGPoint, scale: CGFloat, zPosition: CGFloat, alpha: CGFloat) {
        let relative = max(0, depth - forwardProgress)
        let depthFactor = max(0.12, 1 - relative / visibleDepth)
        let scale = 0.22 + depthFactor * 1.15
        let centerX = size.width * 0.5 + cameraShift * 0.22
        let horizonY = size.height * 0.30
        let y = horizonY + depthFactor * size.height * 0.62
        let x = centerX + lane * size.width * 0.34 * depthFactor
        let alpha = 0.22 + depthFactor * 0.78
        let z = 10_000 - relative
        return (CGPoint(x: x, y: y), scale, z, alpha)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view else { return }
        for touch in touches {
            let loc = touch.location(in: view)
            if loc.x < view.bounds.width / 2 {
                if moveTouchID == nil {
                    moveTouchID = touch
                    joystickOrigin = touch.location(in: camera ?? self)
                    joystickBase.position = joystickOrigin
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
        let clampX = view.bounds.width * 0.5 - 18
        let clampY = view.bounds.height * 0.5 - 18

        for touch in touches {
            if touch == moveTouchID {
                let loc = touch.location(in: camera ?? self)
                let dx = loc.x - joystickOrigin.x
                let dy = loc.y - joystickOrigin.y
                let dist = hypot(dx, dy)
                let maxRadius: CGFloat = 44
                let nx = dist > maxRadius ? (dx / dist) * maxRadius : dx
                let ny = dist > maxRadius ? (dy / dist) * maxRadius : dy
                joystickThumb.position = CGPoint(x: joystickOrigin.x + nx, y: joystickOrigin.y + ny)
                let norm = dist > 0 ? min(dist / maxRadius, 1) : 0
                joystickVec = dist > 5 ? CGVector(dx: (nx / maxRadius) * norm, dy: (ny / maxRadius) * norm) : .zero
            }
            if touch == aimTouchID {
                let loc = touch.location(in: camera ?? self)
                reticleNode.position = CGPoint(
                    x: loc.x.clamped(to: -clampX...clampX),
                    y: loc.y.clamped(to: -clampY...clampY)
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

    override func willMove(from view: SKView) {
        removeAllActions()
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}