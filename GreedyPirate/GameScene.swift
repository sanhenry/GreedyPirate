//
//  GameScene.swift
//  GreedyPirate
//
//  Created by Shao-Han Tang on 12/14/15.
//  Copyright (c) 2015 GGGaming. All rights reserved.
//

import SpriteKit
let scaleFactor:Float = 2.0

class GameScene: SKScene, SKPhysicsContactDelegate{
    //constant
    let skyColor = SKColor(red: 0, green:191, blue:255, alpha:1)
    let scaleFactorCG = CGFloat(scaleFactor)
    
    //Node
    var bird:SKSpriteNode!
    var scrollNode = SKNode()
    var preBirdY = CGFloat(0.0)
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //setup background color
        self.backgroundColor = skyColor
        
        //setup world physic
        self.physicsWorld.gravity = CGVectorMake(0.0, -3.0)
        self.physicsWorld.contactDelegate = self
        
        //setup sprites
        self.bird = setupBird()
        self.addChild(self.bird)
        self.setupGround()
        self.setupSkyline()
        self.addChild(scrollNode)
        
    }
    
    func setupBird() ->SKSpriteNode{
        // Fetch the image from bird1.png texture
        let birdTexture1 = SKTexture(imageNamed: "Bird1")
        birdTexture1.filteringMode   = .Nearest
        
        //Create our sprite node from texture
        let bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(self.scaleFactorCG)
        bird.position = CGPoint(x: self.frame.size.width * 0.4,
            y: self.frame.size.height * 0.4)
        bird.physicsBody = SKPhysicsBody(rectangleOfSize: bird.size)
        bird.physicsBody?.dynamic = true
        
        //print("frame width %d",self.frame.size.width)
        //print("frame height %d", self.frame.size.height)
        self.preBirdY = bird.position.y
        return bird
    }
    
    func setupGround(){
        //Set Texture
        let groundTexture = SKTexture(imageNamed: "Ground")
        groundTexture.filteringMode = .Nearest

        //Add helper variables
        let groundTextureSize   = groundTexture.size();
        let groundTextureWidth  = groundTextureSize.width
        
        //Add the SKActions that will allow the ground to move and reset
        //so it will appear to scorll indefinitely
        let moveGroundSprite    = SKAction.moveByX(-groundTextureWidth * scaleFactorCG, y: 0,  duration: NSTimeInterval(0.005 * groundTextureWidth * scaleFactorCG))
        let resetGroundSprite   = SKAction.moveByX(groundTextureWidth * scaleFactorCG, y: 0, duration: 0)
        let moveGroundSpriteForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        //Here we add some code to add enough ground sprites to
        //the scolling node depending on the width of the device
        for (var i:CGFloat = 0; i < 20.0 + self.frame.size.width / (groundTextureWidth * scaleFactorCG); ++i){
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(scaleFactorCG)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0)
            sprite.runAction(moveGroundSpriteForever)
            self.scrollNode.addChild(sprite)
        }


    }
    
    func setupSkyline(){
        //Set Texture
        let skyTexture  = SKTexture(imageNamed: "Skyline")
        let groundTexture   = SKTexture(imageNamed: "Ground")
        //Add helper variale
        let skyTextureWidth = skyTexture.size().width
        //let skyTextureHeight    = skyTexture.size().height
        let groundTextureHeight = groundTexture.size().height
        //skyline action
        let moveSkySprite   = SKAction.moveByX(-skyTextureWidth * scaleFactorCG, y: 0, duration: NSTimeInterval(0.025 * skyTextureWidth * scaleFactorCG))
        let resetSkySprite  = SKAction.moveByX(skyTextureWidth * scaleFactorCG, y: 0, duration: NSTimeInterval(0.0))
        let moveSkySpriteForever    = SKAction.repeatActionForever(SKAction.sequence([moveSkySprite, resetSkySprite]))
        skyTexture.filteringMode    = .Nearest
        
        for(var i:CGFloat = 0; i < 6.0 + self.frame.size.width / (skyTextureWidth * scaleFactorCG); ++i){
            let sprite = SKSpriteNode(texture: skyTexture)
            sprite.setScale(scaleFactorCG)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0 + groundTextureHeight * scaleFactorCG)
            sprite.zPosition    = -20
            sprite.runAction(moveSkySpriteForever)
            self.scrollNode.addChild(sprite)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.bird.physicsBody?.velocity = CGVectorMake(0, 0)
        self.bird.physicsBody?.applyImpulse(CGVectorMake(0, 20))
        
        //when touch, the speed increase and then decrease to normal
        let increaseScrollSpeed = SKAction.speedTo(3.0, duration: NSTimeInterval(0.01))
        let resetScrollSpeed = SKAction.speedTo(1.0, duration: NSTimeInterval(0.5))
        let scrollSpeedSequence = SKAction.sequence([increaseScrollSpeed, resetScrollSpeed])
        self.scrollNode.runAction(scrollSpeedSequence)
        
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let resizeScaleFactor = CGFloat(0.66)
        if(bird.position.y >= frame.size.height * 3.0 / 4.0 && preBirdY < frame.size.height * 3.0 / 4.0 )
        {
            let rescaleAction = SKAction.scaleBy(resizeScaleFactor, duration: NSTimeInterval(0.5))
            self.scrollNode.runAction(rescaleAction)
            self.bird.runAction(rescaleAction)
        }
        else if(bird.position.y < frame.size.height * 3.0 / 4.0 && preBirdY >= frame.size.height * 3.0 / 4.0)
        {
            let rescaleAction = SKAction.scaleBy(1/resizeScaleFactor, duration: NSTimeInterval(0.5))
            self.scrollNode.runAction(rescaleAction)
            self.bird.runAction(rescaleAction)
        }
        
        preBirdY = bird.position.y
    }
    
    
}
