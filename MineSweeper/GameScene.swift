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
    let squareColorEven = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    let squareColorOdd = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    let squareBorderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    let mineBrendColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    let flagBrendColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
    
    //numbers
    let rows = 13
    let cols = 8
    let mineNum = 20
    
    //sizes and margins
    //let fieldSize = 320.0
    var squareFrameSize:CGFloat = 320.0
    let marginButtom:CGFloat = 0.0
    
    //parameter
    var phase = Phase.GetReady
    var score = 0
    var openCount = 0
    //var timer : NSTimeInterval = 0
    
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
        resetGame()
        
        getReady()
    }
    
    func resetGame() {
        openCount = 0
        score = 0
        resetSquare()
    }
    
    func resetSquare() {
        var nodeArray = self.children
        var i:NSInteger = 0
        
        while i < nodeArray.count {
            nodeArray[i].removeFromParent()
            i++
        }
    }
    
    func getReady() {
        let minePosition = setMinePosition()
        addSquares(minePosition)
        
        setLogoimage()
        
        phase = Phase.GetReady

    }
    
    func setLogoimage() {
        var titleLogo = SKSpriteNode(imageNamed: "logo.png")
        let logoSizeFixed = self.size.width / 1920.0
        titleLogo.xScale =  logoSizeFixed
        titleLogo.yScale =  logoSizeFixed
        titleLogo.position = CGPoint(x: self.size.width / 2.0, y: self.size.height / 2.0)
        //addChild(titleLogo)
    }
    
    func start() {
        
        phase = Phase.Game
    }
    
    func addSquares(minePosition: Array<NSInteger>) {
        let squareSize = setSquareSize()
        squareTypeArray = []
        for i in 0...rows - 1 {
            for j in 0...cols - 1 {
                
                let n = setSquareNum(i, col: j)
                let squareType = setSquareType(minePosition, xPos:j, yPos:i)
                squareTypeArray.append(squareType)
                
                var squareImage = setSquareImage(squareSize, type:squareType)
                squareImage.position = setSquarePosition(squareImage, size:squareSize, xPos:j, yPos:i)
                
                var square = setSquare(squareSize, type:squareType, num:n)
                square.name = NSString(format: "%d", n)
                square.position = setSquarePosition(square, size:squareSize, xPos:j, yPos:i)
                
            }
        }
        
    }
    
    func setSquareNum(row:NSInteger, col:NSInteger) -> NSInteger {
        return cols * row + col
    }
    
    func setSquareSize() -> CGFloat {
        squareFrameSize = self.size.width / CGFloat(cols)
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
    
    func setSquareImage(size:CGFloat, type: NSInteger) -> SKSpriteNode {
        
        let imageName = setSquareImageName(type)
        
        var square = SKSpriteNode(imageNamed: imageName)
        
        square.xScale = 2.0 / CGFloat(cols)
        square.yScale = 2.0 / CGFloat(cols)
        //square.name = NSString(format: "%d", type)
        square.color = mineBrendColor
        square.colorBlendFactor = CGFloat(type) / 10.0
        
        addChild(square)
        
        return square
    
    }
    
    func setSquare (size:CGFloat, type: NSInteger, num:NSInteger) -> SKSpriteNode {
        
        var color = setSquareColor(num)
        var square = SKSpriteNode(color: color, size: CGSizeMake(size, size))
        addChild(square)
        return square
    }
    
    func setSquareColor(num:NSInteger) -> UIColor {
        
        if(num % 2 == 1 && cols % 2 == 1){
            return squareColorEven
        }
        
        let row:NSInteger = num / cols
        if(cols % 2 == 0 && (
            (row % 2 == 0 && num % 2 == 0) || (row % 2 == 1 && num % 2 == 1) )){
            return squareColorEven
        }
        
        return squareColorOdd
    }
    
    func setSquarePosition(square:SKSpriteNode, size:CGFloat, xPos:NSInteger, yPos:NSInteger) -> CGPoint {
        
        let x:CGFloat = size * (CGFloat(xPos) + 1.0) - size / 2.0
        let y:CGFloat = self.size.height / 2.0 - CGFloat(yPos - (rows - 1) / 2) * size + marginButtom
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
        if(node.name != nil){
            let nodeName:String = node.name!
            let type = squareTypeArray[nodeName.toInt()!]
            openSquareAction(type, node:node)
            
            gameClearChecker()
        }
    }
    
    func openSquareAction (type:NSInteger, node:SKNode) {
        if(type == 9){
            node.removeFromParent()
            phase = Phase.GameOver
            println("gameover")
        }else{
            openSafeSquare(type, node: node)
        }
    }

    func openSafeSquare (type:NSInteger, node:SKNode) {
        node.removeFromParent()
        if(type == 0){
            neighborChecker(node)
        }
        openCount += 1
    }
    
    func neighborChecker(node:SKNode) {
        
        let nodeName:String = node.name!
        let num = nodeName.toInt()!
        let nodeX:NSInteger = num % cols
        let nodeY:NSInteger = num / cols
        
        for i in -1...1 {
            for j in -1...1 {
                if(i != 0 || j != 0){
                    var neighberNum = setNeighborNum(nodeX + j, yPos: nodeY + i)
                    neighberAction(neighberNum)
                    
                }
            }
        }
        
    }
    
    func setNeighborNum(xPos:NSInteger, yPos:NSInteger) -> NSInteger {
        if(xPos >= 0 && yPos >= 0 && xPos < cols && yPos < rows){
            return setSquareNum(yPos, col: xPos)
        }
        return -1
    }
    
    func neighberAction(num:NSInteger) {
        if(num != -1){
            var nodeName = String(num)
            println(nodeName)
            self.enumerateChildNodesWithName(nodeName) {
                node, stop in
                let type = self.squareTypeArray[num]
                if(type != 9){
                    self.openSafeSquare(type, node: node)
                }
            }
        }
    }
    
    func gameClearChecker (){
        if(openCount >= rows * cols - mineNum) {
            phase = Phase.GameClear
            println("clear")
        }
    }
}
