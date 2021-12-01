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

// treasure scale repeat
// пропадает и уменш bonus
// 2-3 бонус(функция)
// poison анимация
// размер персонажа коеф
// нужно ли добавлять больше bonus, poison?
// skaction wait(для poison и bonus)
// установить wait после bonus.remove
// jump(лимит)
// баг при первом контакте с bonus
// переход в коде

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
    //    enum без t/f
    
    var player: Player!
//    var bonus: Bonus!
    var poison: Poison!
    
    var livesLabel: LivesLabel!
    var scoreLabel: ScoreLabel!
    var bestScoreLabel: BestScoreLabel!
    
    var isFinish: Bool = true
    var isPlaying: Bool = false
    
    var playerPosition: CGFloat = 0 //to do
    
    var background = SKSpriteNode(imageNamed: "gameBackgroungImage")
    
    var score = 0
    var bestScore = 0
    
    var textureOfSprite = ""
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        putObj()
        //startGame()
//        poisonRandPos()
//        bonusRandPos()
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
            firstBody.node?.removeFromParent()
            //firstBody.node?.physicsBody = nil
            //firstBody.node?.isHidden = true
            
            // to do
            checkAndGiveScore()
            //randomPosition(bonus)
            
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
        //checkAndGiveScore()
        // enum
        setGestures() // to do
        
        if isFinish {
            startGame()
            isFinish = false
            generateBonus()
            generatePoison()
            
            
        }
        animationOfWalking()
        
        isMovingRight.toggle()
        player.xScale = -1 * player.xScale
        
    }
    var tmp = 0
    override func update(_ currentTime: TimeInterval) {
        playerPosition = player.position.x
        tmp += 1
        //spawnBonus()
        if (tmp == 100) {
           // spawnBonus()
            tmp = 0
        }
        //spawnBonus()
        
    }
    
    var isMovingRight = false {
        didSet {
            changeMovement()
        }
    }
    
    // запихнуть в Player
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
        isPlaying = true
        
        //addChild(player!)
       // addChild(bonus!)
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

        removeAllActions()
        //removeAllChildren()
        player.position.x = 0
        player.run(SKAction.moveTo(x: 0, duration: 0.5))
        player.removeAction(forKey: "anim")
        player.texture = SKTexture(imageNamed: "startPositionPlayer")
       // bonus.removeFromParent()
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
        
//        bonus = Bonus()
//        bonus.position.x = 100
//        bonus.position.y = 0
        
        poison = Poison()
        //poison.position.x = -100
        //poison.position.y = 0
        
        var floor: Floor!
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
            SKAction.wait(forDuration: 0.25),
            SKAction.run {
                self.player?.texture = SKTexture(imageNamed: "goLeft2Image")
            },
            SKAction.wait(forDuration: 0.25)
        ])
        let act = SKAction.repeatForever(sequence)
        player.run(act, withKey: "anim")
    }
    
    func spawnBonus()-> SKSpriteNode {
        let bonus1: Bonus!
        bonus1 = Bonus()
        bonus1!.position.x = randomPosition1()
        bonus1!.position.y = 0
        addChild(bonus1!)
        return bonus1
    }
    
    func generateBonus() {
        
        let waitAct = SKAction.wait(forDuration: 2)
        let spawnAct = SKAction.run {
            self.spawnBonus()
        }
        let forev = SKAction.sequence([waitAct, spawnAct])
        let rep = SKAction.repeatForever(forev)
        self.run(rep)
    }
    
    func scaleObj(_ obj: SKSpriteNode) {
        var a:CGFloat = 1
        let waitAct = SKAction.wait(forDuration: 1)
        let spawnAct = SKAction.run {
            while (a > 0) {
                obj.setScale(a)
                
                a -= 0.1
                
                print(a)
                //self.run(act)
            }
        }
        let forev = SKAction.sequence([waitAct, spawnAct])
        let rep = SKAction.repeatForever(forev)
        self.run(rep)
    }
    
    func generatePoison() {
        //scaleObj(poison)
        let waitAct1 = SKAction.wait(forDuration: 4)
        let spawnAct1 = SKAction.run {
            self.poison.position.x = self.randomPosition1()
            self.poison.position.y = self.frame.maxY
        }
        let forev1 = SKAction.sequence([waitAct1, spawnAct1])
        let rep1 = SKAction.repeatForever(forev1)
        self.run(rep1)
    }
    
    
    
//
//
//    func poisonRandPos() {
//        //        let seq = SKAction.sequence([
//        //            SKAction.run {
//        //                self.poison.position.x = self.randomPosition1()
//        //            },
//        //            SKAction.wait(forDuration: 3)
//        //        ])
//        //        let act = SKAction.repeatForever(seq)
//        //        //remove with key
//        //        poison.run(act, withKey: "poisonPos")
//    }
//
//    func bonusRandPos() {
//        //        let seq = SKAction.sequence([
//        //            SKAction.run {
//        //                self.bonus.position.x = self.randomPosition1()
//        //            },
//        //            SKAction.wait(forDuration: 3.5)
//        //        ])
//        //        let act = SKAction.repeatForever(seq)
//        //        bonus.run(act, withKey: "poisonPos")
//    }
    
    func randomPosition(_ obj: SKSpriteNode ) {
        //        obj.removeFromParent()
        //        obj.run(SKAction.wait(forDuration: 1))
        //        obj.position.x = randomPosition1()
        //        if (obj == bonus) {
        //            textureOfSprite = bonus.choosenTexture
        //            bonus.changeTexture()
        //        }
        //        addChild(obj)
    }
    
    func randomPosition1()-> CGFloat {
        var rand: CGFloat = 0
        while (rand > CGFloat(playerPosition) - 2 * player.size.width && rand < CGFloat(playerPosition) + 2 * player.size.width) {
            rand = CGFloat.random(in: frame.minX...frame.maxX)
        }
        
        return rand
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


