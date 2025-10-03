//
//  DrawingsController.swift
//  ARMuseumApp
//
//  Created by Senan on 08/09/2025.
//

import Foundation
import SwiftUI
import SceneKit
import ARKit
import UIKit

func saveDrawingNode(_ node: SCNNode, museumID: String, roomID: String, accessToken: String) async {
    guard let sphere = await node.geometry as? SCNSphere else { return }
    
    let point = await DrawingPoint(
        x: node.position.x,
        y: node.position.y,
        z: node.position.z,
        radius: Float(sphere.radius)
         
    )
    
    print(point)
    await saveDrawingNodeService(drawingPoint: point, museumID: museumID, roomID: roomID, accessToken: accessToken)
}

func restoreDrawings(to scene: SCNScene, museumID: String, roomID: String, accessToken: String) async {
    let points = await getDrawingNodeService(museumID: museumID, roomID: roomID, accessToken: accessToken)
    for p in points {
        print(p.x)
        await MainActor.run {
            let sphere = SCNSphere(radius: CGFloat(p.radius))
            sphere.firstMaterial?.diffuse.contents = UIColor.systemBlue
            let node = SCNNode(geometry: sphere)
            node.position = SCNVector3(p.x, p.y, p.z)
            scene.rootNode.addChildNode(node)
        }
    }
}


func clearSavedDrawings() {
    UserDefaults.standard.removeObject(forKey: "savedDrawings")
}

//func removeDrawingNode(_ node: SCNNode) {
//    var points = loadDrawingPoints()
//    
//    points.removeAll { p in
//        let pointPosition = SCNVector3(p.position[0], p.position[1], p.position[2])
//        let matchesPosition = pointPosition.isAlmostEqual(to: node.position)
//        let matchesRadius = CGFloat(p.radius) == (node.geometry as? SCNSphere)?.radius
//
//        return matchesPosition && matchesRadius
//    }
//    
//    if let data = try? JSONEncoder().encode(points) {
//        UserDefaults.standard.set(data, forKey: "savedDrawings")
//    }
//}

extension SCNVector3 {
    func isAlmostEqual(to other: SCNVector3, tolerance: Float = 0.0001) -> Bool {
        return
            abs(self.x - other.x) < tolerance &&
            abs(self.y - other.y) < tolerance &&
            abs(self.z - other.z) < tolerance
    }
}


