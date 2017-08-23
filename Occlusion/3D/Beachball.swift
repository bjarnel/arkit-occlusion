//
//  Fireball.swift
//  BouncyAR
//
//  Created by Bjarne Lundgren on 19/08/2017.
//  Copyright © 2017 Silicon.dk ApS. All rights reserved.
//

import Foundation
import SceneKit

class Beachball {
    static let TTL:TimeInterval = 5
    static let INITIAL_VELOCITY:Float = 4
    static let RADIUS:CGFloat = Wand.TIP_RADIUS
    
    private static var sphere:SCNGeometry?
    
    class func node() -> SCNNode {
        
        if sphere == nil {
            sphere = SCNSphere(radius: RADIUS)
            sphere!.materials = [Wand.ballMaterial()]
        }
        
        let node = SCNNode(geometry: sphere!)
        node.renderingOrder = 10
        
        
        let body = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic,
                                  shape: nil)
        body.categoryBitMask = CollisionTypes.beachball.rawValue
        body.collisionBitMask = CollisionTypes.solid.rawValue|CollisionTypes.wall.rawValue|CollisionTypes.beachball.rawValue
        // body.contactTestBitMask = CollisionTypes.fireball.rawValue|CollisionTypes.wall.rawValue
        body.isAffectedByGravity = true
        body.mass = 0.5
        body.restitution = 0.75
        body.damping = 0.1
        body.friction = 0.8
        
        node.physicsBody = body
        
        return node
    }
}
