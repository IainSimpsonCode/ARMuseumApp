//
//  ShadowPanel.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 23/01/2025.
//

import Foundation
import SceneKit
import ARKit

class ShadowPanel {
    
    let sceneView: ARSCNView
    var panelText: String
    var parentNode: SCNNode
    var currentGeometry: SCNBox
    
    let panelSides = SCNMaterial()
    let transparentPanelFace = SCNMaterial()
    
    var textNode: SCNNode
    var iconNode: SCNNode
    let iconImage: UIImage
    var iconCurrentLocation = SCNVector3(x: 0.0, y: 0.0, z: 0.0051)
    var iconCurrentScale = SCNVector3(x: 1.0, y: 1.0, z: 1.0)
    
    var panelToChnage: ARPanel?
    var shadowPanelChoice: Int = 0
    
    init(position: SCNVector3, scene: ARSCNView, text: String, panelColor: UIColor, panelIcon: String) {
        self.panelText = text
        self.currentGeometry = SCNBox(width: 0.05, height: 0.05, length: 0.01, chamferRadius: 1)
        
        transparentPanelFace.diffuse.contents = UIColor(red: 172, green: 172, blue: 172, alpha: 0.9)
        panelSides.diffuse.contents = panelColor
        
        currentGeometry.materials = [transparentPanelFace, panelSides, panelSides, panelSides, panelSides, panelSides]
        
        self.parentNode = SCNNode(geometry: currentGeometry)
        self.parentNode.position = position
        
        self.textNode = createTextNode(text: "Move me to where \n you feel i best fit!", fontSize: 1, color: UIColor.black)
        
        let mainIconMaterial = SCNMaterial()
        iconImage = UIImage(systemName: panelIcon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 128))!
        mainIconMaterial.diffuse.contents = iconImage
        
        let iconGeometry = SCNPlane(width: 0.03, height: 0.03)
        iconGeometry.materials = [mainIconMaterial]
        
        self.iconNode = SCNNode(geometry: iconGeometry)
        iconNode.position = iconCurrentLocation
        
        self.sceneView = scene
        parentNode.addChildNode(textNode)
        parentNode.addChildNode(iconNode)
        
        makePanelFaceCamera()
        print("Test - Init Shadow panel")
    }
    
    func makePanelFaceCamera() {
        let followCameraConstraint = SCNBillboardConstraint()
        followCameraConstraint.freeAxes = SCNBillboardAxis.Y
        parentNode.constraints = [followCameraConstraint]
    }
    
    func addToScene() {
        sceneView.scene.rootNode.addChildNode(parentNode)
        print("Add to scene")
    }
    
    func makePanelStayInFrontOfUser(distance: Float = 0.5) {
        guard let pointOfView = sceneView.pointOfView else {
            print("Error: Unable to get pointOfView")
            return
        }
        
        sceneView.scene.rootNode.runAction(SCNAction.repeatForever(SCNAction.customAction(duration: 0) { _, _ in
            // Get camera position and forward direction
            let cameraTransform = pointOfView.transform
            let cameraPosition = SCNVector3(cameraTransform.m41, cameraTransform.m42, cameraTransform.m43)
            let cameraDirection = SCNVector3(-cameraTransform.m31, -cameraTransform.m32, -cameraTransform.m33)
            
            // Calculate new position
            let newPosition = SCNVector3(
                cameraPosition.x + cameraDirection.x * distance,
                cameraPosition.y + cameraDirection.y * distance,
                cameraPosition.z + cameraDirection.z * distance
            )
            
            // Smoothly update the panel's position
            self.parentNode.position = newPosition
        }))
    }
    
    func shadowPanelAction(){
        if(shadowPanelChoice == 1){
            panelToChnage!.parentNode.worldPosition = parentNode.worldPosition
            parentNode.removeFromParentNode()
        }
        else if(shadowPanelChoice == 2){
            parentNode.removeFromParentNode()
        }
        else {
            print("This Shoulnt Run")
        }
    }



}
