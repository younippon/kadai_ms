//
//  MSSquareSpriteNode.swift
//  MineSweeper
//
//  Created by 佐々木 耀 on 2015/01/21.
//  Copyright (c) 2015年 佐々木 耀. All rights reserved.
//

import SpriteKit

class MSSquareSpriteNode: SKSpriteNode {
 
    var row:NSInteger = 0
    var col:NSInteger = 0
    var type:NSInteger = 0
    var protect:Bool = false
    var opened:Bool = false
    
    func changeProtect() {
        protect = !protect
    }
    
}
