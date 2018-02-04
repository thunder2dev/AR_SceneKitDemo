//
//  DebugPlane.swift
//  ARDemo
//
//  Created by n01192 on 7/14/17.
//  Copyright © 2017 test. All rights reserved.
//

import Foundation
import ARKit

class DebugPlane: SCNNode {
    
    static var planeIdGenerator: Int32 = 1
    
    public var planeId: Int32 = DebugPlane.planeIdGenerator
    
    var planeAnchor: ARPlaneAnchor
    
    var planeGeometry: SCNPlane
    var planeNode: SCNNode
    
    var occlusionNode: SCNNode?
    let occlusionPlaneVerticalOffset: Float = -0.01
    
    init(anchor: ARPlaneAnchor) {
        
        DebugPlane.planeIdGenerator += 1
        
        self.planeAnchor = anchor
        
        let grid = UIImage(named: "art.scnassets/plane_grid.png")
        self.planeGeometry = createPlane(size: CGSize(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z)),
                                         contents: grid)
        self.planeNode = SCNNode(geometry: planeGeometry)
        self.planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        
        super.init()
        
        let originVisualizationNode = createAxesNode(quiverLength: 0.1, quiverThickness: 1.0)
        self.addChildNode(originVisualizationNode)
        self.addChildNode(planeNode)
        
        self.position = SCNVector3(anchor.center.x, -0.002, anchor.center.z) // 2 mm below the origin of plane.
        
        adjustScale()
        
        createOcclusionNode()
        
    }
    
    func update(_ anchor: ARPlaneAnchor) {
        self.planeAnchor = anchor
        
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        
        self.position = SCNVector3Make(anchor.center.x, -0.002, anchor.center.z)
        
        adjustScale()
        
        updateOcclusionNode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func adjustScale() {
        let scaledWidth: Float = Float(planeGeometry.width / 2.4)
        let scaledHeight: Float = Float(planeGeometry.height / 2.4)
        
        let offsetWidth: Float = -0.5 * (scaledWidth - 1)
        let offsetHeight: Float = -0.5 * (scaledHeight - 1)
        
        let material = self.planeGeometry.materials.first
        var transform = SCNMatrix4MakeScale(scaledWidth, scaledHeight, 1)
        transform = SCNMatrix4Translate(transform, offsetWidth, offsetHeight, 0)
        material?.diffuse.contentsTransform = transform
        
    }
    
    private func createOcclusionNode() {
        // Make the occlusion geometry slightly smaller than the plane.
        let occlusionPlane = SCNPlane(width: CGFloat(planeAnchor.extent.x - 0.05 + 20.0  ), height: CGFloat(planeAnchor.extent.z - 0.05 + 20.0))
        let material = SCNMaterial()
        material.colorBufferWriteMask = []
        material.isDoubleSided = true
        occlusionPlane.materials = [material]
        
        occlusionNode = SCNNode()
        occlusionNode!.geometry = occlusionPlane
        occlusionNode!.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        occlusionNode!.position = SCNVector3Make(planeAnchor.center.x, occlusionPlaneVerticalOffset, planeAnchor.center.z)
        
        self.addChildNode(occlusionNode!)
    }
    
    private func updateOcclusionNode() {
        guard let occlusionNode = occlusionNode, let occlusionPlane = occlusionNode.geometry as? SCNPlane else {
            return
        }
        occlusionPlane.width = CGFloat(planeAnchor.extent.x - 0.05 + 20.0)
        occlusionPlane.height = CGFloat(planeAnchor.extent.z - 0.05 + 20.0)
        
        occlusionNode.position = SCNVector3Make(planeAnchor.center.x, occlusionPlaneVerticalOffset, planeAnchor.center.z)
    }
    
}





