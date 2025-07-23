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
        
        //turns the anchor into an image anchor
        if let imageAnchor = anchor as? ARImageAnchor {
            
            //Check if image scanned is a valid room
            if rooms.contains(imageAnchor.referenceImage.name!) {
                let imagePosition = node.position
                
                //Code for image lineup
                let boxWidth: Float = 0.25
                let boxHeight: Float = 0.25
                let boxCenter = SCNVector3(0, 0, 0)
                
                if abs(imagePosition.x - boxCenter.x) < boxWidth / 2 && abs(imagePosition.z - boxCenter.z) < boxHeight / 2 {
                    //If a session isnt currently running start a new session
                    if !buttonFunctions.sessionRunning {
                        print("Image is aligned!")
                        //testMongo()
                        buttonFunctions.startSession(node: node, posterName: imageAnchor.referenceImage.name ?? "NIL")
                    }
                }
            }
        }
    }
}

