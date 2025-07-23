//
//  ButtonFunctions.swift
//  ARMuseumApp
//
//  Created by Liam Moseley on 31/07/2024.
//

import ARKit

class ButtonFunctions: ObservableObject {
    var arView: ARSCNView?
    var panelController: ARPanelController?
    var shadowPanel: ShadowPanel?
    @Published var sessionRunning: Bool = false
    @Published var editModeActive: Bool = false
    @Published var movementModeBool: Bool = true
    @Published var movingPanel: Bool = false
    @Published var tutorialVisible: Bool = false
    

    func setupARView(_ arView: ARSCNView, panelController: ARPanelController) {
        self.arView = arView
        self.panelController = panelController
    }

    func addPanel(text: String, panelColor: UIColor, panelIcon: String) {
        let newPanel = ARPanel(position: SCNVector3(x: 0, y: 0, z: -0.1), scene: arView!, text: text, panelColor: panelColor, panelIcon: panelIcon)
        if(sessionRunning) {
            newPanel.addToScene()
        }
        panelController?.panelsInScene.append(newPanel)
        panelController?.diningRoomPanels.append(newPanel)
        
    }

    func captureImage() -> UIImage? {
        guard let arView = arView else {
            print("Error: ARSCNView is nil")
            return nil
        }
        
        let image = arView.snapshot()
        
        return image
    }

    func startDrawing() {
        
    }
    
    func startSession(node: SCNNode, posterName: String) {
        sessionRunning = true
        print("WOMP")
        panelController!.roomSetup(imageNode: node, sceneView: arView!)
        
        if(posterName == "Viva Exhibit Display") {
            panelController!.enablePanelsForRoom(roomPanels: panelController!.diningRoomPanels)
            print("for")
        }
        else if(posterName == "KitchenRoomPoster") {
            panelController!.enablePanelsForRoom(roomPanels: panelController!.kitchenRoomPanels)
            print("Loop")
        }
        else {
            print("No Corresponding Room")
        }
    }
    
    func refreshSession() {
        for panel in panelController!.panelsInScene {
            panel.parentNode.removeFromParentNode()
            panel.panelNodeInScene = false
        }
        panelController?.enableAllPanels()
    }
    
    func endSession() {
        sessionRunning = false
        
        panelController?.removePanelsInScene()
        resetARSession()
    }
    
    func resetARSession() {
        let configuration = ARWorldTrackingConfiguration()
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
        configuration.detectionImages = referenceImages
        arView!.session.run(configuration, options: [.removeExistingAnchors])
    }
    
    func toggleEditMode() {
        editModeActive.toggle()
        for panel in panelController!.panelsInScene {
            panel.editModeToggle()
        }
    }
    
    func movePanelButtons(option: Int){
        shadowPanel?.shadowPanelChoice = option
        shadowPanel?.shadowPanelAction()
    }
}
