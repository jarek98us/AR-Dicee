//
//  ViewController.swift
//  AR Dicee
//
//  Created by Jarek on 27/03/2018.
//  Copyright © 2018 Jarek. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        // sceneView.scene = scene
        
        // let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let sphere = SCNSphere(radius: 0.3)
//
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "art.scnassets/2k_jupiter.jpg")
        //cube.materials = [material]
//        sphere.materials = [material]
//
//        let node = SCNNode()
//        node.position = SCNVector3(x: 0, y: 0.1, z: -1.0)
//        node.geometry = sphere
//
//        sceneView.scene.rootNode.addChildNode(node)
//        sceneView.autoenablesDefaultLighting = true
        
        // New Dice
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
//            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
//            sceneView.scene.rootNode.addChildNode(diceNode)
//        }
//        
//        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (ARWorldTrackingConfiguration.isSupported) {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            
            sceneView.session.run(configuration)
        } else {
            let configuration = AROrientationTrackingConfiguration()
            sceneView.session.run(configuration)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y:0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [material]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
            print("Plane detected")
        }
    }
    
    func addDice(x: Float, y: Float, z: Float) {
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(x: x, y: y + diceNode.boundingSphere.radius, z: z)
            sceneView.scene.rootNode.addChildNode(diceNode)
            diceArray.append(diceNode)
            
            rollDice(dice: diceNode)
        }
    }
    
    func rollDice(dice: SCNNode) {
        
        let rotations = arc4random_uniform(5) + 2
        let randomX = CGFloat(Float(arc4random_uniform(4) + 1) * (Float.pi / 2)) * CGFloat(rotations)
        let randomZ = CGFloat(Float(arc4random_uniform(4) + 1) * (Float.pi / 2)) * CGFloat(rotations)
        
        let duration = 0.2 * Double(rotations)
        
        dice.runAction(
            SCNAction.rotateBy(x: randomX, y: 0, z: randomZ, duration: duration)
        )
    }
    
    func rollAll() {
        if diceArray.isEmpty {
            return
        }
        
        for dice in diceArray {
            rollDice(dice: dice)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let result = results.first {
                addDice(x: result.worldTransform.columns.3.x,
                          y: result.worldTransform.columns.3.y,
                          z: result.worldTransform.columns.3.z)
                
                print("Touches the plane at: \(result)")
            }
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if (motion == .motionShake) {
            rollAll()
        }
    }
    
    @IBAction func refreshDices(_ sender: Any) {
        rollAll()
    }
    
    @IBAction func clearDicesButtonClicked(_ sender: Any) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
            
            diceArray.removeAll()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
