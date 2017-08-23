//
//  Wand.swift
//  BouncyAR
//
//  Created by Bjarne Lundgren on 19/08/2017.
//  Copyright © 2017 Silicon.dk ApS. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class Wand {
    static let SIZE:CGFloat = 0.6
    static let METERS_PER_SECOND:CGFloat = 0.5
    static let HANDLE_LENGTH:CGFloat = 0.5
    static let HANDLE_TOP_RADIUS:CGFloat = 0.03
    static let HANDLE_BOTTOM_RADIUS:CGFloat = 0.02
    
    static let TIP_RADIUS:CGFloat = 0.06
    static let RECHARGE_TIME:TimeInterval = 0.25
    
    static let WAND_NODE_NAME = "wand"
    static let TIP_NODE_NAME = "tip"
    
    class func coneMaterials() -> [SCNMaterial] {
        let mat  = SCNMaterial()
        mat.diffuse.contents = UIImage(named: "art.scnassets/s/seamless_wood_texure_by_bhaskar655-d9y62za.jpg")
        mat.normal.contents = UIImage(named: "art.scnassets/s/wand_stock_normal.png")
        mat.displacement.contents = UIImage(named: "art.scnassets/s/wand_stock_displacement.png")
        
        let endMat = SCNMaterial()
        // https://www.flickr.com/photos/filterforge/8671761554
        endMat.diffuse.contents = UIImage(named: "art.scnassets/s/wood_end.png")
        
        return [mat, endMat, endMat]
    }
    
    private static var _ballMaterial:SCNMaterial?
    
    class func ballMaterial() -> SCNMaterial {
        if _ballMaterial == nil {
            let mat = SCNMaterial()
            
            // beachball texture: http://www.robinwood.com/Catalog/FreeStuff/Textures/TexturePages/BallMaps.html
            mat.diffuse.contents = UIImage(named: "art.scnassets/s/BeachBallColor.jpg")
            mat.transparent.contents = UIImage(named: "art.scnassets/s/BeachBallTransp3.png")
            mat.transparencyMode = .dualLayer
          
            mat.readsFromDepthBuffer = true
            mat .writesToDepthBuffer = true
            _ballMaterial = mat
          
        }
        
        
        return _ballMaterial!
    }
    
    class func wandNode() -> SCNNode {
        let wandNode = SCNNode()
        wandNode.name = WAND_NODE_NAME
        
        // handle of the wand
        let cone = SCNCone(topRadius: HANDLE_TOP_RADIUS,
                           bottomRadius: HANDLE_BOTTOM_RADIUS,
                           height: HANDLE_LENGTH)
        cone.heightSegmentCount = 12
        cone.materials = coneMaterials()
        let coneNode = SCNNode(geometry: cone)
        wandNode.addChildNode(coneNode)
        
        // tip/sphere of the wand
        let sphere = SCNSphere(radius: TIP_RADIUS)
        sphere.materials = [ballMaterial()]
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0,HANDLE_LENGTH * 0.5 + TIP_RADIUS * 0.75,0)
        sphereNode.name = TIP_NODE_NAME
        wandNode.addChildNode(sphereNode)
        
        return wandNode
    }
    
    class func node() -> SCNNode {
        let node = SCNNode()
        
        let wandNode = self.wandNode()
        wandNode.eulerAngles = SCNVector3(0,0,45.0.degreesToRadians)
        wandNode.position = SCNVector3(0,0.3,0)
        node.addChildNode(wandNode)
        
        let physicsGeometry = SCNBox(width: SIZE, height: SIZE, length: SIZE, chamferRadius: 0)
        node.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic,
                                          shape: SCNPhysicsShape(geometry: physicsGeometry, options: nil))
        
        let moveUpAction = SCNAction.moveBy(x: 0, y: 0.1, z: 0, duration: 0.3)
        let moveDownAction = SCNAction.moveBy(x: 0, y: -0.1, z: 0, duration: 0.3)
        let waitAction = SCNAction.wait(duration: 1.5)
        let sequence = SCNAction.sequence([moveUpAction, moveDownAction, moveUpAction, moveDownAction, waitAction])
        node.runAction(SCNAction.repeatForever(sequence))
        
        return node
    }
}
