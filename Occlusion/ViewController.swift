//
//  ViewController.swift
//  BouncyAR
//
//  Created by Bjarne Lundgren on 19/08/2017.
//  Copyright © 2017 Silicon.dk ApS. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    var trackState = WallTrackState.findFirstPoint
    var mode = AppState.menu {
        willSet {
            if mode == .menu {
                HUD.remove(options: [BouncyOption.newWall, BouncyOption.start],
                           in: sceneView.overlaySKScene!)
            }
            if mode == .addingWall {
                HUD.remove(options: [BouncyOption.cancelWall],
                           in: sceneView.overlaySKScene!)
            }
        }
        didSet {
            switch mode {
            case .menu:
                HUD.present(options: [BouncyOption.newWall, BouncyOption.start],
                            in: sceneView.overlaySKScene!)
            case .addingWall:
                trackState = .findFirstPoint
                HUD.present(options: [BouncyOption.cancelWall],
                            in: sceneView.overlaySKScene!)
                
            case .playing:
                // put wand into the hands of the user (camera node attachment)..
                carryNode.position = SCNVector3(0.07 - 0.01,-0.25,-0.3)
                carryNode.eulerAngles = SCNVector3(-60.0.degreesToRadians,0,30.0.degreesToRadians)
                let movePosAction = SCNAction.moveBy(x: 0.02, y: 0, z: 0, duration: 0.7)
                let moveNegAction = SCNAction.moveBy(x: -0.02, y: 0, z: 0, duration: 0.7)
                let sequence = SCNAction.sequence([movePosAction, moveNegAction])
                carryNode.runAction(SCNAction.repeatForever(sequence))
                sceneView.pointOfView?.addChildNode(carryNode)
                
                // replace all walls with invisible versions, these having physics bodies
                // we also need to find center point to add lighting..(!)
                var totalX:Float = 0
                var totalZ:Float = 0
                
                for wall in walls {
                    Wall.makeInvisibleOccludingWall(wallNode: wall.wallNode)
                    totalX += wall.wallStartPosition.x
                    totalX += wall.wallEndPosition.x
                    totalZ += wall.wallStartPosition.z
                    totalZ += wall.wallEndPosition.z
                }
                
                let centerPosition = SCNVector3(totalX / Float(walls.count * 2),
                                                walls[0].wallStartPosition.y,
                                                totalZ / Float(walls.count * 2))
                
                sceneView.scene.rootNode.addChildNode(Floor.node(position: centerPosition))
                
                let light = SCNLight()
                light.type = .spot
                light.shadowMode = .deferred
                light.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                light.castsShadow = true
                let lightNode = SCNNode()
                lightNode.position = SCNVector3(centerPosition.x,
                                                centerPosition.y + 10,
                                                centerPosition.z)
                lightNode.look(at: SCNVector3(0,0,0))
                lightNode.light = light
                sceneView.scene.rootNode.addChildNode(lightNode)
                
                let ambientLight = SCNLight()
                ambientLight.type = .ambient
                ambientLightNode = SCNNode()
                ambientLightNode!.light = ambientLight
                sceneView.scene.rootNode.addChildNode(ambientLightNode!)
            }
        }
    }
    var wandIsRecharging = false
    var walls = [(wallNode:SCNNode, wallStartPosition:SCNVector3, wallEndPosition:SCNVector3, wallId:String)]()
    var ambientLightNode:SCNNode?
    var carryNode:SCNNode!
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        // sceneView.showsStatistics = true
        
        let scene = SCNScene()
        sceneView.scene = scene
        // sceneView.scene.physicsWorld.contactDelegate = self
        
        // generally you should not set this higher than the framerate, however we
        // want to run it 120 times per seconds in order to catch collisions between the fireball and planes
        // more accurately. In a more complex scene, this probably drop frames and stuff :D
        sceneView.scene.physicsWorld.timeStep = 1.0 / 120.0
        sceneView.overlaySKScene = SKScene(size: view.frame.size)
        
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(didTap)))
        
        mode = .menu
        
        // creating the wand is costly, so we'll do it up front..
        carryNode = Wand.wandNode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = false
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.overlaySKScene?.size = view.frame.size
    }
    
    private func anyPlaneFrom(location:CGPoint, usingExtent:Bool = true) -> (SCNNode, SCNVector3, ARPlaneAnchor)? {
        let results = sceneView.hitTest(location,
                                        types: usingExtent ? ARHitTestResult.ResultType.existingPlaneUsingExtent : ARHitTestResult.ResultType.existingPlane)
        
        guard results.count > 0,
            let anchor = results[0].anchor as? ARPlaneAnchor,
            let node = sceneView.node(for: anchor) else { return nil }
        
        return (node,
                SCNVector3Make(results[0].worldTransform.columns.3.x, results[0].worldTransform.columns.3.y, results[0].worldTransform.columns.3.z),
                anchor)
    }
    
    @objc func didTap(_ sender:UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        switch mode {
        case .menu: menuTapped(location: location)
        case .addingWall: addingWallTapped(location: location)
        case .playing: playingTapped(location: location)
        }
    }
    
    private func menuTapped(location:CGPoint) {
        guard let hudPosition = sceneView.overlaySKScene?.convertPoint(fromView: location),
            let node = sceneView.overlaySKScene?.nodes(at: hudPosition).first,
            let nodeName = node.name else { return }
        
        switch nodeName {
        case BouncyOption.newWall.id:
            mode = .addingWall
            
        case BouncyOption.start.id:
            guard !walls.isEmpty else { return }
            mode = .playing
            
        default: break
        }
    }
    
    private func addingWallTapped(location:CGPoint) {
        if let hudPosition = sceneView.overlaySKScene?.convertPoint(fromView: location),
            let node = sceneView.overlaySKScene?.nodes(at: hudPosition).first,
            let nodeName = node.name {
            
            switch nodeName {
            case BouncyOption.cancelWall.id:
                if case .findScondPoint(let trackingNode, _, _) = trackState {
                    // cleanup!
                    trackingNode.removeFromParentNode()
                }
                trackState = .findFirstPoint
                mode = .menu
                
            default: break
            }
            
            return
        }
        
        
        switch trackState {
        case .findFirstPoint:
            // begin wall placement
            
            guard let planeData = anyPlaneFrom(location: location) else { return }
            
            let trackingNode = TrackingNode.node(from: planeData.1,
                                                 to: nil)
            sceneView.scene.rootNode.addChildNode(trackingNode)
            trackState = .findScondPoint(trackingNode: trackingNode,
                                         wallStartPosition: planeData.1,
                                         originAnchor: planeData.2)
        case .findScondPoint(let trackingNode, let wallStartPosition, let originAnchor):
            // finilize wall placement
            
            guard let planeData = anyPlaneFrom(location: self.view.center),
                planeData.2 == originAnchor else { return }
            
            trackingNode.removeFromParentNode()
            let wallNode = Wall.node(from: wallStartPosition,
                                     to: planeData.1)
            sceneView.scene.rootNode.addChildNode(wallNode)
            
            let newTrackingNode = TrackingNode.node(from: planeData.1,
                                                    to: nil)
            trackState = .findScondPoint(trackingNode: newTrackingNode, wallStartPosition: planeData.1, originAnchor: originAnchor)
            
            walls.append((wallNode: wallNode,
                          wallStartPosition: wallStartPosition,
                          wallEndPosition: planeData.1,
                          wallId: UUID().uuidString))
            
        default:fatalError()
        }
    }
    
    private func playingTapped(location:CGPoint) {
        // shoot fireballs _exactly_ from the fireball tip of the carried wand..
        guard !wandIsRecharging else { return }
        
        // the new fireball!
        let fireballNode = Beachball.node()
        fireballNode.name = UUID().uuidString
        
        sceneView.scene.rootNode.addChildNode(fireballNode)
        
        // this way of projecting points from the camera is HEAVYLI
        // inspired from: https://developer.apple.com/videos/play/wwdc2017/602/
        let currentFrame = sceneView.session.currentFrame!
        let n = SCNNode()
        sceneView.scene.rootNode.addChildNode(n)
        
        var closeTranslation = matrix_identity_float4x4
        closeTranslation.columns.3.z = -0.5
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5
        
        n.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        fireballNode.simdTransform = matrix_multiply(currentFrame.camera.transform, closeTranslation)
        
        let direction = (n.position - fireballNode.position).normalized
        
        // fireball should come FROM THE TIP of the wand!
        if let wandNode = sceneView.pointOfView?.childNode(withName: Wand.WAND_NODE_NAME, recursively: false),
            let tipNode = wandNode.childNode(withName: Wand.TIP_NODE_NAME, recursively: false) {
            // all we need to do is to give the fireballNode the right starting position!!
            // use same direction vector
            fireballNode.position = wandNode.convertPosition(tipNode.position, to: sceneView.scene.rootNode)
            wandIsRecharging = true
            wandNode.position.z = -0.2
            wandNode.runAction(SCNAction.moveBy(x: 0, y: 0, z: -0.1, duration: Wand.RECHARGE_TIME))
            tipNode.scale = SCNVector3(0,0,0)
            tipNode.runAction(SCNAction.scale(to: 1, duration: Wand.RECHARGE_TIME)) {
                self.wandIsRecharging = false
            }
        }
        
        fireballNode.physicsBody?.applyForce(direction * Beachball.INITIAL_VELOCITY, asImpulse: true)
        n.removeFromParentNode()
        
        fireballNode.runAction(SCNAction.wait(duration: Beachball.TTL)) {
            fireballNode.removeFromParentNode()
        }
    }
    
    private func updateWallTracking() {
        guard case .findScondPoint(let trackingNode, let wallStartPosition, let originAnchor) = trackState,
            let planeData = anyPlaneFrom(location: self.view.center),
            planeData.2 == originAnchor else { return }
        
        trackingNode.removeFromParentNode()
        let newTrackingNode = TrackingNode.node(from: wallStartPosition,
                                                to: planeData.1)
        sceneView.scene.rootNode.addChildNode(newTrackingNode)
        trackState = .findScondPoint(trackingNode: newTrackingNode,
                                     wallStartPosition: wallStartPosition,
                                     originAnchor: originAnchor)
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let lightEstimate = sceneView.session.currentFrame?.lightEstimate,
            let ambientLight = ambientLightNode?.light {
            ambientLight.temperature = lightEstimate.ambientColorTemperature
            ambientLight.intensity = lightEstimate.ambientIntensity
        }
        
        //TODO: DO NOT do this for every frame, that is kind of crazy. Do it via a timer!
        DispatchQueue.main.async(execute: updateWallTracking)
    }
    
    // MARK: - SCNPhysicsContactDelegate
    
}

