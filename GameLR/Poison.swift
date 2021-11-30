import SpriteKit

class Poison: SKSpriteNode {

    init() {
        let poisonSize = CGSize(width: 60, height: 70)
        super.init(texture: nil, color: .red, size: poisonSize)
        self.texture = SKTexture(imageNamed: "poisonImage")
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.node?.zPosition = 1
        self.physicsBody?.categoryBitMask = PhysicsBodies.poisonCategory
        self.physicsBody?.contactTestBitMask = PhysicsBodies.playerCategory
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
