//
//  PanelTextNodeCreator.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 24/01/2025.
//

import SceneKit

func createTextNode(text: String, fontSize: CGFloat, color: UIColor) -> SCNNode {
    let textGeometry = SCNText(string: text, extrusionDepth: 0.2)
    textGeometry.font = UIFont.systemFont(ofSize: fontSize)
    
    let material = SCNMaterial()
    material.diffuse.contents = color
    textGeometry.materials = [material]
    
    let textNode = SCNNode(geometry: textGeometry)
    
    textNode.position = SCNVector3(x: -0.033, y: -0.035, z: 0.02)
    textNode.scale = SCNVector3(x: 0.015, y: 0.015, z: 0.015)
    
    return textNode
}
