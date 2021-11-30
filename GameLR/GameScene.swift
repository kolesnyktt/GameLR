//
//  GameScene.swift
//  LRGame
//
//  Created by Taras Kolesnyk on 29.11.2021.
//


import SpriteKit
import GameplayKit
import Foundation

var maxLives = 3

//анимация
// генерация poison, bonus
// размер персонажа
// нужно ли добавлять больше bonus, poison?
// skaction wait
// jump

class LivesLabel: SKLabelNode {
    
     init(position: CGPoint) {
        super.init()
        self.text = "text"
        self.position = position
        self.fontName = "Helvetica"
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var lives: Int = 0 {
        didSet{
            self.text = "Lives: \(lives)"
        }
    }
}

class ScoreLabel: SKLabelNode {
    
     init(position: CGPoint) {
        super.init()
        self.text = "text"
        self.position = position
        self.fontName = "Helvetica"
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var score: Int = 0 {
        didSet{
            self.text = "Score: \(score)"
        }
    }
}

class BestScoreLabel: SKLabelNode {
    var bc = UserDefaults.standard.integer(forKey: "bestScore")
    
     init(position: CGPoint) {
        super.init()
        self.text = "Best Score: \(bc)"
        self.position = position
        self.fontName = "Helvetica"
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var bestscore: Int = 0 {
        didSet{
            self.text = "Best Score: \(bestscore)"
        }
    }
}

struct PhysicsBodies {
    
    static let poisonCategory: UInt32 = 1 << 1
    static let bonusCategory: UInt32 = 1 << 2
    static let floorCategory: UInt32 = 1 << 3
    static let playerCategory: UInt32 = 1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: Player!
    var bonus: Bonus!
    var floor: Floor!
    var poison: Poison!
    
    var livesLabel: LivesLabel!
    var scoreLabel: ScoreLabel!
    var bestScoreLabel: BestScoreLabel!
    
    var isFinish: Bool = false
    
    let playerPosition = 0
    
    var background = SKSpriteNode(imageNamed: "gameBackgroungImage")

    var score = 0
    var bestScore = 0
    
    var textureOfSprite = ""
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        putObj()
        startGame()
        poisonRandPos()
        bonusRandPos()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody, secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsBodies.bonusCategory) != 0 &&
            (secondBody.categoryBitMask & PhysicsBodies.playerCategory != 0)) {
            randomPosition(bonus)
            checkAndGiveScore()
        }
        
        if ((firstBody.categoryBitMask & PhysicsBodies.poisonCategory) != 0 &&
            (secondBody.categoryBitMask & PhysicsBodies.playerCategory != 0)) {
            livesLabel.lives -= 1
            if( livesLabel.lives == 0) {
                isFinish = true
                bestScore = UserDefaults.standard.integer(forKey: "bestScore")
                if (score > bestScore)
                {
                    UserDefaults.standard.set(score, forKey: "bestScore")
                    bestScoreLabel.bestscore = score
                }
                gameOver()
            } else {
                randomPosition(poison)
            }
        }
        
    }
  
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setGestures()
        if isFinish {
            startGame()
            isFinish = false
        }
        animationOfWalking()
        
