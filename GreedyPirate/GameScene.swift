//
//  GameScene.swift
//  GreedyPirate
//
//  Created by Shao-Han Tang on 12/14/15.
//  Copyright (c) 2015 GGGaming. All rights reserved.
//

import SpriteKit
let scaleFactor:Float = 2.0

let pirateCat:UInt32    = 1 << 0
let oceanCat:UInt32     = 1 << 1
let skyCat:UInt32       = 1 << 2
let jellyFishCat:UInt32 = 1 << 3
let birdCat:UInt32      = 1 << 4
let coinCat:UInt32      = 1 << 5


class GameScene: SKScene, SKPhysicsContactDelegate{
    
    //parameter structure of launching the pirate
    struct LaunchingParameter{
        var verticalImpulse: CGFloat = 0.0
        var horizontalSpeed: CGFloat = 0.0
    }
    
    //constant
    let skyColor = SKColor(red: 0, green:191, blue:255, alpha:1)
    let scaleFactorCG = CGFloat(scaleFactor)
    
    //Node
    var pirateSprite:SKSpriteNode!
    var scrollNode  = SKNode()
    var skyNode     = SKNode()
    var jellyFishNode = SKNode()
    var birdNode      = SKNode()
    var coinNode      = SKNode()
    
    //game control variable
    var isZoomOut   = false
    var coinCnt     = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //setup background color
        self.backgroundColor = skyColor
        
        //setup world physic
        self.physicsWorld.gravity = CGVectorMake(0.0, -3.0)
        self.physicsWorld.contactDelegate = self
        
