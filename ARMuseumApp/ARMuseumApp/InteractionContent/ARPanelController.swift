//
//  ARPanelController.swift
//  ARPaint
//
//  Created by Liam Moseley on 14/05/2024.
//

import ARKit

class ARPanelController {
    @Published var panelsInScene: [ARPanel] = []
    var diningRoomPanels: [ARPanel] = []
    var kitchenRoomPanels: [ARPanel] = []
    
    var playerCameraCoords = SCNVector3(0,0,0)
    var entranceNodePosition = SCNVector3(0,0,0)
    
    var originPlaneNode = SCNNode()
    
    func roomSetup(sceneView: ARSCNView) {
        // 1️⃣ Get current camera transform
        guard let camera = sceneView.session.currentFrame?.camera else { return }
        let cameraTransform = camera.transform

        // 2️⃣ Create the plane
        let plane = SCNPlane(width: 0.1, height: 0.1)
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        let planeNode = SCNNode(geometry: plane)

        // 3️⃣ Position the plane 0.5 meters in front of the camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.5  // negative Z is forward in camera space
        planeNode.simdTransform = matrix_multiply(cameraTransform, translation)

        // 4️⃣ Rotate plane to lie flat (if needed)
        planeNode.eulerAngles.x = -Float.pi / 2

        // 5️⃣ Add plane to the scene
        sceneView.scene.rootNode.addChildNode(planeNode)
        originPlaneNode = planeNode

        // 6️⃣ Optional: create entrance node near camera
        let entranceNodeUserSpace = SCNNode()
        entranceNodeUserSpace.simdTransform = cameraTransform
        entranceNodeUserSpace.position.z += 0.05
        self.entranceNodePosition = entranceNodeUserSpace.position
        sceneView.scene.rootNode.addChildNode(entranceNodeUserSpace)
    }

    
    func enableAllPanels() {
        for panel in panelsInScene{
            originPlaneNode.addChildNode(panel.parentNode)
            panel.displayActive = true
        }
    }
    
    func enablePanelsForRoom(roomPanels: [ARPanel]) {
        for panel in roomPanels {
            panelsInScene.append(panel)
        }
        
        for panel in panelsInScene {
            originPlaneNode.addChildNode(panel.parentNode)
            panel.displayActive = true
        }
    }
    
    func removePanelsInScene() {
        for panel in panelsInScene {
            panel.parentNode.removeFromParentNode()
            panel.panelNodeInScene = false
        }
        panelsInScene.removeAll()
    }
}
