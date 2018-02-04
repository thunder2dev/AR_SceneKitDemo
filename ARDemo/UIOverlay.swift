//
//  UIOverlay.swift
//  ARDemo
//
//  Created by n01192 on 7/14/17.
//  Copyright © 2017 test. All rights reserved.
//


import SceneKit
import SpriteKit

class UIOverlay: SKScene {
    private var overlayNode: SKNode
    
    
    public var controlOverlay: ControlOverlay?
    
    init(size: CGSize, controller: GameController) {
        overlayNode = SKNode()
        super.init(size: size)
        
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        
        
        scaleMode = .resizeFill
        
        addChild(overlayNode)
        overlayNode.position = CGPoint(x: 0.0, y: h)
        
        controlOverlay = ControlOverlay(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: w, height: h))
        controlOverlay!.leftPad.delegate = controller
        controlOverlay!.rightPad.delegate = controller
        controlOverlay!.buttonA.delegate = controller
        controlOverlay!.buttonB.delegate = controller
        controlOverlay!.buttonStart.delegate = controller
        addChild(controlOverlay!)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




