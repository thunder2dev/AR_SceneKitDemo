//
//  GameController.swift
//  ARDemo
//
//  Created by n01192 on 7/14/17.
//  Copyright © 2017 test. All rights reserved.
//

import ARKit
import SceneKit

struct Bitmask: OptionSet {
    let rawValue: Int
    static let character = Bitmask(rawValue: 1 << 0)
    static let collision = Bitmask(rawValue: 1 << 1)
    static let enemy = Bitmask(rawValue: 1 << 2)
    static let trigger = Bitmask(rawValue: 1 << 3)
    static let collectable = Bitmask(rawValue: 1 << 4)
}

class GameController: NSObject, SCNSceneRendererDelegate , SCNPhysicsContactDelegate,
                        PadOverlayDelegate, ButtonOverlayDelegate, MARDelegate{
    
    private var scene: SCNScene?
    public var arCtrl: ARController?
    
    private var sceneNode: SCNNode?
    private var character: Character?
    
    
    private weak var sceneRenderer: SCNSceneRenderer?
    private weak var arView: ARSCNView?
    
    private var overlay: UIOverlay?
    
    
    var characterDirection: vector_float2 {
        get {
            return character!.direction
        }
        set {
            var direction = newValue
            let l = simd_length(direction)
            if l > 1.0 {
                direction *= 1 / l
            }
            character!.direction = direction
        }
    }
    
    init(scnView: ARSCNView){
        super.init()
        sceneRenderer = scnView
        sceneRenderer?.delegate = self
        
        arView = scnView
        
        overlay = UIOverlay(size: scnView.bounds.size, controller: self)
        scnView.overlaySKScene = overlay
        overlay!.controlOverlay!.initLayout()
        
        arCtrl = ARController(scnView)
        arCtrl!.delegate = self
        arCtrl!.gameController = self
        
    }
    
    func initGame(){
    
        setupScene()
        setupPhysics()
        setupCharacter()
    
    
    }
    
    
    
    func startAR(){
        
        arCtrl!.start()
    }
    
    func firstAnchorAdded(_ node: SCNNode, _ anchor: ARPlaneAnchor){
        
        print("first anchor loaded anchor center:\(anchor.center)")
        overlay!.controlOverlay!.waitStartLayout()

    }
    
    
    func setupCharacter() {
        character = Character()
        
        character!.node.scale = SCNVector3Uniform(0.3 as CGFloat)
        character!.node.position = sceneNode!.position
        // keep a pointer to the physicsWorld from the character because we will need it when updating the character's position
        character!.physicsWorld = scene!.physicsWorld
        arView!.scene.rootNode.addChildNode(character!.node)
    }
    
    
    func setupScene(){
        
        guard arCtrl!.isFirstAnchorAdded else {
            return
        }
        
        let screenCenter = arView?.bounds.mid
        
        let (worldPos, _, _) = arCtrl!.worldPositionFromScreenPosition(screenCenter!, objectPos: nil)
        
        scene = SCNScene(named: "art.scnassets/GameScene.scn")
        
        sceneNode = SCNNode()
        
        for child in (scene?.rootNode.childNodes)! {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            child.movabilityHint = .movable
            sceneNode!.addChildNode(child)
            print("child pos:\(child.position)")
        }
        
        //mmmm = wrapperNode
        sceneNode!.scale = SCNVector3Uniform(0.05 as CGFloat)
        
        sceneNode!.position = worldPos!
        
        print("wrapper node: \(sceneNode!.position)")
        
        arView?.scene.rootNode.addChildNode(sceneNode!)
        
        
        
    }
    
    
    func setupPhysics(){
        
        self.scene?.rootNode.enumerateHierarchy({(_ node: SCNNode, _ _: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.physicsBody?.collisionBitMask = Int(Bitmask.character.rawValue)
        })
        
    }
    
    
    func padOverlayVirtualStickInteractionDidStart(_ padNode: PadOverlay) {
        
        if padNode == overlay!.controlOverlay!.leftPad {
            characterDirection = float2(Float(padNode.stickPosition.x), -Float(padNode.stickPosition.y))
        }
        
    }
    
    func padOverlayVirtualStickInteractionDidChange(_ padNode: PadOverlay) {
        
        if padNode == overlay!.controlOverlay!.leftPad {
            characterDirection = float2(Float(padNode.stickPosition.x), -Float(padNode.stickPosition.y))
        }
        
    }
    
    func padOverlayVirtualStickInteractionDidEnd(_ padNode: PadOverlay) {
        
        if padNode == overlay!.controlOverlay!.leftPad {
            characterDirection = [0, 0]
        }
        
    }
    
    func willPress(_ button: ButtonOverlay) {
        
        print("btn clicked")
        
        if button == overlay!.controlOverlay!.buttonStart{
            
            print("start btn clicked")
            initGame()
            //arCtrl?.arAnchorCtrl?.show(false)
            overlay!.controlOverlay!.playLayout()
            
        }
        
        if button == overlay!.controlOverlay?.buttonA{
            print("btn b clicked")
            self.character!.attack()
            
        }
        
        if button == overlay!.controlOverlay!.buttonB {
            self.character!.jump(sceneRenderer!)
        }
        
        
    }
    
    func didPress(_ button: ButtonOverlay) {
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        
        // update characters
        character?.update(atTime: time, with: renderer)
        
    }
    
    
}

