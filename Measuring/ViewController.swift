//
//  ViewController.swift
//  Measuring
//
//  Created by JiniGuruiOS on 26/07/19.
//  Copyright © 2019 jiniguru. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController {

    @IBOutlet weak var lblZ: UILabel!
    @IBOutlet weak var lblY: UILabel!
    @IBOutlet weak var lblX: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var scenView: ARSCNView!
  
    var startingPosition:SCNNode?
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scenView.debugOptions = [.showWorldOrigin,.showFeaturePoints]
        self.scenView.session.run(configuration)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(sender:)))
        self.scenView.addGestureRecognizer(tapGesture)
        self.scenView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @objc func handleTap(sender:UITapGestureRecognizer){
        guard let scenView = sender.view as? ARSCNView else {
            return
        }
        let currentFrame = scenView.session.currentFrame
        let camera = currentFrame?.camera
        let transform = camera?.transform
        var transformMatrix = matrix_identity_float4x4
        transformMatrix.columns.3.z = -0.1
        let modifyMatrix = simd_mul(transform!, transformMatrix)
        
        if self.startingPosition != nil {
            self.startingPosition?.removeFromParentNode()
            self.startingPosition = nil
        }
        
        let sphereNode = SCNNode.init(geometry: SCNSphere(radius: 0.005))
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        sphereNode.simdTransform = modifyMatrix
        self.startingPosition = sphereNode
        self.scenView.scene.rootNode.addChildNode(sphereNode)
    }
    
    func distanceTraveld(x:Float,y:Float,z:Float) -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
}

//MARK : - SCNView Delegate -
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let pointOfView = self.scenView.pointOfView else {
            return
        }
        
        guard self.startingPosition != nil else {
            return
        }
        
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let xDistance = location.x - (self.startingPosition?.position.x ?? 0)
        let yDistance = location.y - (self.startingPosition?.position.y ?? 0)
        let zDistance = location.z - (self.startingPosition?.position.z ?? 0)
        
        DispatchQueue.main.async {
            self.lblX.text = String(format: "%.2f m", xDistance)
            self.lblY.text = String(format: "%.2f m", yDistance)
            self.lblZ.text = String(format: "%.2f m", zDistance)
            self.lblDistance.text = String(format: "%.2f", self.distanceTraveld(x: xDistance, y: yDistance, z: zDistance))
        }
    }
}
