//
//  Wall.swift
//  BouncyAR
//
//  Created by Bjarne Lundgren on 19/08/2017.
//  Copyright © 2017 Silicon.dk ApS. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

let WALL_TEXT_SIZE_MULP:CGFloat = 100

class Wall {
    
    static let HEIGHT:CGFloat = 3.0
    
    class func wallMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.darkGray
        mat.transparency = 0.5
        
        // dont care if wall turns away from us, still render it
        mat.isDoubleSided = true
        return mat
    }
    
    class func maskMaterial() -> SCNMaterial {
        let maskMaterial = SCNMaterial()
        maskMaterial.diffuse.contents = UIColor.white
        
        // another way to do this is to set a very very low transparency value (but that
        // would not receive shadows..)
        // mask out everything we would have drawn..
        maskMaterial.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        
        // occlude (render) from both sides please
        maskMaterial.isDoubleSided = true
        return maskMaterial
    }
    
    class func makeInvisibleOccludingWall(wallNode:SCNNode) {
        wallNode.geometry?.firstMaterial = maskMaterial()
        
        wallNode.physicsBody = SCNPhysicsBody(type: .static,
                                              shape: nil)
        wallNode.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        wallNode.physicsBody?.collisionBitMask = CollisionTypes.beachball.rawValue
    }
    
    class func node(from:SCNVector3,
                    to:SCNVector3) -> SCNNode {
        let distance = from.distance(vector: to)
        
        let wall = SCNPlane(width: CGFloat(distance),
                            height: HEIGHT)
        wall.firstMaterial = wallMaterial()
        let node = SCNNode(geometry: wall)
        
        // always render before the beachballs
        node.renderingOrder = -10
        
        // get center point
        node.position = SCNVector3(from.x + (to.x - from.x) * 0.5,
                                   from.y + Float(HEIGHT) * 0.5,
                                   from.z + (to.z - from.z) * 0.5)
        
        // orientation of the wall is fairly simple. we only need to orient it around the y axis,
        // and the angle is calculated with 2d math.. now this calculation does not factor in the position of the
        // camera, and so if you move the cursor right relative to the starting position the
        // wall will be oriented away from the camera (in this app the wall material is set as double sided so you will not notice)
        // - obviously if you want to render something on the walls, this issue will need to be resolved.
        node.eulerAngles = SCNVector3(0,
                                      -atan2(to.x - node.position.x, from.z - node.position.z) - Float.pi * 0.5,
                                      0)
        //node.castsShadow = false
        
        return node
    }
}
