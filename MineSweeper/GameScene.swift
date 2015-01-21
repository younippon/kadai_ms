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
    
    //color
    let bgColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    let squareColorEven = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    let squareColorOdd = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    let squareBorderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    let mineBrendColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    let flagBrendColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
    let textBgColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    
    //numbers
    let rows = 9
    let cols = 6
    let mineNum = 10
    
    //sizes and margins
    //let fieldSize = 320.0
    var squareFrameSize:CGFloat = 320.0
    let squareScaleRatio:CGFloat = 2.0
    let squareImageScaleRatio:CGFloat = 2.0
    
    let marginButtom:CGFloat = 0.0
    
    //parameter
    var phase = Phase.GetReady
    //var score = 0
    var openCount = 0
    var beganSquareSet:Array<SKNode> = [] //long pressed node
    
    //timer
    let longPressSec = 0.7
    var timer : NSTimeInterval = -1
    var lastUpdateTime : NSTimeInterval = 0
    
    //gesture flag
    var longPress:Bool = false
    
    //square set
    var squareNode:Array<MSSquareSpriteNode> = []
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = bgColor
        getReady()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        switch phase {
        case .Game:
            setBeganSquare(touches)
        default:
            println("touch began")
        }
        println("touch began")
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
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
        println("touch Ended")
        
    }
   
    func retry() {
        resetGame()
        getReady()
    }
    
    func resetGame() {
        openCount = 0
        //score = 0
        resetSquare()
    }
    
    func resetSquare() {
        squareNode = []
        var nodeArray = self.children
        var i:NSInteger = 0
        
        while i < nodeArray.count {
            nodeArray[i].removeFromParent()
            i++
        }
    }
    
    func openAllSquare() {
        
        var i:NSInteger = 0
        while i < squareNode.count {
            squareNode[i].removeFromParent()
            i++
        }
    }
    
    func getReady() {
        let minePosition = getMinePosition() //mine pos array
        addSquares(minePosition)
        
        setLogoimage()
        
        phase = Phase.GetReady

    }
    
    func setLogoimage() {
        
        let centerPoint = CGPoint(x: self.size.width / 2.0, y: self.size.height / 2.0)
        
        var textBg = SKSpriteNode(color: textBgColor, size: CGSizeMake(self.size.width, 120.0))
        textBg.position = centerPoint
        textBg.zPosition = 2.0
        textBg.name = "logoBg"
        addChild(textBg)
        
        var titleLogo = SKSpriteNode(imageNamed: "logo.png")
        let logoSizeFixed = self.size.width / 1800.0
        titleLogo.xScale =  logoSizeFixed
        titleLogo.yScale =  logoSizeFixed
        titleLogo.position = centerPoint
        titleLogo.zPosition = 3.0
        titleLogo.name = "logo"
        addChild(titleLogo)
    }
    
    func deleteLogoimage() {
        self.enumerateChildNodesWithName("logo") {
            node, stop in
            node.removeFromParent()
        }
        self.enumerateChildNodesWithName("logoBg") {
            node, stop in
            self.closeTextBgAnimation(node)
            //node.removeFromParent()
        }
    }
    
    func start() {
        deleteLogoimage()
        phase = Phase.Game
        
    }
    
    func addSquares(minePosition: Array<NSInteger>) {
        
        setSquareSize()
        
        for i in 0...rows - 1 {
            for j in 0...cols - 1 {
                
                let squareType = getSquareType(minePosition, xPos:j, yPos:i)
                setSquareImage(squareFrameSize, type:squareType, r:i, c:j)
                setSquare(squareFrameSize, type:squareType, r:i, c:j)
                
            }
        }
        
    }
        
    func setSquareSize() {
        squareFrameSize = self.size.width / CGFloat(cols)
    }
    
    func getSquareType (position:Array<NSInteger>, xPos:NSInteger, yPos:NSInteger) -> NSInteger {
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
    
    func setSquareNum(row:NSInteger, col:NSInteger) -> NSInteger {
        return cols * row + col
    }
    
    func setSquareImage(size:CGFloat, type: NSInteger, r:NSInteger, c:NSInteger) {
        
        let imageName = getSquareImageName(type)
        var square = SKSpriteNode(imageNamed: imageName)
        
        setSquareParam(square, color: mineBrendColor, r: r, c: c, zPos: 0.5, brend:CGFloat(type) / 10.0)
        
        addChild(square)
    
    }
    
    func setSquare (size:CGFloat, type: NSInteger, r:NSInteger, c:NSInteger) {
        
        let color = getSquareColor(squareNode.count + 1)
        var square = MSSquareSpriteNode(imageNamed: "square.png")
        
        setSquareParam(square, color: color, r: r, c: c, zPos: 1.0, brend:1.0)
        
        square.name = "Square"
        square.row = r
        square.col = c
        square.type = type
        
        squareNode.append(square)
        addChild(square)

    }
    
    func setSquareParam(square:SKSpriteNode, color:UIColor, r:NSInteger, c:NSInteger, zPos:CGFloat, brend:CGFloat) {
        
        square.xScale = squareScaleRatio / CGFloat(cols)
        square.yScale = squareScaleRatio / CGFloat(cols)
        square.color = color
        square.colorBlendFactor = brend
        square.position = getSquarePosition(square, size:squareFrameSize, xPos:c, yPos:r)
        square.zPosition = zPos
    }
    
    func getSquareColor(num:NSInteger) -> UIColor {
        
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
    
    func getSquarePosition(square:SKSpriteNode, size:CGFloat, xPos:NSInteger, yPos:NSInteger) -> CGPoint {
        
        let x:CGFloat = size * (CGFloat(xPos) + 1.0) - size / 2.0
        let y:CGFloat = self.size.height / 2.0 - CGFloat(yPos - (rows - 1) / 2) * size + marginButtom
        let point = CGPoint(x: x, y: y)
        println(xPos, yPos, x, y)
        
        return point
    }
    
    func getSquareImageName(type:NSInteger) -> NSString {
        switch type {
        case 0:
            return "mine.png"
        case 9:
            return "mine.png"
        default:
            return NSString(format: "%d.png", type)
        }
    }
    
    func getMinePosition() -> Array<Int> {
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
        if(timer > longPressSec){
            longPress = true
            timer = -1.0
            println("long press flag")
        }else if(timer >= 0.0){
            let timeSinceLast:CFTimeInterval = currentTime - lastUpdateTime
            timer += timeSinceLast
            println(timer)
        }
        lastUpdateTime = currentTime
    }
    
    func gameAction (touches: NSSet) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            openSquareAction(location)
            
        }
    }
    
    func openSquareAction (location: CGPoint) {
        let node:SKNode = nodeAtPoint(location)
        if(node.name == "Square"){

            var spriteNode = node as MSSquareSpriteNode
            
            //タップ中に指の位置が移動
            let n = find(beganSquareSet, node)
            if(n == nil){
                longPress = false
                return
            }
            
            let num:NSInteger = find(squareNode, spriteNode)!
            let type:NSInteger = squareNode[num].type
            
            timer = -1.0
            
            if(longPress){
                protectSquare(num, node: spriteNode)
            }else if(!spriteNode.protect){
                openSquare(spriteNode)
                beganSquareSet.removeAtIndex(n!)
                gameClearChecker()
            }else{
                println("protected")
            }
        }
        longPress = false
    }
    
    func protectSquare(n:NSInteger, node:MSSquareSpriteNode) {
        if(node.protect){
            node.color = getSquareColor(n)
            println("cancel")
        }else{
            node.color = flagBrendColor
            println("protect")
        }
        node.changeProtect()
    }
    
    func openSquare (node:MSSquareSpriteNode) {
        
        if(node.type == 9){
            node.removeFromParent()
            phase = Phase.GameOver
            openAllSquare()
            println("gameover")
        }else{
            openSafeSquare(node)
        }
    }

    func openSafeSquare (node:MSSquareSpriteNode) {
        if(!node.protect && !node.opened){
            
            openCount += 1
            node.opened = true
            node.removeFromParent()
            println(openCount)
            
            if(node.type == 0){
                neighborChecker(node)
            }
            
        }
    }
    
    func neighborChecker(node:MSSquareSpriteNode) {
        
        let nodeX:NSInteger = node.col
        let nodeY:NSInteger = node.row
        println(nodeX, nodeY)
    
        for i in -1...1 {
            for j in -1...1 {
                if(i != 0 || j != 0){
                    var neighberNum = getNeighborNum(nodeX + j, yPos: nodeY + i)
                    neighberAction(neighberNum)
                }
            }
        }
        
    }
    
    func getNeighborNum(xPos:NSInteger, yPos:NSInteger) -> NSInteger {
        if(xPos >= 0 && yPos >= 0 && xPos < cols && yPos < rows){
            return setSquareNum(yPos, col: xPos)
        }
        return -1
    }
    
    func neighberAction(num:NSInteger) {
        
        if(num != -1){
            let type = squareNode[num].type
            if(type != 9){
                openSafeSquare(squareNode[num])
            }
        }
    }
    
    func gameClearChecker () {
        if(openCount >= rows * cols - mineNum) {
            phase = Phase.GameClear
            openAllSquare()
            println("clear")
            println(openCount)
        }
    }
    
    func setBeganSquare(touches:NSSet) {
        beganSquareSet = []
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node:SKNode = nodeAtPoint(location)
            if(node.name == "Square"){
                beganSquareSet.append(node)
                println(node.name)
                startTimer()
            }
            
        }
    }
    
    func startTimer() {
        timer = 0.0
    }
    
    //animation
    
    func closeTextBgAnimation(square:SKNode) {
        let close = SKAction.scaleYTo(0.0, duration: 0.3)
        close.timingMode = SKActionTimingMode.EaseOut
        square.runAction(close)
    }
    
}
