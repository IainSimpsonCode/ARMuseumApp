//
//  ImageDetection.swift
//  ARMuseumApp
//
//  Created by Liam Moseley on 26/07/2024.
//

import ARKit
import SwiftUI

var rooms: [String] = ["DiningRoomPoster", "SecondPoster", "Viva Exhibit Display"]

class ImageDetection: NSObject, ARSCNViewDelegate {
    var sceneView: ARSCNView
    var panelController: ARPanelController
    @ObservedObject var buttonFunctions: ButtonFunctions
    @State var isImageAligned = false // Track if the image is aligned
    
    init(sceneView: ARSCNView, panelController: ARPanelController, buttonFunctions: ButtonFunctions) {
        self.sceneView = sceneView
        self.panelController = panelController
        self.buttonFunctions = buttonFunctions
        super.init()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Image Detected")
        
        guard let imageAnchor = anchor as? ARImageAnchor,
              let imageName = imageAnchor.referenceImage.name,
              rooms.contains(imageName)
        else { return }
        
        // Capture node + name immediately
        let targetNode = node
        
        // Add 2s delay before checking alignment & starting session
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            let imagePosition = targetNode.presentation.worldPosition  // <- more stable
            
            // Define box area for alignment
            let boxWidth: Float = 2.5
            let boxHeight: Float = 2.5
            let boxCenter = SCNVector3(0, 0, 0)
            
//            if abs(imagePosition.x - boxCenter.x) < boxWidth / 2 &&
//               abs(imagePosition.z - boxCenter.z) < boxHeight / 2 {
                
                if !self.buttonFunctions.sessionRunning {
                    print("Image is aligned")
                    self.buttonFunctions.startSession(
                        node: targetNode,
                        posterName: imageName
                    )
                }
//            }
        }
    }

}

