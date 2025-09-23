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

struct DrawingPoint: Codable {
    let position: [Float]  // [x, y, z]
    let radius: Float      // sphere radius
}

func saveDrawingNode(_ node: SCNNode) {
    guard let sphere = node.geometry as? SCNSphere else { return }
    
    let point = DrawingPoint(
        position: [node.position.x, node.position.y, node.position.z],
        radius: Float(sphere.radius)
    )
    
    var savedPoints = loadDrawingPoints()
    savedPoints.append(point)
    
    if let data = try? JSONEncoder().encode(savedPoints) {
        UserDefaults.standard.set(data, forKey: "savedDrawings")
    }
}

func loadDrawingPoints() -> [DrawingPoint] {
    guard let data = UserDefaults.standard.data(forKey: "savedDrawings"),
          let points = try? JSONDecoder().decode([DrawingPoint].self, from: data) else { return [] }
    return points
}

func restoreDrawings(to scene: SCNScene) {
    let points = loadDrawingPoints()
    for p in points {
        let sphere = SCNSphere(radius: CGFloat(p.radius))
        sphere.firstMaterial?.diffuse.contents = UIColor.systemBlue
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(p.position[0], p.position[1], p.position[2])
        scene.rootNode.addChildNode(node)
    }
}

func clearSavedDrawings() {
    UserDefaults.standard.removeObject(forKey: "savedDrawings")
}

func removeDrawingNode(_ node: SCNNode) {
    var points = loadDrawingPoints()
    
    points.removeAll { p in
        let pointPosition = SCNVector3(p.position[0], p.position[1], p.position[2])
        let matchesPosition = pointPosition.isAlmostEqual(to: node.position)
        let matchesRadius = CGFloat(p.radius) == (node.geometry as? SCNSphere)?.radius

        return matchesPosition && matchesRadius
    }
    
    if let data = try? JSONEncoder().encode(points) {
        UserDefaults.standard.set(data, forKey: "savedDrawings")
    }
}

extension SCNVector3 {
    func isAlmostEqual(to other: SCNVector3, tolerance: Float = 0.0001) -> Bool {
        return
            abs(self.x - other.x) < tolerance &&
            abs(self.y - other.y) < tolerance &&
            abs(self.z - other.z) < tolerance
    }
}