        isMovingRight.toggle()
        player.xScale = -1 * player.xScale
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        let playerPosition = player.position.x

    }
    
    func randomPosition(_ obj: SKSpriteNode ) {
        var rand: CGFloat = 0
       
        while (rand > CGFloat(playerPosition) - 200 && rand < CGFloat(playerPosition) + 200) {
            rand = CGFloat.random(in: frame.minX...frame.maxX)
        }
        obj.removeFromParent()
    
        
        obj.position.x = rand
        if (obj == bonus) {
            textureOfSprite = bonus.choosenTexture
            bonus.changeTexture()
        }
        addChild(obj)
    }
    
    var isMovingRight = false {
        didSet {
            changeMovement()
        }
    }
    
    func changeMovement() {
        let checkAction = SKAction.run {
            if (self.player.position.x > self.frame.maxX ){
                self.isMovingRight = false
                self.player.xScale = 1
            }
            if (self.player.position.x < self.frame.minX) {
                self.isMovingRight = true
                self.player.xScale = -1
            }
            
        }
        if isMovingRight {
            player.removeAction(forKey: "right")
            let actionRight = SKAction.moveBy(x: 50, y: 0, duration: 0.2)
            let sqns = SKAction.sequence([
                actionRight,
                checkAction,
            ])
            let foreverAction = SKAction.repeatForever(sqns)
            player.run(foreverAction, withKey: "left")
        } else {
            player.removeAction(forKey: "left")
            let actionLeft = SKAction.moveBy(x: -50, y: 0, duration: 0.2)
            let sqns = SKAction.sequence([
                actionLeft,
                checkAction,
            ])
            let foreverAction = SKAction.repeatForever(sqns)
            player.run(foreverAction, withKey: "right")
        }
    }
    
    func startGame() {
        
        //addChild(player!)
        addChild(bonus!)
        addChild(poison!)
        player.position.x = 0
        player.texture = SKTexture(imageNamed: "startPositionPlayer")
        score = 0
        livesLabel.lives = 3
        scoreLabel.score = 0
        livesLabel.text = "Lives: \(maxLives)"
        scoreLabel.text = "Score: 0"
    }
    
    func gameOver() {
        player.position.x = 0
        player.run(SKAction.moveTo(x: 0, duration: 0.5))
        player.removeAction(forKey: "anim")
        player.texture = SKTexture(imageNamed: "startPositionPlayer")
        bonus.removeFromParent()
        poison.removeFromParent()
        player.removeAction(forKey: "right")
        player.removeAction(forKey: "left")
        livesLabel.text = "You die =("
    }
    
    func putObj() {
        background.zPosition = -1
        background.size = CGSize(width: frame.width, height: frame.height)
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)
        
        livesLabel = LivesLabel(position: CGPoint(x: -frame.maxX/2, y: frame.maxY/2))
        addChild(livesLabel!)
        
        scoreLabel = ScoreLabel(position: CGPoint(x: frame.maxX/2, y: frame.maxY/2))
        addChild(scoreLabel!)
        
        bestScoreLabel = BestScoreLabel(position: CGPoint(x: 0, y: frame.maxY/2))
        addChild(bestScoreLabel)
        
        player = Player()
        addChild(player!)
        player.position.x = 0
        player.position.y = 0
        
        bonus = Bonus()
        bonus.position.x = 100
        bonus.position.y = 0
        
        poison = Poison()
        poison.position.x = -100
        poison.position.y = 0
        
        floor = Floor(size: CGSize(width: frame.size.width + 500, height: 20))
        addChild(floor!)
        floor.position.x = 0
        floor.position.y = frame.minY + 0.5 * floor.size.height
    }
    
    func animationOfWalking() {
       
        let sequence = SKAction.sequence([
            SKAction.run {
                self.player?.texture = SKTexture(imageNamed: "goLeftImage")
            },
            SKAction.wait(forDuration: 0.3),
            SKAction.run {
                self.player?.texture = SKTexture(imageNamed: "goLeft2Image")
            },
            SKAction.wait(forDuration: 0.3)
        ])
        let act = SKAction.repeatForever(sequence)
        player.run(act, withKey: "anim")
    }
    
    func poisonRandPos() {
        let seq = SKAction.sequence([
            SKAction.run {
                self.poison.position.x = self.randomPosition1()
            },
            SKAction.wait(forDuration: 2)
        ])
        let act = SKAction.repeatForever(seq)
        poison.run(act, withKey: "poisonPos")
    }
    
    func bonusRandPos() {
        let seq = SKAction.sequence([
            SKAction.run {
                self.bonus.position.x = self.randomPosition1()
            },
            SKAction.wait(forDuration: 3.5)
        ])
        let act = SKAction.repeatForever(seq)
        bonus.run(act, withKey: "poisonPos")
    }

    
    func randomPosition1()-> CGFloat {
        var rand: CGFloat = 0
       
        while (rand > CGFloat(playerPosition) - 200 && rand < CGFloat(playerPosition) + 200) {
            rand = CGFloat.random(in: frame.minX...frame.maxX)
        }
        return rand
    }
    
    
    func bonusShowAndHide() {
//        let sequence = SKAction.sequence([
//            SKAction.run {
//                self.bonus?.position.x = ran
//            },
//            SKAction.wait(forDuration: 0.5),
//            SKAction.run {
//                self.player?.texture = SKTexture(imageNamed: "goLeft2Image")
//            },
//            SKAction.wait(forDuration: 0.5)
//        ])
//        let act = SKAction.repeatForever(sequence)
//        player.run(act, withKey: "anim")
    }
    
    
    
    func checkAndGiveScore() {
        var tmp = 0
        if (textureOfSprite == "coinImage")
        {
            tmp = 1
        }
        if (textureOfSprite == "bonusImage")
        {
            tmp = 3
        }
        if (textureOfSprite == "treasureImage")
        {
            tmp = 5
        }
        score += tmp
        scoreLabel.text = "Score: \(String(score))"
    }
    
    func setGestures() {
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        upSwipeGesture.direction = .up
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        rightSwipeGesture.direction = .right
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        leftSwipeGesture.direction = .left
        
        [upSwipeGesture, rightSwipeGesture, leftSwipeGesture].forEach { self.view?.addGestureRecognizer($0) }
    }
    
    @objc func swiped(recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .left:
            isMovingRight = false
            player.xScale = 1
        case .right:
            isMovingRight = true
            player.xScale = -1
        case .up:
            player.jump()
        default:
            print("other recogn")
        }
    }
}


