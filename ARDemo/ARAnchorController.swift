//
//  AnchorController.swift
//  ARDemo
//
//  Created by n01192 on 7/14/17.
//  Copyright © 2017 test. All rights reserved.
//

import Foundation
import ARKit


class ARAnchorController:NSObject{
    
    private var arView: ARSCNView?
    private var allPlanes = [ARPlaneAnchor: DebugPlane]()
    

    init(arView_: ARSCNView){
        super.init()
        arView = arView_
        //arView!.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ isShow: Bool){
        
            
        for plane in allPlanes.values{
            
            plane.isHidden = !isShow
            
        }
    }
    
    func addDebugPlane(_ node: SCNNode,_ anchor: ARPlaneAnchor){
        DispatchQueue.global().async {
            let plane = DebugPlane(anchor: anchor)
            DispatchQueue.main.async {
                node.addChildNode(plane)
                self.allPlanes[anchor] = plane
                print("add planeId:\(plane.planeId) center:\(anchor.center)")
            }
        }
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = allPlanes[anchor] {
            plane.update(anchor)
            
            //print("update planeId:\(plane.planeId) center:\(anchor.center)")
        }
    }
    
    func removePlane(anchor: ARPlaneAnchor) {
        if let plane = allPlanes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
        }
    }
    
    
    func getPlaneByAnchor(_ anchor: ARPlaneAnchor)-> DebugPlane?{
        
        return allPlanes[anchor]
        
    }

}
