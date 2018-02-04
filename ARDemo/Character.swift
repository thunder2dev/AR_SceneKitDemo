//
//  Character.swift
//  ARDemo
//
//  Created by n01192 on 7/14/17.
//  Copyright © 2017 test. All rights reserved.
//

import SceneKit




class Character {
    
    private var model: SCNNode!
    private var characterCollisionShape: SCNPhysicsShape?
    private var collisionShapeOffsetFromModel = float3.zero
    
    private var lazyInitFinished = false
    
    private var previousUpdateTime: TimeInterval = 0
    
    static private let collisionMargin = Float(0.04)
    static private let modelOffset = float3(0, -collisionMargin, 0)
    static private let initialPosition = float3(0.1, -0.2, 0)
    
    
    let node = SCNNode()
    let dirNode = SCNNode()
    var collisionNode: SCNNode?
    
    
    var walkSpeed: CGFloat = 0.08 {
        didSet {
            model.animationPlayer(forKey: "walk")?.speed = 0.08
        }
    }
    
    var direction = float2()
    private var directionAngle: CGFloat = 0.0 {
        didSet {
            dirNode.runAction(
                SCNAction.rotateTo(x: 0.0, y: directionAngle, z: 0.0, duration: 0.1, usesShortestUnitArc:true))
        }
    }
    var isWalking: Bool = false {
        didSet {
            if oldValue != isWalking {
                // Update node animation.
                if isWalking {
                    model.animationPlayer(forKey: "walk")?.play()
                } else {
                    model.animationPlayer(forKey: "walk")?.stop(withBlendOutDuration: 0.2)
                }
            }
        }
    }
    
    /*var direction: SCNVector3(x:0.0, y:0, z:0){
        didSet{
            changeDirection(dir: direction)
        }
        
    }*/
    
    //var animations = [AnimType: CAAnimation]()
    var currAnimation:CAAnimation? = nil
    
    var physicsWorld: SCNPhysicsWorld?
    
    
    init() {
        
        //let topNode = characterFile.rootNode.childNodes[0]
        //node.addChildNode(topNode)
        
        loadModel()
        
        loadAnimations()
        
    }
    
    private func loadModel(){
        let characterScene = SCNScene(named: "art.scnassets/character/max.scn")!
        model = characterScene.rootNode.childNode( withName: "Max_rootNode", recursively: true)
        model.simdPosition = Character.modelOffset
        node.name = "character"
        node.simdPosition = Character.initialPosition
        
        node.addChildNode(dirNode)
        dirNode.addChildNode(model)        
    }
    
    
    private func setupPhysics(){
        
        collisionNode = model.childNode(withName: "collider", recursively: true)!
        collisionNode!.physicsBody?.collisionBitMask = Int(([ .enemy, .trigger, .collectable ] as Bitmask).rawValue)
        
        
        let (min, max) = model.boundingBox
        let collisionCapsuleRadius = CGFloat((max.x - min.x) * 0.4)
        let collisionCapsuleHeight = CGFloat(max.y - min.y)
        
        let collisionGeometry = SCNCapsule(capRadius: collisionCapsuleRadius, height: collisionCapsuleHeight)
        characterCollisionShape = SCNPhysicsShape(geometry: collisionGeometry, options:[.collisionMargin: Character.collisionMargin])
        collisionShapeOffsetFromModel = float3(0, Float(collisionCapsuleHeight) * 0.51, 0.0)
        
        
        /*
        let characterCollisionNode = SCNNode()
        characterCollisionNode.name = "collider"
        characterCollisionNode.position = SCNVector3(0.0, collisionCapsuleHeight * 0.51, 0.0) // a bit too high so that the capsule does not hit the floor
        characterCollisionNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape:SCNPhysicsShape(geometry: SCNCapsule(capRadius: collisionCapsuleRadius, height: collisionCapsuleHeight), options:nil))
        //characterCollisionNode.physicsBody!.contactTestBitMask = BitmaskSuperCollectable | BitmaskCollectable | BitmaskCollision | BitmaskEnemy
        node.addChildNode(characterCollisionNode)*/
        
    }
    
    
    class func loadAnimation(fromSceneNamed sceneName: String) -> SCNAnimationPlayer {
        let scene = SCNScene( named: sceneName )!
        // find top level animation
        var animationPlayer: SCNAnimationPlayer! = nil
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
    }
    
