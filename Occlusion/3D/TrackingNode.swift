//
//  TrackingNode.swift
//  BouncyAR
//
//  Created by Bjarne Lundgren on 19/08/2017.
//  Copyright © 2017 Silicon.dk ApS. All rights reserved.
//

import Foundation
import SceneKit

class TrackingNode {
    class private func startNode() -> SCNNode {
        let sphere = SCNSphere(radius: 0.02)
        sphere.firstMaterial?.diffuse.contents = UIColor.green
        return SCNNode(geometry: sphere)
    }
    
    class private func endNode() -> SCNNode {
        let sphere = SCNSphere(radius: 0.02)
        sphere.firstMaterial?.diffuse.contents = UIColor.blue
        return SCNNode(geometry: sphere)
    }
    
    class func node(from:SCNVector3, to:SCNVector3?) -> SCNNode {
        let node = SCNNode()
        
        let startNode = self.startNode()
        startNode.position = from
        node.addChildNode(startNode)
        
        if let to = to {
            let endNode = self.endNode()
            endNode.position = to
            node.addChildNode(endNode)
            
            // just render wall on the fly as well.. :)
            node.addChildNode(Wall.node(from: from, to: to))
        }
        
        return node
    }
}
