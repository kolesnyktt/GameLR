
import SpriteKit


class Player: SKSpriteNode {

    init() {
        let playerSize = CGSize(width: 90, height: 130)
        super.init(texture: SKTexture(imageNamed: "startPositionPlayer"), color: .yellow, size: playerSize)

        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.node?.zPosition = 1
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsBodies.playerCategory
        self.physicsBody?.contactTestBitMask = PhysicsBodies.bonusCategory

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func jump() {
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 400))
    }
}
