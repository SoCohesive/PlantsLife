//
//  ViewController.swift
//  PlantsLife
//
//  Created by Sonam Dhingra on 5/20/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SnapKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var targetFindingNode: SCNNode?
    var didTapTarget = false
    var plantBucketNode: SCNNode?
    var didShowBunny = false
    
    var selectedNode: SCNNode?
    var zDepth: Float = 0.0
    var hasDroppedOneTarget = false

    
    private let morphSlider = UISlider(frame: .zero)
    private var lastMorphValue: Float = 0.0
    var stemNode: SCNNode? {
        didSet {
            addMorphSlider()
        }
    }
    
    var leafNode: SCNNode?

    var dropTargetScene: SCNScene {
        return SCNScene(named: "art.scnassets/dropTarget.scn")!
    }
    
    var bucketScene: SCNScene {
        return SCNScene(named: "art.scnassets/bucket.scn")!
    }
    
    var bugsBunnyScene: SCNScene {
        return SCNScene(named: "art.scnassets/bunny_rigged.dae")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        self.registerGestureRecognizers()
        sceneView.debugOptions = [ ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        // Set the scene to the view
        addDropTargetFinding()
    }
    
    private func addMorphSlider() {
        
        self.view.addSubview(morphSlider)
        morphSlider.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-20)
            make.left.equalTo(self.view).offset(30)
            make.right.equalTo(self.view).offset(-30)
        }
        morphSlider.maximumValue = 1.0
        morphSlider.minimumValue = 0.0
        morphSlider.value = 0.0
        morphSlider.addTarget(self, action: #selector(didChangeMorph), for: .valueChanged)
        morphSlider.tintColor = .purple
        
    }
    
    @objc func didChangeMorph() {
        guard let stem = self.stemNode else { return }
        
        let newValue = morphSlider.value
        fadeLeafsIntoScene(with: newValue)
        stem.addMorphingAnimation(morpherIndex: 0, autoreverses: false, duration: 0.4, repeatCount: 0, fromValue: lastMorphValue, newValue: newValue, removedOnCompletion: false)
        lastMorphValue = newValue
    }
    
    func fadeLeafsIntoScene(with newValue: Float) {
        
        guard let leafOneNode = stemNode?.childNode(withName: "LeafOne", recursively: false),
            let leafTwoNode = stemNode?.childNode(withName: "LeafTwo", recursively: false),
            let leafThreeNode = stemNode?.childNode(withName: "LeafThree",  recursively: false) else {
                print("can't get leafs")
                return
        }
        
        let leafs = [leafOneNode, leafTwoNode, leafThreeNode]
        leafs.forEach { leaf in
            SCNTransaction.begin()
            leaf.fade(from: lastMorphValue, to: newValue, with: 1.0)
            SCNTransaction.completionBlock = {
                leaf.opacity = CGFloat(newValue)
            }
            SCNTransaction.commit()
        }
    }
    
    func addDropTargetFinding() {
        guard let targetNode = dropTargetScene.rootNode.childNode(withName: "floor", recursively: true) else {
            print("can't get the node")
            return
        }
        self.sceneView.scene.rootNode.addChildNode(targetNode)
        targetNode.position = SCNVector3(0, 0, -0.2)
        self.targetFindingNode = targetNode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Gestures
    
    func registerGestureRecognizers() {
        
        // Tap
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @objc func didTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        let tapLocation = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(tapLocation, options: nil)
    
        if !hitResults.isEmpty {
            
            guard
                let _ = hitResults.first?.node,
                let plantBucketNode = bucketScene.rootNode.childNode(withName: "Parent", recursively: true),
                let bugsBunnyNode = bugsBunnyScene.rootNode.childNode(withName: "bunny_rigged", recursively: false) else {
                print("did not hit the target node")
                return
            }
            
            plantBucketNode.position = SCNVector3(x: targetFindingNode!.position.x, y: targetFindingNode!.position.y + 0.8, z: targetFindingNode!.position.z)
            
            if !didShowBunny {
            bugsBunnyNode.position =  SCNVector3(x: targetFindingNode!.position.x + 0.3, y: targetFindingNode!.position.y + 1.0, z: targetFindingNode!.position.z)
                bugsBunnyNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: -1.0, z:0), duration: 1.0))
                sceneView.scene.rootNode.addChildNode(bugsBunnyNode)
                didShowBunny = true
            }
            
            plantBucketNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: -1.3, z: 0), duration: 1.0))
            sceneView.scene.rootNode.addChildNode(plantBucketNode)
            self.plantBucketNode = plantBucketNode
            self.didTapTarget = true
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            targetFindingNode?.geometry?.materials.first?.diffuse.contents = UIColor.red
            targetFindingNode?.opacity = CGFloat(0)

            
            SCNTransaction.commit()
            showBranches(on: plantBucketNode)
            
            hasDroppedOneTarget = true

        }
    }
    
   
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first, hasDroppedOneTarget == true else { return }
        
        if let hit = sceneView.hitTest(touch.location(in: sceneView), options: nil).first,
            let hitNodeParent = hit.node.parent, hit.node.parent != targetFindingNode {
            selectedNode = hitNodeParent
            zDepth = sceneView.projectPoint(selectedNode!.position).z
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard selectedNode != nil, let touch = touches.first else { return }
        
        let touchPoint = touch.location(in: sceneView)
        selectedNode?.position = sceneView.unprojectPoint(
            SCNVector3(x: Float(touchPoint.x),
                       y: Float(touchPoint.y),
                       z: zDepth))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedNode = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedNode = nil
    }
    
    
    func showBranches(on bucket: SCNNode) {
        guard let branchNode = plantBucketNode?.childNode(withName: "Stems", recursively: true) else {
            print("can't get the stems from the bucket")
            return
        }
        
        branchNode.morpher?.unifiesNormals = true
        branchNode.morpher?.setWeight(0, forTargetAt: 0)
        self.stemNode = branchNode
    }
    

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        if !self.didTapTarget {
            
            // Get the point of view from the scene view camera
            guard let pointOfView = sceneView.pointOfView, let safeTargetNode = targetFindingNode else {
                return
            }
            // Get the transform of the cmaera
            let transform = pointOfView.transform
            
            // Get the orientation
            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
            
            // Get the location
            let location = SCNVector3(transform.m41, transform.m42,transform.m43)
            
            // Current position = orientation + location
            let currentPositionOfCamera = orientation + location
            
            DispatchQueue.main.async {
                safeTargetNode.position.x = currentPositionOfCamera.x
                safeTargetNode.position.z = currentPositionOfCamera.z
                safeTargetNode.position.y = currentPositionOfCamera.y - 0.2
            }
        }
    }
    
    
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

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    
}
