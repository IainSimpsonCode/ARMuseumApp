//
//  DrawingDataFetcher.swift
//  ARMuseumApp
//
//  Created by Liam Moseley on 14/05/2024.
//

import Foundation
import SceneKit
import ARKit
import SwiftUI

// Helper to split text
extension String {
    func chunked(into size: Int) -> [String] {
        var start = startIndex
        var results = [String]()
        while start < endIndex {
            let end = index(start, offsetBy: size, limitedBy: endIndex) ?? endIndex
            results.append(String(self[start..<end]))
            start = end
        }
        return results
    }
}

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
    var spotlightButtonNode = SCNNode()
    
    let currentRoom: String
    let panelID: String
    let panelIconName: String
    var longText:String
    
    var isTemporarilyExpanded = false
    var spotlight: Bool
    var highlightNode: SCNNode?

    init(position: SCNVector3, scene: ARSCNView, text: String, panelColor: UIColor, panelIcon: String ,currentRoom: String, panelID: String, detailedText: String, spotlight: Bool) {
        self.panelText = text
        self.currentGeometry = SCNBox(width: 0.05, height: 0.05, length: 0.01, chamferRadius: 1)
        
        transparentPanelFace.diffuse.contents = UIColor(red: 172, green: 172, blue: 172, alpha: 0.9)
        panelSides.diffuse.contents = panelColor
        
        currentGeometry.materials = [transparentPanelFace, panelSides, panelSides, panelSides, panelSides, panelSides]
        
        self.parentNode = SCNNode(geometry: currentGeometry)
        self.parentNode.position = position
        
        self.textNode = createTextNode(text: "", fontSize: 1, color: UIColor.black)
        
        let mainIconMaterial = SCNMaterial()
        iconImage = UIImage(
            systemName: panelIcon,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 128)
        ) ?? UIImage(systemName: "questionmark.circle")!
        mainIconMaterial.diffuse.contents = iconImage
        
        let iconGeometry = SCNPlane(width: 0.02, height: 0.02)
        iconGeometry.materials = [mainIconMaterial]
        
        self.iconNode = SCNNode(geometry: iconGeometry)
        iconNode.position = iconCurrentLocation
        
        self.sceneView = scene
        parentNode.addChildNode(textNode)
        parentNode.addChildNode(iconNode)
        parentNode.addChildNode(editButtonNode)
        
        self.currentRoom = currentRoom
        self.panelID = panelID
        self.displayActive = true // expanded at start
        self.panelState = 2
        self.panelIconName = panelIcon
        self.longText = detailedText
        self.spotlight = spotlight
        makePanelFaceCamera()
        createDeleteButton()
        createEditButton()
        createMoveButton()
        createSpotlightButton()
        createHighlight()
        
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
        else {
                displayActive = false
                panelState = 0
                animatePanel(
                    panelNode: parentNode,
                    currentGeometry: currentGeometry,
                    targetGeometry: SCNBox(width: 0.02, height: 0.02, length: 0.02, chamferRadius: 0.01) // Small cube instead of disappearing
                )
                iconNode.isHidden = true // keep hidden so only the dot remains
            }
    }
    
    func editModeToggle() {
        deleteButtonNode.isHidden.toggle()
        editButtonNode.isHidden.toggle()
        moveButtonNode.isHidden.toggle()
        spotlightButtonNode.isHidden.toggle()
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
        let editImage = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 256, weight: .bold))
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
    
    func createSpotlightButton() {
        let buttonSize: CGFloat = 0.025
        let iconSize: CGFloat = 0.018
        let chamfer: CGFloat = 0.003

        let spotlightButtonGeometry = SCNBox(width: buttonSize, height: buttonSize, length: 0.005, chamferRadius: chamfer)
        spotlightButtonGeometry.materials = [transparentPanelFace, panelSides, panelSides, panelSides, panelSides, panelSides]

        spotlightButtonNode.geometry = spotlightButtonGeometry
        spotlightButtonNode.position = SCNVector3(x: 0.05, y: 0.025, z: 0.01)
        spotlightButtonNode.isHidden = true

        // Icon
        let spotlightImage = UIImage(systemName: "lightbulb.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 256, weight: .bold))
        let spotlightIconMaterial = SCNMaterial()
        spotlightIconMaterial.diffuse.contents = spotlightImage
        spotlightIconMaterial.isDoubleSided = true

        let spotlightIconGeometry = SCNPlane(width: iconSize, height: iconSize)
        spotlightIconGeometry.materials = [spotlightIconMaterial]

        let spotlightIconNode = SCNNode(geometry: spotlightIconGeometry)
        spotlightIconNode.position = SCNVector3(x: 0, y: 0, z: 0.003)
        spotlightButtonNode.addChildNode(spotlightIconNode)

        parentNode.addChildNode(spotlightButtonNode)
    }

    func animatePanel(panelNode: SCNNode, currentGeometry: SCNBox, targetGeometry: SCNBox) {
        let sideButtonTargetGeometry: SCNBox
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0

        if (panelState == 2) {
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { [self] _ in
                self.editTextNode(text: panelText,  color: UIColor.black)
            }
            iconCurrentLocation = SCNVector3(x: -0.09, y: 0.0, z: 0.021)
            iconCurrentScale = SCNVector3(x: 1.4, y: 1.4, z: 1.4)

            // Move buttons to the top-right when enlarged
            deleteButtonNode.position = SCNVector3(x: 0.11, y: 0.05, z: 0.025)
            editButtonNode.position = SCNVector3(x: 0.08, y: 0.05, z: 0.025)
            moveButtonNode.position = SCNVector3(x: 0.05, y: 0.05, z: 0.025)
            spotlightButtonNode.position = SCNVector3(x: 0.02, y: 0.05, z: 0.025)
            
            sideButtonTargetGeometry = SCNBox(width: 0.020, height: 0.020, length: 0.012, chamferRadius: 1)
        }
        else if (panelState == 1 || panelState == 0) {
            editTextNode(text: "", color: UIColor.black)
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
                // Pass flag to fill the whole panel
                self.editTextNode(text: longText, color: UIColor.black, fullWidth: true)
            }

            // Hide the icon completely
            iconCurrentLocation = SCNVector3(x: 0, y: 0, z: -1000)   // move behind panel
            iconCurrentScale = SCNVector3(x: 0, y: 0, z: 0)       // shrink it completely

            // Move buttons to top corners (optional)
            deleteButtonNode.position = SCNVector3(x: 0.14, y: 0.1, z: 0.03)
            editButtonNode.position = SCNVector3(x: 0.11, y: 0.1, z: 0.03)
            moveButtonNode.position = SCNVector3(x: 0.08, y: 0.1, z: 0.03)
            spotlightButtonNode.position = SCNVector3(x: 0.05, y: 0.1, z: 0.03)

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

    func editTextNode(text: String, color: UIColor = .black, fullWidth: Bool = false) {
        let panelWidth: Float = fullWidth ? 0.3 : 0.2
        let panelHeight: Float = fullWidth ? 1.3 : 0.125

        // If fullWidth is true, remove left margin for icon
        let leftMargin: Float = fullWidth ? 0 : panelWidth * 0.2

        let availableWidth: CGFloat = CGFloat(panelWidth - leftMargin) * 500 // scale for SCNText
        let availableHeight: CGFloat = CGFloat(panelHeight) * 500

        let textGeometry = SCNText(string: text, extrusionDepth: 0.0)
        textGeometry.font = UIFont.systemFont(ofSize: 7)
        textGeometry.firstMaterial?.diffuse.contents = color
        textGeometry.firstMaterial?.isDoubleSided = true
        textGeometry.alignmentMode = CATextLayerAlignmentMode.left.rawValue
        textGeometry.truncationMode = CATextLayerTruncationMode.none.rawValue
        textGeometry.isWrapped = true
        textGeometry.containerFrame = CGRect(x: 0, y: 0, width: availableWidth, height: availableHeight)

        textNode.geometry = textGeometry

        let (minVec, maxVec) = textNode.boundingBox
        let textHeight = maxVec.y - minVec.y
        textNode.pivot = SCNMatrix4MakeTranslation(minVec.x, minVec.y + textHeight / 2, 0)

        // Position text in the center horizontally
        textNode.position = SCNVector3(-panelWidth/2 + leftMargin, 0, 0.021)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
    }

    func getWorldPosition() -> SCNVector3 {
        return parentNode.worldPosition
    }

    static func randomId(length: Int = 16) -> String {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in chars.randomElement() })
    }
    
    func convertToPanel(museumID: String, roomID: String) -> Panel {
        let rgba = convertUIColourToRGBA(from: self.panelSides.diffuse.contents as! UIColor)
        return Panel(
            panelID: self.panelID,
            museumID: museumID,
            roomID: roomID,
            x: self.parentNode.position.x,
            y: self.parentNode.position.y,
            z: self.parentNode.position.z,
            text: self.panelText,
            icon: self.panelIconName,
            r: rgba.red,
            g: rgba.green,
            b: rgba.blue,
            alpha: rgba.alpha,
            longText: self.longText,
            spotlight: self.spotlight
        )
    }
    
    func createHighlight() {
        highlightNode?.removeFromParentNode()

        let highlightWidth: CGFloat = 0.29
        let highlightHeight: CGFloat = 0.135
        let cornerRadius: CGFloat = 30   // corner radius in image points
        let color = UIColor.yellow.withAlphaComponent(0.7)

        // Create a rounded-corner image
        let size = CGSize(width: 300, height: 150)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        color.setFill()
        path.fill()
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Use a plane (simple, efficient geometry)
        let plane = SCNPlane(width: highlightWidth, height: highlightHeight)

        let material = SCNMaterial()
        material.diffuse.contents = roundedImage
        material.emission.contents = roundedImage
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.writesToDepthBuffer = false

        plane.materials = [material]

        let node = SCNNode(geometry: plane)
        node.position = SCNVector3(0, 0, -0.03)
        node.isHidden = true

        // Optional: make sure it faces the camera
        let billboard = SCNBillboardConstraint()
        billboard.freeAxes = .Y
        node.constraints = [billboard]

        parentNode.insertChildNode(node, at: 0)
        highlightNode = node
        print(spotlight)
        if(spotlight){
            highlightNode?.isHidden = false
        }
    }

    func setSpotlight() {
        spotlight.toggle()
        highlightNode?.isHidden = !spotlight
    }
    
    func checkAndSetSpotlight(far:Bool){
        if(far){
            if(spotlight){
                adjustSpotlightSize(isLarge: false)
            }
        }
        else{
            if(spotlight){
                adjustSpotlightSize(isLarge: true)
            }
        }
        
    }
    
    func adjustSpotlightSize(isLarge: Bool) {
        guard let plane = highlightNode?.geometry as? SCNPlane else {
            return
        }

        // Define base sizes
        let smallWidth: CGFloat = 0.15
        let smallHeight: CGFloat = 0.075
        let largeWidth: CGFloat = 0.29
        let largeHeight: CGFloat = 0.135

        // Instantly resize the geometry
        plane.width = isLarge ? largeWidth : smallWidth
        plane.height = isLarge ? largeHeight : smallHeight

    }


}

