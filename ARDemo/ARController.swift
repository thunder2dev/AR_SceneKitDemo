//
//  ARController.swift
//  ARDemo
//
//  Created by n01192 on 7/14/17.
//  Copyright © 2017 test. All rights reserved.
//

import ARKit


protocol MARDelegate: NSObjectProtocol {
    func firstAnchorAdded(_ node:SCNNode, _ anchor: ARPlaneAnchor)
}



class ARController:NSObject, ARSCNViewDelegate{
    public var gameController: GameController?
    
    private var arView: ARSCNView?
    weak var delegate: MARDelegate?
    
    public var isFirstAnchorAdded: Bool = false
    public var arAnchorCtrl: ARAnchorController?
    
    var sessionConfig: ARSessionConfiguration = ARWorldTrackingSessionConfiguration()
    let session = ARSession()
    
    init(_ arView_: ARSCNView){
        super.init()
        arView = arView_
        arAnchorCtrl = ARAnchorController(arView_: arView_)
        
        arView!.delegate = self
        arView!.antialiasingMode = .multisampling4X
        arView!.automaticallyUpdatesLighting = false
        arView!.session = session
        
        arView!.preferredFramesPerSecond = 60
        //arView!.contentScaleFactor = 1.3
        arView!.showsStatistics = true
        
        enableEnvironmentMapWithIntensity(25.0)
        
        if let camera = arView!.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
        }
    }
    
    func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
        if arView!.scene.lightingEnvironment.contents == nil {
            if let environmentMap = UIImage(named: "art.scnassets/scene/environment_blur.exr") {
                arView!.scene.lightingEnvironment.contents = environmentMap
            }
        }
        arView!.scene.lightingEnvironment.intensity = intensity
    }
    
    
    
    func start(){
        
        print("ar tracking started")
        
        if let worldSessionConfig = sessionConfig as? ARWorldTrackingSessionConfiguration {
            worldSessionConfig.planeDetection = .horizontal
            arView!.session.run(worldSessionConfig, options: [.resetTracking, .removeExistingAnchors])
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    var mmmm: SCNNode?
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            
            self.arAnchorCtrl?.addDebugPlane(node, planeAnchor)
            if !self.isFirstAnchorAdded {
                self.isFirstAnchorAdded = true
                self.delegate?.firstAnchorAdded(node, planeAnchor)
            }
            
            //self.anchorx = planeAnchor
            /*
             if(!added){
             self.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor)
             added = true
             }*/
            
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            //print("update plane")
            
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.arAnchorCtrl!.updatePlane(anchor: planeAnchor)
                
                //self.checkIfObjectShouldMoveOntoPlane(object: self.mmmm!, anchor: anchor as! ARPlaneAnchor)
                                
                
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                let planeId = self.arAnchorCtrl?.getPlaneByAnchor(planeAnchor)!.planeId
                print("remove planeId:\(String(describing: planeId)) center:\(planeAnchor.center)")
                self.arAnchorCtrl!.removePlane(anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        
        // update characters
        gameController?.renderer(renderer, updateAtTime: time)
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    
    }
    
    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         objectPos: SCNVector3?,
                                         infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)
        
        let planeHitTestResults = arView!.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let planeAnchor = result.anchor
            
            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        
        
        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.
        
        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = self.arView!.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).
        
        if infinitePlane || !highQualityFeatureHitTestResult {
            
            let pointOnPlane = objectPos ?? SCNVector3Zero
            
            let pointOnInfinitePlane = self.arView!.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
            if pointOnInfinitePlane != nil {
                return (pointOnInfinitePlane, nil, true)
            }
        }
        
        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }
        
        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.
        
        let unfilteredFeatureHitTestResults = self.arView!.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        
        
        print("go to 2..")
        return (nil, nil, false)
    }
    
    
    func checkIfObjectShouldMoveOntoPlane(object: SCNNode, anchor: ARPlaneAnchor) {
        guard let planeAnchorNode = arView?.node(for: anchor) else {
            return
        }
        
        // Get the object's position in the plane's coordinate system.
        let objectPos = planeAnchorNode.convertPosition(object.position, from: object.parent)
        
        if objectPos.y == 0 {
            return; // The object is already on the plane - nothing to do here.
        }
        
        // Add 10% tolerance to the corners of the plane.
        let tolerance: Float = 0.1
        
        let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
        let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
        let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
        let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance
        
        if objectPos.x < minX || objectPos.x > maxX || objectPos.z < minZ || objectPos.z > maxZ {
            return
        }
        
        // Drop the object onto the plane if it is near it.
        let verticalAllowance: Float = 0.03
        if objectPos.y > -verticalAllowance && objectPos.y < verticalAllowance {
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            object.position.y = anchor.transform.columns.3.y
            SCNTransaction.commit()
        }
    }
        /*
     var screenCenter: CGPoint?
     var lastPosition: SCNVector3?
     
     
     func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
     DispatchQueue.main.async {
     
     if let planeAnchor = anchor as? ARPlaneAnchor {
     self.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor)
     }
     }
     }
    
    private var previousUpdateTime = TimeInterval(0.0)
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let sCenter = self.screenCenter else{
            return
        }
        
        let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(sCenter, objectPos: nil)
        //print("world position:\(worldPos)")
        
        if let wp = worldPos {
            
            self.lastPosition = wp
            
            //print("last position:\(wp)")
            
        }
        
        if walkDir != nil && cobj != nil {
            
            if previousUpdateTime == 0.0 {
                previousUpdateTime = time
            }
            
            let deltaTime = Float(min(time - previousUpdateTime, 1.0 / 60.0))
            let characterSpeed = deltaTime * 1
            
            let initPos = cobj?.position
            
            
            let position = float3((cobj?.position)!)
            cobj?.position = SCNVector3(position + walkDir! * characterSpeed)
            
            directionAngle = SCNFloat(atan2((walkDir?.x)!, (walkDir?.z)!))
            
            print("new pos:\(cobj?.position)")
            
        }        
    }

    
    
     
    */
}

