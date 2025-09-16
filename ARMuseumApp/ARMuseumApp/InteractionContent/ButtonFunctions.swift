//
//  ButtonFunctions.swift
//  ARMuseumApp
//
//  Created by Liam Moseley on 31/07/2024.
//

import ARKit
import UIKit

class ButtonFunctions: ObservableObject {
    var arView: ARSCNView?
    var panelController: ARPanelController?
    var shadowPanel: ShadowPanel?
    @Published var sessionRunning: Bool = false
    @Published var SessionSelected: Int = 0
    @Published var editModeActive: Bool = false
    @Published var movementModeBool: Bool = true
    @Published var movingPanel: Bool = false
    @Published var tutorialVisible: Bool = false
    @Published var isDrawingMode = false
    @Published var isEraserMode = false
    @Published var currentRoom: String = ""
    @Published var sessionDetails: SessionDetails
    
    init() {
            // Example initialization with parameters
        self.sessionDetails = SessionDetails(sessionType: 0, museumID: "", roomID: "TestRoom", communitySessionID: 0, isSessionActive: false, panelCreationMode: false)
        }

    func setupARView(_ arView: ARSCNView, panelController: ARPanelController) {
        self.arView = arView
        self.panelController = panelController
    }

    func toggleDrawingMode() {
            isDrawingMode.toggle()
            if isDrawingMode == false{
                isEraserMode = false
            }
        }
    
    func toggleEraserMode() {
            isEraserMode.toggle()
        }
    
    func addPanel(text: String, panelColor: UIColor, panelIcon: String, panelID: String) async {
        guard let arView = arView, let pointOfView = await arView.pointOfView else {
            print("Error: ARSCNView or pointOfView is nil")
            return
        }

        // Get the camera transform
        let cameraTransform = await pointOfView.transform

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
        let newPanel = ARPanel(position: position, scene: arView, text: text, panelColor: panelColor, panelIcon: panelIcon, currentRoom: currentRoom, panelID: panelID)

        if sessionRunning {
            newPanel.addToScene()
        }

        panelController?.panelsInScene.append(newPanel)
        panelController?.diningRoomPanels.append(newPanel)

        var panelToSave = newPanel.convertToPanel(museumID: sessionDetails.museumID, roomID: sessionDetails.roomID)
        
        await PanelStorageManager.savePanel(panel: panelToSave)
    }
    
    func placeLoadedPanel(panel: Panel){
        guard let arView = arView, let pointOfView = arView.pointOfView else {
            print("Error: ARSCNView or pointOfView is nil")
            return
        }
        
        let position = SCNVector3(panel.x, panel.y, panel.z)

        let colour = convertRGBAToUIColor(r: panel.r, g: panel.g, b: panel.b)
        
        // Create and add the panel
        let newPanel = ARPanel(position: position, scene: arView, text: panel.text ??  "", panelColor: colour, panelIcon: panel.icon, currentRoom: currentRoom, panelID: panel.panelID)

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
        currentRoom = ""
        
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

    func getRGB(from color: UIColor) -> (red: Int, green: Int, blue: Int, alpha: Double) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Extract RGBA components
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Convert 0–1 range to 0–255 for RGB
        return (
            red: Int(red * 255),
            green: Int(green * 255),
            blue: Int(blue * 255),
            alpha: Double(alpha)
        )
    }

}
