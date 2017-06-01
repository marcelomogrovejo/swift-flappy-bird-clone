//
//  GameScene.swift
//  FlappyBirdClone
//
//  Created by Marcelo Mogrovejo on 6/1/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: Properties
    
    // Objects that appear in the screen
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    
    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    var gameOver = false
    var scoreLabel = SKLabelNode()
    var score = 0
    var gameOverLabel = SKLabelNode()
    var timer = Timer()
    
    // Like a viewDidLoad
    override func didMove(to view: SKView) {

        self.physicsWorld.contactDelegate = self
        
        setupGame()

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false {
            bird.physicsBody?.isDynamic = true
        
            // Velocity
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
            // Impulse
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
        } else {
            gameOver = false
            
            score = 0
            
            self.speed = 1
            
            self.removeAllChildren()
            
            setupGame()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    // MARK: SKPhysicsContactDelegate metods
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameOver == false {
            
            // TODO: check why score is sticked somethimes
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
                print("Add one to score")
            
                score += 1
            } else {
                print("We have contact")
            
                // Stop the game
                self.speed = 0
                gameOver = true
                
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 40
                gameOverLabel.text = "Game Over! Tap to play again."
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                
                self.addChild(gameOverLabel)
                
                timer.invalidate()
            }
        
            scoreLabel.text = String(score)
        }
    }
    
    // MARK: Private methods
    
    func setupGame() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        // Create a background
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        // Create animation that move the background
        let moveBgAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 5)
        let shiftBgAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        let makeBgMove = SKAction.repeatForever(SKAction.sequence([moveBgAnimation, shiftBgAnimation]))
        
        // Avoid lacks of backgounds
        var i: CGFloat = 0
        
        while i < 3 {
            
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            bg.zPosition = -2
            bg.run(makeBgMove)
            
            self.addChild(bg)
            
            i += 1
        }
        
        // Create a bird
        let birdTexture1 = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        // Create an animation that mixes both images in timePerFrame (The duration, in seconds, that each texture is displayed)
        let animation = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        // Execute the animation
        bird.run(makeBirdFlap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture1.size().height / 2)
        bird.physicsBody?.isDynamic = false
        
        self.addChild(bird)
        
        // Collision Detection
        bird.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody?.collisionBitMask = ColliderType.Bird.rawValue
        
        // Create a ground as an invisible barrier
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody?.isDynamic = false
        
        self.addChild(ground)
        
        // Collision Detection
        ground.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        // Create the score text
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        
        self.addChild(scoreLabel)

    }
    
    func makePipes() {
        // Add pipes left movement
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        // Define the gap between the pipes
        let gapHeight = bird.size.height * 4
        
        // Add the pipes muvement up and down effect
        let movementAmmount = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffset = CGFloat(movementAmmount) - self.frame.height / 4
        
        // Create the first pipe from top
        let pipe1Texture = SKTexture(imageNamed: "pipe1.png")
        pipe1 = SKSpriteNode(texture: pipe1Texture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipe1Texture.size().height / 2 + gapHeight / 2 + pipeOffset)
        pipe1.run(moveAndRemovePipes)
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipe1Texture.size())
        pipe1.physicsBody?.isDynamic = false
        
        pipe1.zPosition = -1
        
        self.addChild(pipe1)
        
        // Collision Detection
        pipe1.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        // Create the secound pipe from bottom
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipe2Texture.size().height / 2 - gapHeight / 2 + pipeOffset)
        pipe2.run(moveAndRemovePipes)
        
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2Texture.size())
        pipe2.physicsBody?.isDynamic = false
        
        pipe2.zPosition = -1
        
        self.addChild(pipe2)

        // Collision Detection
        pipe2.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        // Create a gap between pipes to get the score
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe1Texture.size().width, height: gapHeight))
        gap.physicsBody?.isDynamic = false
        gap.run(moveAndRemovePipes)
        
        // Detect contact between the Gap and the Bird
        gap.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody?.collisionBitMask = ColliderType.Gap.rawValue
        
        self.addChild(gap)

    }
}