        //setup sprites
        self.pirateSprite = setupPirate()
        self.addChild(self.pirateSprite)
        self.setupOcean()
        self.setupSkyline()
        self.spwanJellyFish()
        self.spwanCoin()
        self.addChild(self.scrollNode)
        self.addChild(self.skyNode)
    }
    
    func setupPirate() ->SKSpriteNode{
        // Fetch the image from bird1.png texture
        let pirateTexture1 = SKTexture(imageNamed: "Bird1")
        pirateTexture1.filteringMode   = .Nearest
        
        //Create our sprite node from texture
        let pirate = SKSpriteNode(texture: pirateTexture1)
        pirate.setScale(self.scaleFactorCG)
        pirate.position = CGPoint(x: self.frame.size.width * 0.4,
            y: self.frame.size.height * 0.4)
        pirate.physicsBody = SKPhysicsBody(rectangleOfSize: pirate.size)
        pirate.physicsBody?.dynamic = true
        pirate.physicsBody?.allowsRotation    = false
        pirate.physicsBody?.categoryBitMask    = pirateCat
        pirate.physicsBody?.collisionBitMask   = oceanCat|skyCat|jellyFishCat
        pirate.physicsBody?.contactTestBitMask = oceanCat|skyCat|jellyFishCat
        return pirate
    }
    
    func setupOcean(){
        //Set Texture
        let oceanTexture = SKTexture(imageNamed: "Ground")
        oceanTexture.filteringMode = .Nearest

        //Add helper variables
        let oceanTextureSize   = oceanTexture.size();
        let oceanTextureWidth  = oceanTextureSize.width
        //let oceanTextureHeight = oceanTextureSize.height
        
        //Add the SKActions that will allow the ground to move and reset
        //so it will appear to scorll indefinitely
        let moveOceanSprite    = SKAction.moveByX(-oceanTextureWidth * scaleFactorCG, y: 0,  duration: NSTimeInterval(0.005 * oceanTextureWidth * scaleFactorCG))
        let resetOceanSprite   = SKAction.moveByX(oceanTextureWidth * scaleFactorCG, y: 0, duration: 0)
        let moveOceanSpriteForever = SKAction.repeatActionForever(SKAction.sequence([moveOceanSprite, resetOceanSprite]))
        
        //Here we add some code to add enough ocean sprites to
        //the scolling node depending on the width of the device
        for (var i:CGFloat = 0; i < 20.0 + self.frame.size.width / (oceanTextureWidth * scaleFactorCG); ++i){
            let oceanSprite = SKSpriteNode(texture: oceanTexture)
            oceanSprite.setScale(scaleFactorCG)
            oceanSprite.position = CGPointMake(i * oceanSprite.size.width, oceanSprite.size.height / 2.0)
            oceanSprite.zPosition = -10
            oceanSprite.physicsBody = SKPhysicsBody(rectangleOfSize: oceanSprite.size)
            oceanSprite.physicsBody?.dynamic    = false
            oceanSprite.physicsBody?.categoryBitMask    = oceanCat
            oceanSprite.physicsBody?.contactTestBitMask = pirateCat

            oceanSprite.runAction(moveOceanSpriteForever)
            self.scrollNode.addChild(oceanSprite)
        }

    }
    
    func setupSkyline(){
        //Set Texture
        let skyTexture  = SKTexture(imageNamed: "Skyline")
        let oceanTexture   = SKTexture(imageNamed: "Ground")
        //Add helper variale
        let skyTextureWidth = skyTexture.size().width
        //let skyTextureHeight    = skyTexture.size().height
        let oceanTextureHeight = oceanTexture.size().height
        //skyline action
        let moveSkySprite   = SKAction.moveByX(-skyTextureWidth * scaleFactorCG, y: 0, duration: NSTimeInterval(0.025 * skyTextureWidth * scaleFactorCG))
        let resetSkySprite  = SKAction.moveByX(skyTextureWidth * scaleFactorCG, y: 0, duration: NSTimeInterval(0.0))
        let moveSkySpriteForever    = SKAction.repeatActionForever(SKAction.sequence([moveSkySprite, resetSkySprite]))
        skyTexture.filteringMode    = .Nearest
        
        for(var i:CGFloat = 0; i < 6.0 + self.frame.size.width / (skyTextureWidth * scaleFactorCG); ++i){
            let sprite = SKSpriteNode(texture: skyTexture)
            sprite.setScale(scaleFactorCG)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0 + oceanTextureHeight * scaleFactorCG)
            sprite.zPosition    = -20
            sprite.runAction(moveSkySpriteForever)
            self.scrollNode.addChild(sprite)
        }
        
        self.skyNode.position    = CGPointMake(0, self.frame.size.height - scaleFactorCG)
        self.skyNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, scaleFactorCG))
        self.skyNode.physicsBody?.dynamic    = false
        self.skyNode.physicsBody?.categoryBitMask    = skyCat
        self.skyNode.physicsBody?.contactTestBitMask = pirateCat
    }
    
    func setupJellyFish(){
        //set jelly fish texture
        let jellyFishTexture    = SKTexture(imageNamed: "jellyfish")
        let oceanTexture        = SKTexture(imageNamed: "Ground")
        
        let jellyFishTextureWidth = jellyFishTexture.size().width
        let oceanTextureHeight = oceanTexture.size().height
        
        //setup action
        let distanceToMove = self.frame.size.width * 2.0 + jellyFishTextureWidth * scaleFactorCG
        let moveJellyFish = SKAction.moveByX(-distanceToMove, y: 0, duration: NSTimeInterval(0.005 * distanceToMove))
        let removeJellyFish = SKAction.removeFromParent()
        let moveAndRemove = SKAction.sequence([moveJellyFish, removeJellyFish])
        
        //setup jelly fish sprite
        let jellyFishSprite = SKSpriteNode(texture: jellyFishTexture)
        jellyFishSprite.setScale(scaleFactorCG)
        jellyFishSprite.position = CGPointMake(distanceToMove, oceanTextureHeight * scaleFactorCG)
        jellyFishSprite.physicsBody = SKPhysicsBody(rectangleOfSize: jellyFishSprite.size)
        jellyFishSprite.physicsBody?.dynamic = false
        jellyFishSprite.physicsBody?.categoryBitMask = jellyFishCat
        jellyFishSprite.physicsBody?.contactTestBitMask = pirateCat
        
        jellyFishSprite.runAction(moveAndRemove)
        
        self.scrollNode.addChild(jellyFishSprite)
        
    }
    
    func spwanJellyFish(){
        // spwan a jelly fish every 1.8 second
        //todo: how to spawn Jelly Fish?
        let spwan = SKAction.performSelector("setupJellyFish", onTarget: self)
        let delaySpawn = SKAction.waitForDuration(1.8)
        let spwanThenDelay = SKAction.sequence([spwan, delaySpawn])
        let spwanThenDelayForever = SKAction.repeatActionForever(spwanThenDelay)
        self.runAction(spwanThenDelayForever)
    }
    
    func setupCoin(){
        //set coin fish texture
        let coinTexture    = SKTexture(imageNamed: "coin")
        let oceanTexture        = SKTexture(imageNamed: "Ground")
        
        let coinTextureWidth = coinTexture.size().width
        let oceanTextureHeight = oceanTexture.size().height
        
        //setup action
        let distanceToMove = self.frame.size.width * 2.0 + coinTextureWidth * scaleFactorCG
        let moveCoin = SKAction.moveByX(-distanceToMove, y: 0, duration: NSTimeInterval(0.005 * distanceToMove))
        let removeCoin = SKAction.removeFromParent()
        let moveAndRemove = SKAction.sequence([moveCoin, removeCoin])
        
        //setup coin sprite
        let coinSprite = SKSpriteNode(texture: coinTexture)
        coinSprite.setScale(scaleFactorCG)
        coinSprite.position = CGPointMake(distanceToMove, oceanTextureHeight * scaleFactorCG * 2.0)
        coinSprite.physicsBody = SKPhysicsBody(rectangleOfSize: coinSprite.size)
        coinSprite.physicsBody?.dynamic = false
        coinSprite.physicsBody?.categoryBitMask = coinCat
        coinSprite.physicsBody?.contactTestBitMask = pirateCat
        
        coinSprite.runAction(moveAndRemove)
        
        self.scrollNode.addChild(coinSprite)
        
    }
    
    func spwanCoin(){
        // spwan coins every 1.8 second
        //todo: how to spawn coins?
        let spwan = SKAction.performSelector("setupCoin", onTarget: self)
        let delaySpawn = SKAction.waitForDuration(0.5)
        let spwanThenDelay = SKAction.sequence([spwan, delaySpawn])
        let spwanThenDelayForever = SKAction.repeatActionForever(spwanThenDelay)
        self.runAction(spwanThenDelayForever)
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.launchPirate(LaunchingParameter(verticalImpulse: 15.0, horizontalSpeed: 4.0))
        
    }
    
    func launchPirate (lp : LaunchingParameter){
        self.pirateSprite.physicsBody?.velocity = CGVectorMake(0, 0)
        self.pirateSprite.physicsBody?.applyImpulse(CGVectorMake(0, lp.verticalImpulse))
        
        //when touch, the speed increase and then decrease to normal
        let increaseScrollSpeed = SKAction.speedTo(lp.horizontalSpeed, duration: NSTimeInterval(0.01))
        let resetScrollSpeed = SKAction.speedTo(1.0, duration: NSTimeInterval(0.5))
        let scrollSpeedSequence = SKAction.sequence([increaseScrollSpeed, resetScrollSpeed])
        self.scrollNode.runAction(scrollSpeedSequence)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let resizeScaleFactor = CGFloat(0.60)
        //Zoom out the scene when pirate fly too height
        if(self.pirateSprite.position.y >= frame.size.height * 3.0 / 4.0 && self.isZoomOut == false )
        {
            let rescaleAction = SKAction.scaleBy(resizeScaleFactor, duration: NSTimeInterval(0.5))
            self.scrollNode.runAction(rescaleAction)
            self.pirateSprite.runAction(rescaleAction)
            self.isZoomOut = true
        }
        //zoom in back to normal scene when pirate drop down
        else if(self.pirateSprite.position.y < frame.size.height * 1.0 / 4.0 && self.isZoomOut == true)
        {
            // Add time delay to make better visual effect
            let delayScaleAction = SKAction.waitForDuration(0.5)
            let rescaleAction = SKAction.scaleBy(1/resizeScaleFactor, duration: NSTimeInterval(1.0))
            let delayThenRescale = SKAction.sequence([delayScaleAction, rescaleAction])
            self.scrollNode.runAction(delayThenRescale)
            self.pirateSprite.runAction(delayThenRescale)
            self.isZoomOut = false
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        //check contact type by the contact body bitmask
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch(contactMask)
        {
/*
        case pirateCat|oceanCat:
            self.launchPirate(LaunchingParameter(verticalImpulse: 5.0, horizontalSpeed: 1.0))
*/
        case pirateCat|jellyFishCat:
            self.launchPirate(LaunchingParameter(verticalImpulse: 15.0, horizontalSpeed: 1.0))
        default:
            return
        }
    }
    
}
