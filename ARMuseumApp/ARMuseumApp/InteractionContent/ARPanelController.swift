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
    
    func roomSetup(imageNode: SCNNode, sceneView: ARSCNView) {
        let plane = SCNPlane(width: 0.1, height: 0.1)
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        let planeNode = SCNNode(/*geometry: plane*/)
        planeNode.eulerAngles.x = -Float.pi / 2
        imageNode.addChildNode(planeNode)
        originPlaneNode = planeNode
        
        let entranceNodeUserSpace = SCNNode()
        entranceNodeUserSpace.position = self.playerCameraCoords
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
