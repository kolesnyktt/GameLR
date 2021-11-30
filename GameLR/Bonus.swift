import SpriteKit

class Bonus: SKSpriteNode {
    var arrayTexture = ["treasureImage", "coinImage", "bonusImage"]
    var choosenTexture = ""

    init() {
        let bonusSize = CGSize(width: 70, height: 70)
        super.init(texture: nil, color: .red, size: bonusSize)
        self.texture = SKTexture(imageNamed: arrayTexture.randomElement()!)
        //self.texture = SKTexture(imageNamed: "bonusImage")
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.node?.zPosition = 1
        self.physicsBody?.categoryBitMask = PhysicsBodies.bonusCategory
        self.physicsBody?.contactTestBitMask = PhysicsBodies.playerCategory
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeTexture() {
        choosenTexture = arrayTexture.randomElement()!
        print("choosenTexture ", choosenTexture)
        
        self.texture = SKTexture(imageNamed: choosenTexture)
    }
}
