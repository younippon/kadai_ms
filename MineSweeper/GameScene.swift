//
//  GameScene.swift
//  MineSweeper
//
//  Created by 佐々木 耀 on 2014/12/29.
//  Copyright (c) 2014年 佐々木 耀. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    enum Phase{
        case GetReady, Game, GameOver, GameClear
    }
    
    //colors
    let bgColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    let squareColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    let squareBorderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    let mineBrendColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    let flagBrendColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
    
    //numbers
    let rows = 5
    let cols = 5
    let mineNum = 1
    
    //sizes and margins
    let fieldSize = 320.0
    var squareFrameSize:CGFloat = 86.0
    let marginButtom:CGFloat = 120.0
    
    //parameter
    var phase = Phase.GetReady
    var score = 0
    var openCount = 0
    var timer : NSTimeInterval = 0
    
    //square type set
    var squareTypeArray:Array<NSInteger> = []
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = bgColor
        getReady()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        switch phase {
        case .GetReady:
            start()
        case .Game:
            gameAction(touches)
        case .GameClear:
            retry()
        case .GameOver:
            retry()
        default:
            println("touch Ended")
        }
        
    }
   
    func retry() {
        score = 0
        resetSquare()
        
        getReady()
    }
    
    func resetSquare() {
        
    }
    
    func getReady() {
        let minePosition = setMinePosition()
        addSquares(minePosition)
        
        
        phase = Phase.GetReady

    }
    
    func start() {
        phase = Phase.Game
    }
    
    func addSquares(minePosition: Array<NSInteger>) {
        let squareSize = setSquareSize()
        
        for i in 0...rows - 1 {
            for j in 0...cols - 1 {
                
                let n = setSquareNum(i, col: j)
                let squareType = setSquareType(minePosition, xPos:j, yPos:i)
                
                var square = addSquare(squareSize, type:squareType)
                square.name = NSString(format: "%d", n)
                square.position = setSquarePosition(square, size:squareSize, xPos:j, yPos:i)
                squareTypeArray.append(squareType)
                //addChild(square)
            }
        }
        
    }
    
    func setSquareNum(row:NSInteger, col:NSInteger) -> NSInteger {
        return cols * row + col
    }
    
    func setSquareSize() -> CGFloat {
        squareFrameSize = 430.0 / CGFloat(cols)
        let squareSize = squareFrameSize//fieldSize / Double(rows)
        return CGFloat(squareSize)
    }
    
    func setSquareType (position:Array<NSInteger>, xPos:NSInteger, yPos:NSInteger) -> NSInteger {
        var neighborMineNum = 0
        
        for i in 0...position.count - 1 {
            let mineX:NSInteger = position[i] % cols
            let mineY:NSInteger = position[i] / cols
            
            if(setSquareNum(yPos, col: xPos) == position[i]){
                return 9
            }else if(abs(mineX - xPos) <= 1 && abs(mineY - yPos) <= 1){
                neighborMineNum += 1
            }
        }
        return neighborMineNum
    }
    
    func addSquare(size:CGFloat, type: NSInteger) -> SKSpriteNode {
        
        let imageName = setSquareImageName(type)
        
        var square = SKSpriteNode(imageNamed: imageName)
        
        square.xScale = squareFrameSize / (CGFloat(rows) * 2.0)
        square.yScale = squareFrameSize / (CGFloat(rows) * 2.0)
        //square.name = NSString(format: "%d", type)
        square.color = mineBrendColor
        square.colorBlendFactor = CGFloat(type) / 10.0
        
        addChild(square)
        
        return square
        
    }
    
    func setSquarePosition(square:SKSpriteNode, size:CGFloat, xPos:NSInteger, yPos:NSInteger) -> CGPoint {
        
        let x:CGFloat = size * (CGFloat(xPos) + 1.0) + self.frame.size.width / 4.0
        let y:CGFloat = self.frame.size.height / 2.0 - CGFloat(yPos) * size + marginButtom
        let point = CGPoint(x: x, y: y)
        println(xPos, yPos, x, y)
        
        return point
    }
    
    func setSquareImageName(type:NSInteger) -> NSString {
        switch type {
        case 0:
            return "mine.png"
        case 9:
            return "mine.png"
        default:
            return NSString(format: "%d.png", type)
        }
    }
    
    func setMinePosition() -> Array<Int> {
        let squareNum:UInt32 = UInt32(cols * rows)
        var randArray:Array<Int> = []
        
        while randArray.count < mineNum {
            let randNum = Int(arc4random() % squareNum)
            if (find(randArray, randNum) == nil) {
                randArray.append(randNum)
            }
        }
        println(randArray)
        
        return randArray
    }
    
    //game action
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func gameAction (touches: NSSet) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            openSquare(location)
        }
    }
    
    func openSquare (location: CGPoint) {
        let node:SKNode = nodeAtPoint(location)
        let nodeName:String = node.name!
        let type = squareTypeArray[nodeName.toInt()!]
        
        openSquareAction(type, node:node)
        gameClearChecker()
        
    }
    
    func openSquareAction (type:NSInteger, node:SKNode) {
        if(type == 0){
            //todo:複数開く
            node.alpha = 0.0
            openCount += 1
        }else if(type == 9){
            phase = Phase.GameOver
            println("gameover")
        }else{
            //todo:１つ開く
            node.alpha = 0.0
            openCount += 1
        }
    }
    
    func gameClearChecker (){
        if(openCount >= rows * cols - mineNum) {
            phase = Phase.GameClear
            println("clear")
        }
    }
}
