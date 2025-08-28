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
    @Published var isDrawingMode = false
    @Published var currentRoom: String = nil

    func setupARView(_ arView: ARSCNView, panelController: ARPanelController) {
        self.arView = arView
        self.panelController = panelController
    }

    func toggleDrawingMode() {
            isDrawingMode.toggle()
        }
    
    func addPanel(text: String, panelColor: UIColor, panelIcon: String) {
        guard let arView = arView, let pointOfView = arView.pointOfView else {
            print("Error: ARSCNView or pointOfView is nil")
            return
        }

        // Get the camera transform
        let cameraTransform = pointOfView.transform

        // Camera's forward direction
        let forward = SCNVector3(-cameraTransform.m31, -cameraTransform.m32, -cameraTransform.m33)

        // Camera's current position
        let cameraPosition = SCNVector3(cameraTransform.m41, cameraTransform.m42, cameraTransform.m43)

        // Distance in front of the camera to place the panel
        let distance: Float = 0.5

        // Calculate final position
        let position = SCNVector3(
            cameraPosition.x + forward.x * distance,
            cameraPosition.y + forward.y * distance,
            cameraPosition.z + forward.z * distance
        )

        // Create and add the panel
        let newPanel = ARPanel(position: position, scene: arView, text: text, panelColor: panelColor, panelIcon: panelIcon)

        if sessionRunning {
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
        currentRoom = posterName

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
        currentRoom = nil
        
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
