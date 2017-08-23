//
//  Floor.swift
//  BouncyAR
//
//  Created by Bjarne Lundgren on 20/08/2017.
//  Copyright © 2017 Silicon.dk ApS. All rights reserved.
//

import Foundation
import SceneKit

class Floor {
    class func node(position:SCNVector3) -> SCNNode {
        
        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        let node = SCNNode(geometry: floor)
        node.physicsBody = SCNPhysicsBody(type: .static,
                                          shape: nil)
        node.physicsBody?.categoryBitMask = CollisionTypes.solid.rawValue
        node.physicsBody?.collisionBitMask = CollisionTypes.beachball.rawValue
        //node.physicsBody?.contactTestBitMask = CollisionTypes.fireball.rawValue|CollisionTypes.solid.rawValue
        node.position = position
        
        return node
    }
}
