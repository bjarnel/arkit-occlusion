//
//  BouncyOption.swift
//  BouncyAR
//
//  Created by Bjarne Lundgren on 19/08/2017.
//  Copyright © 2017 Silicon.dk ApS. All rights reserved.
//

import Foundation

enum BouncyOption:String, HUDOption {
    case newWall = "newWall"
    case start = "start"
    case cancelWall = "cancelWall"
    
    var id:String {
        return rawValue
    }
    
    var title:String {
        switch self {
        case .newWall: return "NEW WALL"
        case .start: return "START"
        case .cancelWall: return "CANCEL"
        }
    }
}
