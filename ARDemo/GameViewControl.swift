//
//  GameViewControl.swift
//  ARDemo
//
//  Created by n01192 on 7/14/17.
//  Copyright © 2017 test. All rights reserved.
//

import ARKit
import Foundation
import SceneKit
import UIKit
import Photos

class GameViewController: UIViewController, UIGestureRecognizerDelegate{
    
    @IBOutlet var sceneView: ARSCNView!
    
    var gameController: GameController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /*let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        tap.delegate = self
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)*/
        
        
        gameController = GameController(scnView: sceneView)
        
    }
    
    
    /*
    @objc func handleTap(){
        print("Tap Gesture Received")
        gameController?.arCtrl?.loadObj()
    }*/
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        gameController!.startAR()
        
        
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    override var shouldAutorotate: Bool { return true }
    
    
    /*
     override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
     session.pause()
     }
     
     
     
     
     func setupScene() {
     // set up sceneView
     sceneView.delegate = self
     sceneView.session = session
     sceneView.antialiasingMode = .multisampling4X
     sceneView.automaticallyUpdatesLighting = false
     
     sceneView.preferredFramesPerSecond = 60
     sceneView.contentScaleFactor = 1.3
     //sceneView.showsStatistics = true
     
     DispatchQueue.main.async {
     self.screenCenter = self.sceneView.bounds.mid
     }
     
     enableEnvironmentMapWithIntensity(25.0)
     
     if let camera = sceneView.pointOfView?.camera {
     camera.wantsHDR = true
     camera.wantsExposureAdaptation = true
     camera.exposureOffset = -1
     camera.minimumExposure = -1
     }
     }
     
     func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
     if sceneView.scene.lightingEnvironment.contents == nil {
     if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
     sceneView.scene.lightingEnvironment.contents = environmentMap
     }
     }
     
     sceneView.scene.lightingEnvironment.intensity = intensity
     }
     
     
     // MARK: - UIPopoverPresentationControllerDelegate
     func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
     return .none
     }
     
     
     override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
     if UIDevice.current.userInterfaceIdiom == .phone {
     return .allButUpsideDown
     } else {
     return .all
     }
     }
     
     
     
     
     var added:Bool = false
     var anchorx: ARAnchor? = nil
     
     
     
     
     
     private var directionAngle: SCNFloat = 0.0 {
     didSet {
     if directionAngle != oldValue {
     cobj?.runAction(SCNAction.rotateTo(x: 0.0, y: CGFloat(directionAngle), z: 0.0, duration: 0.1, usesShortestUnitArc: true))
     }
     }
     }
     
     
     
     var startPos: CGPoint = CGPoint(x:0, y:0);
     var objPos: SCNVector3 = SCNVector3(x:0.0, y:0, z:0);
     var dir: SCNVector3 = SCNVector3(x:0.0, y:0, z:0);
     
     
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     
     print("touched");
     
     if myobj == nil{
     
     loadObj()
     return
     }
     
     let touch = touches[touches.index(touches.startIndex, offsetBy: 0)]
     
     
     startPos = touch.location(in: self.sceneView)
     
     print("start touch:\(startPos)")
     
     }
     
     var walkDir: float3?
     
     
     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     
     let touch = touches[touches.index(touches.startIndex, offsetBy: 0)]
     
     let currPos = touch.location(in: self.sceneView)
     
     let viewOffset = currPos - startPos
     
     let offsetLen = viewOffset.length()
     
     //print("currV3: \(currPos)  offsetV3: \(startPos) len \(offsetLen)")
     
     if offsetLen < 100{
     return
     }
     
     let offset = currPos - startPos
     
     let dirOri = SCNVector3(offset.x, 0, offset.y)
     let directionV = dirOri.normalized()
     var direction = float3(directionV.x, directionV.y, directionV.z)
     
     if let pov = self.sceneView.pointOfView {
     let p1 = pov.presentation.convertPosition(SCNVector3(direction), to: nil)
     let p0 = pov.presentation.convertPosition(SCNVector3Zero, to: nil)
     direction = float3(Float(p1.x - p0.x), 0.0, Float(p1.z - p0.z))
     
     if direction.x != 0.0 || direction.z != 0.0 {
     direction = normalize(direction)
     }
     }
     
     
     
     
     }
     
     
     
     
     
     
     
     */
    
    
    
    
    
}





