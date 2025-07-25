//
//  DrawingDataFetcher.swift
//  ARMuseumApp
//
//  Created by Liam Moseley on 14/05/2024.
//

import Foundation
import SceneKit
import ARKit

class ARPanel {
    
    let sceneView: ARSCNView
    var panelText: String
    var parentNode: SCNNode
    var currentGeometry: SCNBox
    var displayActive = false
    var panelNodeInScene = false
    
    let panelSides = SCNMaterial()
    let transparentPanelFace = SCNMaterial()
    
    var textNode: SCNNode
    let iconNode: SCNNode
    let iconImage: UIImage
    var iconCurrentLocation = SCNVector3(x: 0.0, y: 0.0, z: 0.0051)
    var iconCurrentScale = SCNVector3(x: 1.0, y: 1.0, z: 1.0)
    
    var deleteButtonNode = SCNNode()
    var editButtonNode = SCNNode()
    
    init(position: SCNVector3, scene: ARSCNView, text: String, panelColor: UIColor, panelIcon: String) {
        self.panelText = text
        self.currentGeometry = SCNBox(width: 0.05, height: 0.05, length: 0.01, chamferRadius: 1)
        
        transparentPanelFace.diffuse.contents = UIColor(red: 172, green: 172, blue: 172, alpha: 0.9)
        panelSides.diffuse.contents = panelColor
        
        currentGeometry.materials = [transparentPanelFace, panelSides, panelSides, panelSides, panelSides, panelSides]
        
        self.parentNode = SCNNode(geometry: currentGeometry)
        self.parentNode.position = position
        
        self.textNode = createTextNode(text: "", fontSize: 1, color: UIColor.black)
        
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
        parentNode.addChildNode(editButtonNode)
        
        makePanelFaceCamera()
        createDeleteButton()
        createEditButton()
        print("Test - Init panel")
    }
    
    func addToScene() {
        sceneView.scene.rootNode.addChildNode(parentNode)
        panelNodeInScene = true
        displayActive = true
        print("Add to scene")
    }
    
    func makePanelFaceCamera() {
        let followCameraConstraint = SCNBillboardConstraint()
        followCameraConstraint.freeAxes = SCNBillboardAxis.Y
        parentNode.constraints = [followCameraConstraint]
    }
    
    func handleTap() {
        if (!displayActive) {
            displayActive = true
            animatePanel(panelNode: parentNode, currentGeometry: currentGeometry, targetGeometry: SCNBox(width: 0.26, height: 0.1, length: 0.04, chamferRadius: 1))
        }
        else {
            displayActive = false
            animatePanel(panelNode: parentNode, currentGeometry: currentGeometry, targetGeometry: SCNBox(width: 0.05, height: 0.05, length: 0.01, chamferRadius: 1))
        }
    }
    
    func editModeToggle() {
        deleteButtonNode.isHidden.toggle()
        editButtonNode.isHidden.toggle()
    }
    
    func createDeleteButton() {
        let deleteButtonGeometry = SCNBox(width: 0.013, height: 0.013, length: 0.008, chamferRadius: 1)
        deleteButtonGeometry.materials = [transparentPanelFace, panelSides, panelSides, panelSides, panelSides, panelSides]
        deleteButtonNode.geometry = deleteButtonGeometry
        deleteButtonNode.position = SCNVector3(x: 0.025, y: 0.025, z: 0.003)
        
        let deleteImage = UIImage(systemName: "xmark.bin.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 128))
        let deleteIconMaterial = SCNMaterial()
        deleteIconMaterial.diffuse.contents = deleteImage
        let deleteIconGeometry = SCNPlane(width: 0.009, height: 0.009)
        deleteIconGeometry.materials = [deleteIconMaterial]
        
        deleteButtonNode.geometry = deleteButtonGeometry
        let deleteIconNode = SCNNode(geometry: deleteIconGeometry)
        deleteIconNode.position = SCNVector3(x: 0, y: 0, z: 0.0045)
        
        deleteButtonNode.isHidden = true
        
        parentNode.addChildNode(deleteButtonNode)
        deleteButtonNode.addChildNode(deleteIconNode)
    }
    
    func createEditButton() {
        let editButtonGeometry = SCNBox(width: 0.013, height: 0.013, length: 0.008, chamferRadius: 1)
        editButtonGeometry.materials = [transparentPanelFace, panelSides, panelSides, panelSides, panelSides, panelSides]
        editButtonNode.geometry = editButtonGeometry
        editButtonNode.position = SCNVector3(x: 0.012, y: 0.025, z: 0.003)
        
        let editImage = UIImage(systemName: "slider.horizontal.2.square.on.square", withConfiguration: UIImage.SymbolConfiguration(pointSize: 128))
        let editIconMaterial = SCNMaterial()
        editIconMaterial.diffuse.contents = editImage
        let editIconGeometry = SCNPlane(width: 0.009, height: 0.009)
        editIconGeometry.materials = [editIconMaterial]
        
        editButtonNode.geometry = editButtonGeometry
        let editIconNode = SCNNode(geometry: editIconGeometry)
        editIconNode.position = SCNVector3(x: 0, y: 0, z: 0.0045)
        
        editButtonNode.isHidden = true
        
        parentNode.addChildNode(editButtonNode)
        editButtonNode.addChildNode(editIconNode)
    }
    
    func animatePanel(panelNode: SCNNode, currentGeometry: SCNBox, targetGeometry: SCNBox) {
        let sideButtonTargetGeometry: SCNBox
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0

        if (displayActive) {
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { [self] _ in
                self.editTextNode(text: panelText, fontSize: 5, color: UIColor.black)
            }
            iconCurrentLocation = SCNVector3(x: -0.08, y: 0.0, z: 0.021)
            iconCurrentScale = SCNVector3(x: 1.4, y: 1.4, z: 1.4)

            // Move buttons to the top-right when enlarged
            deleteButtonNode.position = SCNVector3(x: 0.11, y: 0.05, z: 0.003)
            editButtonNode.position = SCNVector3(x: 0.08, y: 0.05, z: 0.003)
            
            sideButtonTargetGeometry = SCNBox(width: 0.020, height: 0.020, length: 0.012, chamferRadius: 1)
        }
        else {
            editTextNode(text: "", fontSize: 1, color: UIColor.black)
            iconCurrentLocation = SCNVector3(x: 0.0, y: 0.0, z: 0.0051)
            iconCurrentScale = SCNVector3(x: 1.0, y: 1.0, z: 1.0)

            // Move buttons back to their original position
            deleteButtonNode.position = SCNVector3(x: 0.025, y: 0.025, z: 0.003)
            editButtonNode.position = SCNVector3(x: 0.012, y: 0.025, z: 0.003)
            
            sideButtonTargetGeometry = SCNBox(width: 0.013, height: 0.013, length: 0.008, chamferRadius: 1)
        }

        // Update panel size
        currentGeometry.width = targetGeometry.width
        currentGeometry.height = targetGeometry.height
        currentGeometry.length = targetGeometry.length
        currentGeometry.chamferRadius = targetGeometry.chamferRadius

        panelNode.geometry = currentGeometry
        iconNode.position = iconCurrentLocation
        iconNode.scale = iconCurrentScale

        SCNTransaction.commit()
    }

    func editTextNode(text: String, fontSize: CGFloat, color: UIColor) {
        let titleGeometry = textNode.geometry as? SCNText
        titleGeometry?.string = text
    }
}