    private func loadAnimations(){
        
        let idleAnimation = Character.loadAnimation(fromSceneNamed: "art.scnassets/character/max_idle.scn")
        model.addAnimationPlayer(idleAnimation, forKey: "idle")
        idleAnimation.play()
        
        let walkAnimation = Character.loadAnimation(fromSceneNamed: "art.scnassets/character/max_walk.scn")
        walkAnimation.speed = 1.0//Character.speedFactor
        walkAnimation.stop()
        model.addAnimationPlayer(walkAnimation, forKey: "walk")
        
        let jumpAnimation = Character.loadAnimation(fromSceneNamed: "art.scnassets/character/max_jump.scn")
        jumpAnimation.animation.isRemovedOnCompletion = false
        jumpAnimation.stop()
        model.addAnimationPlayer(jumpAnimation, forKey: "jump")
        
        let spinAnimation = Character.loadAnimation(fromSceneNamed: "art.scnassets/character/max_spin.scn")
        spinAnimation.animation.isRemovedOnCompletion = false
        spinAnimation.speed = 1.5
        spinAnimation.stop()
        model!.addAnimationPlayer(spinAnimation, forKey: "spin")
        
        
    }
    
    
    func jump(_ renderer: SCNSceneRenderer) {
        //model.animationPlayer(forKey: "spin")?.play()
        //spinParticleAttach.addParticleSystem(spinCircleParticle)
        let duration = 0.5
        let direction = characterDirection(withPointOfView:renderer.pointOfView)
        let characterSpeed = 1.0/60.0 * walkSpeed
        let characterVelocity = direction * Float(characterSpeed)
        
        let bounceUpAction = SCNAction.moveBy(x: CGFloat(characterVelocity.x), y: 0.05, z: CGFloat(characterVelocity.z), duration: duration * 0.5)
        let bounceDownAction = SCNAction.moveBy(x: CGFloat(characterVelocity.x) * 2, y: -0.05, z: CGFloat(characterVelocity.z) * 2, duration: duration * 0.5)
        let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])
        
        node.runAction(bounceAction)
        
    }
    
    func attack() {
        model.animationPlayer(forKey: "spin")?.play()
    }
    
    
    func update(atTime time: TimeInterval, with renderer: SCNSceneRenderer) {
        
        if !lazyInitFinished{
            
            setupPhysics()
            
        }
        
        
        if previousUpdateTime == 0.0 {
            previousUpdateTime = time
        }
        
        
        let direction = characterDirection(withPointOfView:renderer.pointOfView)
        
        let deltaTime = time - previousUpdateTime
        previousUpdateTime = time
        let characterSpeed = CGFloat(deltaTime) * walkSpeed
        
        print("delta:\(deltaTime) walkspeed:\(walkSpeed)")
        
        var characterVelocity = float3.zero
        
        
        if !direction.allZero() {
            characterVelocity = direction * Float(characterSpeed)
            var runModifier = Float(1.0)
            
            
            // move character
            directionAngle = CGFloat(atan2f(direction.x, direction.z))
            
            isWalking = true
        } else {
            isWalking = false
        }
        
        if simd_length_squared(characterVelocity) > 10E-4 * 10E-4 {
            let startPosition = node.presentation.simdWorldPosition + collisionShapeOffsetFromModel
            slideInWorld(fromPosition: startPosition, velocity: characterVelocity)
        }
    }
    
    
    static func getSceneSource(daeNamed: String) -> SCNSceneSource! {
        let collada = Bundle.main.url(forResource:"Models.scnassets/\(daeNamed)", withExtension: "dae")
        return SCNSceneSource(url: collada!, options: nil)!
    }
    
    /*func loadAnimation(withKey:   AnimType, daeNamed: String, fade: CGFloat = 0.3){
        
        let sceneSource = Character.getSceneSource(daeNamed: daeNamed)
        
        let animation = sceneSource?.entryWithIdentifier("\(daeNamed)-1", withClass: CAAnimation.self)!
        
        animation?.repeatCount = MAXFLOAT;//todo
        
        // animation.speed = 1
        animation?.fadeInDuration = fade
        animation?.fadeOutDuration = fade
        // animation.beginTime = CFTimeInterval( fade!)
        animations[withKey] = animation
    }*/
    
    
    
    
    
    /*func playAnimation(named: AnimType){
        if let animation = animations[named] {
            node.addAnimation(animation, forKey: named.rawValue)
        }
    }*/
    
    
    func changeDirection(dir: SCNVector3){
        
        let ang = SCNFloat(atan2(dir.x, dir.z))
        node.runAction(SCNAction.rotateTo(x: 0.0, y: CGFloat(ang), z: 0.0, duration: 0.1, usesShortestUnitArc: true))
        
    }
    
    func characterDirection(withPointOfView pointOfView: SCNNode?) -> float3 {
        let controllerDir = self.direction
        if controllerDir.allZero() {
            return float3.zero
        }
        
        var directionWorld = float3.zero
        if let pov = pointOfView {
            let p1 = pov.presentation.simdConvertPosition(float3(controllerDir.x, 0.0, controllerDir.y), to: nil)
            let p0 = pov.presentation.simdConvertPosition(float3.zero, to: nil)
            directionWorld = p1 - p0
            directionWorld.y = 0
            if simd_any(directionWorld != float3.zero) {
                let minControllerSpeedFactor = Float(0.2)
                let maxControllerSpeedFactor = Float(1.0)
                let speed = simd_length(controllerDir) * (maxControllerSpeedFactor - minControllerSpeedFactor) + minControllerSpeedFactor
                directionWorld = speed * simd_normalize(directionWorld)
            }
        }
        return directionWorld
    }
    
    
    // MARK: - physics contact
    func slideInWorld(fromPosition start: float3, velocity: float3) {
        let maxSlideIteration: Int = 4
        var iteration = 0
        var stop: Bool = false
        
        var replacementPoint = start
        
        var start = start
        var velocity = velocity
        let options: [SCNPhysicsWorld.TestOption: Any] = [
            SCNPhysicsWorld.TestOption.collisionBitMask: Bitmask.collision.rawValue,
            SCNPhysicsWorld.TestOption.searchMode: SCNPhysicsWorld.TestSearchMode.closest]
        while !stop {
            var from = matrix_identity_float4x4
            from.position = start
            
            var to: matrix_float4x4 = matrix_identity_float4x4
            to.position = start + velocity
            
            let contacts = physicsWorld!.convexSweepTest(
                with: characterCollisionShape!,
                from: SCNMatrix4.init(from),
                to: SCNMatrix4.init(to),
                options: options)
            if !contacts.isEmpty {
                (velocity, start) = handleSlidingAtContact(contacts.first!, position: start, velocity: velocity)
                iteration += 1
                
                if simd_length_squared(velocity) <= (10E-3 * 10E-3) || iteration >= maxSlideIteration {
                    replacementPoint = start
                    stop = true
                }
            } else {
                replacementPoint = start + velocity
                stop = true
            }
        }
        node.simdWorldPosition = replacementPoint - collisionShapeOffsetFromModel
        
        print("new pos:\(node.simdWorldPosition) v:\(velocity)")
    }
    
    private func handleSlidingAtContact(_ closestContact: SCNPhysicsContact, position start: float3, velocity: float3)
        -> (computedVelocity: simd_float3, colliderPositionAtContact: simd_float3) {
            let originalDistance: Float = simd_length(velocity)
            
            let colliderPositionAtContact = start + Float(closestContact.sweepTestFraction) * velocity
            
            // Compute the sliding plane.
            let slidePlaneNormal = float3.init(closestContact.contactNormal)
            let slidePlaneOrigin = float3.init(closestContact.contactPoint)
            let centerOffset = slidePlaneOrigin - colliderPositionAtContact
            
            // Compute destination relative to the point of contact.
            let destinationPoint = slidePlaneOrigin + velocity
            
            // We now project the destination point onto the sliding plane.
            let distPlane = simd_dot(slidePlaneOrigin, slidePlaneNormal)
            
            // Project on plane.
            var t = planeIntersect(planeNormal: slidePlaneNormal, planeDist: distPlane,
                                   rayOrigin: destinationPoint, rayDirection: slidePlaneNormal)
            
            let normalizedVelocity = velocity * (1.0 / originalDistance)
            let angle = simd_dot(slidePlaneNormal, normalizedVelocity)
            
            var frictionCoeff: Float = 0.3
            if fabs(angle) < 0.9 {
                t += 10E-3
                frictionCoeff = 1.0
            }
            let newDestinationPoint = (destinationPoint + t * slidePlaneNormal) - centerOffset
            
            // Advance start position to nearest point without collision.
            let computedVelocity = frictionCoeff * Float(1.0 - closestContact.sweepTestFraction)
                * originalDistance * simd_normalize(newDestinationPoint - start)
            
            return (computedVelocity, colliderPositionAtContact)
    }
    
    
}
func planeIntersect(planeNormal: float3, planeDist: Float, rayOrigin: float3, rayDirection: float3) -> Float {
    return (planeDist - simd_dot(planeNormal, rayOrigin)) / simd_dot(planeNormal, rayDirection)
}
