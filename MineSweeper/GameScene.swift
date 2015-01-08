//
//  GameScene.swift
//  MineSweeper
//
//  Created by 佐々木 耀 on 2014/12/29.
//  Copyright (c) 2014年 佐々木 耀. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    let rows = 5
    let cols = 5
    let mineNum = 5
    
    let myLabel = SKLabelNode(fontNamed:"HelveticaNeue")
    
    let areaEven = UIColor(red: 207.0 / 255.0, green: 216.0 / 255.0, blue: 220.0 / 255.0, alpha: 1)
    let areaOdd = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
    var playScene = false
    var mineNumArray: Array<Int> = []
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        myLabel.text = "MINE SWEEPER"
        myLabel.fontSize = 36;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMaxY(self.frame) - 90.0);
        myLabel.name = "-1"
        self.addChild(myLabel)
        mineNumArray = setMineNum()
        addAreaBlocks()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            
            if (!playScene){
                playScene = !playScene
                myLabel.text = "START!"
                return
            }
            
            let location = touch.locationInNode(self)
            let node:SKNode = nodeAtPoint(location)
            println(node.name)
            let touchNum = node.name?.toInt()
            if (find(mineNumArray, touchNum!) != nil){
                myLabel.text = "GAMEOVER"
                playScene = !playScene
                println("don!")
            }
            if (node.alpha > 0.5) {
                node.alpha = 0.5
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func addAreaBlocks(){
        let blockSize: CGFloat = 86.25//self.frame.size.width / CGFloat(cols * 3)
        
        var y: CGFloat = 240.0
        for i in 0...rows - 1{
            var x: CGFloat = blockSize / 2.0 - blockSize * CGFloat(cols) / 2.0 + self.frame.size.width / 2.0
            for j in 0...cols - 1{
                var block = newAreaBlock(CGFloat(blockSize), blockColorId: Int(i+j))
                block.position = CGPointMake(x, y)
                block.name = String(cols * i + j)
                println(block.name)
                x += blockSize
            }
            y += blockSize
        }
    }

    func setMineNum() -> Array<Int> {
        
        let areaNum:UInt32 = UInt32(cols * rows)
        var randArray:Array<Int> = []
        
        while randArray.count <= mineNum {
            let randNum = Int(arc4random() % areaNum)
            if (find(randArray, randNum) == nil) {
                randArray.append(randNum)
            }
        }
        println(randArray)
        return randArray
    }
    
    func newAreaBlock(blockSize: CGFloat, blockColorId: Int) -> SKSpriteNode {
        var blockColor: UIColor
        if(blockColorId % 2 == 0){
            blockColor = areaEven
        }else{
            blockColor = areaOdd
        }
        var block = SKSpriteNode(color: blockColor, size: CGSize(width: blockSize, height: blockSize))
        addChild(block)
        return block
    }
    
}
