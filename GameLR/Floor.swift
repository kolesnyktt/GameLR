import SpriteKit

class Floor: SKSpriteNode {
    
    init(size: CGSize) {

        super.init(texture: nil, color: .clear, size: size)
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsBodies.floorCategory
        self.physicsBody?.contactTestBitMask = PhysicsBodies.playerCategory
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
