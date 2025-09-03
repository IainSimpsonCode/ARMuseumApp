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
    var displayActive = true
    var panelState: Int
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
    var moveButtonNode = SCNNode()
    
    let currentRoom: String
    let id: Int
    let panelIconName: String
    
    var isTemporarilyExpanded = false

    init(position: SCNVector3, scene: ARSCNView, text: String, panelColor: UIColor, panelIcon: String, id: Int, currentRoom: String) {
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
        
        self.currentRoom = currentRoom
        self.id = id
        
        self.displayActive = true // expanded at start
        self.panelState = 2
        self.panelIconName = panelIcon
        
        makePanelFaceCamera()
        createDeleteButton()
        createEditButton()
        createMoveButton()
        
    }
    
    func addToScene() {
        sceneView.scene.rootNode.addChildNode(parentNode)
        panelNodeInScene = true
        displayActive = true
        animatePanel(panelNode: parentNode, currentGeometry: currentGeometry, targetGeometry: SCNBox(width: 0.26, height: 0.1, length: 0.04, chamferRadius: 1))
    }
    
    func makePanelFaceCamera() {
        let followCameraConstraint = SCNBillboardConstraint()
        followCameraConstraint.freeAxes = SCNBillboardAxis.Y
        parentNode.constraints = [followCameraConstraint]
    }
    
    func changePanelSize(size : Int) {
        if (size == 2) {
            displayActive = true
            panelState = 2
            animatePanel(panelNode: parentNode, currentGeometry: currentGeometry, targetGeometry: SCNBox(width: 0.26, height: 0.1, length: 0.04, chamferRadius: 1))
            iconNode.isHidden = false
        }
        else if(size == 1) {
            displayActive = false
            panelState = 1
            animatePanel(panelNode: parentNode, currentGeometry: currentGeometry, targetGeometry: SCNBox(width: 0.05, height: 0.05, length: 0.01, chamferRadius: 1))
            iconNode.isHidden = false
        }
        else{
            displayActive = false
            panelState = 0
            animatePanel(panelNode: parentNode, currentGeometry: currentGeometry, targetGeometry: SCNBox(width: 0.05, height: 0.00, length: 0.00, chamferRadius: 0))
            iconNode.isHidden = true
        }
    }
    
    
    func editModeToggle() {
        deleteButtonNode.isHidden.toggle()
        editButtonNode.isHidden.toggle()
        moveButtonNode.isHidden.toggle()
    }
    
    func createDeleteButton() {
        let buttonSize: CGFloat = 0.025
        let iconSize: CGFloat = 0.018
        let chamfer: CGFloat = 0.003

        let deleteButtonGeometry = SCNBox(width: buttonSize, height: buttonSize, length: 0.005, chamferRadius: chamfer)
        deleteButtonGeometry.materials = [transparentPanelFace, panelSides, panelSides, panelSides, panelSides, panelSides]

        deleteButtonNode.geometry = deleteButtonGeometry
        deleteButtonNode.position = SCNVector3(x: 0.035, y: 0.025, z: 0.01) // increased z
        deleteButtonNode.isHidden = true

        // Icon
        let deleteImage = UIImage(systemName: "xmark.bin.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 256, weight: .bold))
        let deleteIconMaterial = SCNMaterial()
        deleteIconMaterial.diffuse.contents = deleteImage
        deleteIconMaterial.isDoubleSided = true

        let deleteIconGeometry = SCNPlane(width: iconSize, height: iconSize)
        deleteIconGeometry.materials = [deleteIconMaterial]

        let deleteIconNode = SCNNode(geometry: deleteIconGeometry)
        deleteIconNode.position = SCNVector3(x: 0, y: 0, z: 0.003) // relative to button
        deleteButtonNode.addChildNode(deleteIconNode)

        parentNode.addChildNode(deleteButtonNode)
    }

    func createEditButton() {
        let buttonSize: CGFloat = 0.025
        let iconSize: CGFloat = 0.018
        let chamfer: CGFloat = 0.003

        let editButtonGeometry = SCNBox(width: buttonSize, height: buttonSize, length: 0.005, chamferRadius: chamfer)
        editButtonGeometry.materials = [transparentPanelFace, panelSides, panelSides, panelSides, panelSides, panelSides]

        editButtonNode.geometry = editButtonGeometry
        editButtonNode.position = SCNVector3(x: 0.01, y: 0.025, z: 0.01)
        editButtonNode.isHidden = true

        // Icon
        let editImage = UIImage(systemName: "slider.horizontal.2.square.on.square", withConfiguration: UIImage.SymbolConfiguration(pointSize: 256, weight: .bold))
        let editIconMaterial = SCNMaterial()
        editIconMaterial.diffuse.contents = editImage
        editIconMaterial.isDoubleSided = true

        let editIconGeometry = SCNPlane(width: iconSize, height: iconSize)
        editIconGeometry.materials = [editIconMaterial]

        let editIconNode = SCNNode(geometry: editIconGeometry)
        editIconNode.position = SCNVector3(x: 0, y: 0, z: 0.003)
        editButtonNode.addChildNode(editIconNode)

        parentNode.addChildNode(editButtonNode)
    }
        
    func createMoveButton() {
        let buttonSize: CGFloat = 0.025
        let iconSize: CGFloat = 0.018
        let chamfer: CGFloat = 0.003

        let moveButtonGeometry = SCNBox(width: buttonSize, height: buttonSize, length: 0.005, chamferRadius: chamfer)
        moveButtonGeometry.materials = [transparentPanelFace, panelSides, panelSides, panelSides, panelSides, panelSides]

        moveButtonNode.geometry = moveButtonGeometry
        moveButtonNode.position = SCNVector3(x: 0.075, y: 0.025, z: 0.01)
        moveButtonNode.isHidden = true

        // Icon
        let moveImage = UIImage(systemName: "arrow.up.and.down.and.arrow.left.and.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 256, weight: .bold))
        let moveIconMaterial = SCNMaterial()
        moveIconMaterial.diffuse.contents = moveImage
        moveIconMaterial.isDoubleSided = true

        let moveIconGeometry = SCNPlane(width: iconSize, height: iconSize)
        moveIconGeometry.materials = [moveIconMaterial]

        let moveIconNode = SCNNode(geometry: moveIconGeometry)
        moveIconNode.position = SCNVector3(x: 0, y: 0, z: 0.003)
        moveButtonNode.addChildNode(moveIconNode)

        parentNode.addChildNode(moveButtonNode)
    }

    
    func animatePanel(panelNode: SCNNode, currentGeometry: SCNBox, targetGeometry: SCNBox) {
        let sideButtonTargetGeometry: SCNBox
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0

        if (panelState == 2) {
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { [self] _ in
                self.editTextNode(text: panelText, fontSize: 5, color: UIColor.black)
            }
            iconCurrentLocation = SCNVector3(x: -0.08, y: 0.0, z: 0.021)
            iconCurrentScale = SCNVector3(x: 1.4, y: 1.4, z: 1.4)

            // Move buttons to the top-right when enlarged
            deleteButtonNode.position = SCNVector3(x: 0.11, y: 0.05, z: 0.025)
            editButtonNode.position = SCNVector3(x: 0.08, y: 0.05, z: 0.025)
            moveButtonNode.position = SCNVector3(x: 0.05, y: 0.05, z: 0.025)
            
            sideButtonTargetGeometry = SCNBox(width: 0.020, height: 0.020, length: 0.012, chamferRadius: 1)
        }
        else if (panelState == 1 || panelState == 0) {
            editTextNode(text: "", fontSize: 1, color: UIColor.black)
            iconCurrentLocation = SCNVector3(x: 0.0, y: 0.0, z: 0.0051)
            iconCurrentScale = SCNVector3(x: 1.0, y: 1.0, z: 1.0)

            // Move buttons back to their original position
            deleteButtonNode.position = SCNVector3(x: 0.025, y: 0.025, z: 0.003)
            editButtonNode.position = SCNVector3(x: 0.012, y: 0.025, z: 0.003)
            
            sideButtonTargetGeometry = SCNBox(width: 0.013, height: 0.013, length: 0.008, chamferRadius: 1)
        }
        else if panelState == 3 {
            // Bigger panel to show more text
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { [self] _ in
                self.editTextNode(text: panelText, fontSize: 6, color: UIColor.black)
            }
            
            iconCurrentLocation = SCNVector3(x: -0.1, y: 0.0, z: 0.025)
            iconCurrentScale = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
            
            // Move buttons to top-right
            deleteButtonNode.position = SCNVector3(x: 0.15, y: 0.07, z: 0.03)
            editButtonNode.position = SCNVector3(x: 0.12, y: 0.07, z: 0.03)
            moveButtonNode.position = SCNVector3(x: 0.08, y: 0.07, z: 0.03)
            
            sideButtonTargetGeometry = SCNBox(width: 0.025, height: 0.025, length: 0.015, chamferRadius: 1)
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
    
    func getWorldPosition() -> SCNVector3 {
        return parentNode.worldPosition
    }

}

