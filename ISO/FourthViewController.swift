//
//  ViewController.swift
//  ISO
//
//  Created by Denis Protopopov on 02.05.2020.
//  Copyright © 2020 Denis Protopopov. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class FourthViewController: UIViewController {

   
    @IBOutlet weak var sceneView: ARSCNView!
    var runloopCoreMLUpdate = true
    var runupdateCoreML = true
    private var serialQueue = DispatchQueue(label: "dispatchqueueml")
        private var visionRequests = [VNRequest]()
        let object = SCNScene(named: "art.scnassets/portal4.scn")!.rootNode.clone()
   

    }
        
    // MARK: - Lifecycle
    extension FourthViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
           
            func setUpCoachingOverlay() {
                let coachingOverlay = ARCoachingOverlayView()
                coachingOverlay.session = sceneView.session
                coachingOverlay.delegate = self as? ARCoachingOverlayViewDelegate
                coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
                sceneView.addSubview(coachingOverlay)
                
                NSLayoutConstraint.activate([
                    coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
                    coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
                ])
               
                coachingOverlay.activatesAutomatically = true
                coachingOverlay.goal = .horizontalPlane
                
            }
            func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {}
            func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {}
              //  self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
              //  ARSCNDebugOptions.showFeaturePoints]
            setupAR()
            setUpCoachingOverlay()
            UIApplication.shared.isIdleTimerDisabled = true
                
            }
            func punchTheClown() {
                
                sceneView?.session.pause()
                sceneView?.removeFromSuperview()
                sceneView = nil
                runloopCoreMLUpdate = false
                runupdateCoreML = false

            }
            
            override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                punchTheClown()
                UIApplication.shared.isIdleTimerDisabled = false
            }
    }
    // MARK: - Setup
    extension FourthViewController {
       
        private func setupAR() {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
            sceneView.addGestureRecognizer(tapGestureRecognizer)
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            sceneView.session.run(configuration)
        }
        
        
    }
    // MARK: - Private
    extension FourthViewController {
        @objc func tapped(recognizer: UIGestureRecognizer) {
            
      
            let location = recognizer.location(in: sceneView)
            let hitTest = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
            let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
           
            let r=hitTest.first
            
            if hitTest.isEmpty {
                print("No Plane Detected")
                print("Continue Detection")
                return
                
            } else {
                
               // SCNVector3(x: hitResult.worldTransform.columns.3.x, y: //hitResult.worldTransform.columns.3.y + 0.05, z: hitResult.worldTransform.columns.3.z)
                
               //let columns = hitTest.first?.worldTransform.columns.3
                //object.position = SCNVector3(x: columns!.x, y: columns!.y, z: columns!.z+1)
             
                let rotateTransform = simd_mul(r!.worldTransform, rotate)

                object.transform =  SCNMatrix4(m11: rotateTransform.columns.0.x, m12: rotateTransform.columns.0.y, m13: rotateTransform.columns.0.z, m14: rotateTransform.columns.0.w, m21: rotateTransform.columns.1.x, m22: rotateTransform.columns.1.y, m23: rotateTransform.columns.1.z, m24: rotateTransform.columns.1.w, m31: rotateTransform.columns.2.x, m32: rotateTransform.columns.2.y, m33: rotateTransform.columns.2.z, m34: rotateTransform.columns.2.w, m41: rotateTransform.columns.3.x, m42: rotateTransform.columns.3.y, m43: rotateTransform.columns.3.z, m44: rotateTransform.columns.3.w)
            //   let min = object.boundingBox.min
          //  let max = object.boundingBox.max
               object.pivot = SCNMatrix4MakeTranslation(
                  0,
                   0,
                 -2
               )
                
              
                    
                
                
               if let source = SCNAudioSource(fileNamed: "portal_speak4.mp3")
               {
                   source.volume = 2
                   source.isPositional = true
                   source.shouldStream = true
                   source.loops = false
                   source.load()
                    
                   let player = SCNAudioPlayer(source: source)
                    object.removeAllAudioPlayers()
                   object.addAudioPlayer(player)
               }
                self.sceneView.scene.rootNode.addChildNode(object)
                sceneView.autoenablesDefaultLighting = false
                
            }
            
        }
        
     
        
    }

