//
//  WallTrackState.swift
//  BouncyAR
//
//  Created by Bjarne Lundgren on 19/08/2017.
//  Copyright © 2017 Silicon.dk ApS. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

enum WallTrackState {
    case findFirstPoint
    case findScondPoint(trackingNode:SCNNode, wallStartPosition:SCNVector3, originAnchor:ARPlaneAnchor)
    case wallIdentified(wallNode:SCNNode, wallStartPosition:SCNVector3, wallEndPosition:SCNVector3)
}
