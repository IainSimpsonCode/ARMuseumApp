//
//  ARViewContainer.swift
//  ARMuseumApp
//
//  Created by Liam Moseley on 24/07/2024.
//

import SwiftUI
import ARKit
import UIKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var buttonFunctions: ButtonFunctions
    var panelController: ARPanelController
    var sceneView: ARSCNView?
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARViewContainer
        var gestureHandler: GestureHandler?
        var imageDetectionHandler: ImageDetection?
        var panelController: ARPanelController
        var shadowPanel: ShadowPanel?

        private var lastDistanceUpdateTime: TimeInterval = 0
        private var lastComUpdateTime: TimeInterval = 0
        private var firstPass: Bool = true

        init(_ parent: ARViewContainer) {
            self.parent = parent
            self.panelController = parent.panelController
            self.lastDistanceUpdateTime = CACurrentMediaTime() // or Date().timeIntervalSince1970
            self.lastComUpdateTime = CACurrentMediaTime() // or Date().timeIntervalSince1970

        }
        
        func setupImageDetectionHandler(for sceneView: ARSCNView) {
            imageDetectionHandler = ImageDetection(sceneView: sceneView, panelController: panelController, buttonFunctions: parent.buttonFunctions)
            sceneView.delegate = imageDetectionHandler
        }
        
        func setupGestureHandler(for sceneView: ARSCNView) {
            gestureHandler = GestureHandler(sceneView: sceneView, panelController: panelController, buttonFunctions: parent.buttonFunctions)
        }
        
        func setupSceneView(for sceneView: ARSCNView) {
            parent.sceneView = sceneView
            sceneView.delegate = self
        }
        
        func setupShadowPanel(){
            shadowPanel = ShadowPanel(position: SCNVector3(x: 0, y: 0, z: 0), scene: parent.sceneView!, text: "Move me to where you feel i best fit!", panelColor: UIColor.red, panelIcon: "move.3d")
            gestureHandler?.shadowPanel = shadowPanel
            parent.buttonFunctions.shadowPanel = gestureHandler?.shadowPanel
        }
        
        // Delegate forwarding
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            imageDetectionHandler?.renderer(renderer, didAdd: node, for: anchor)
        }

        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            imageDetectionHandler?.renderer(renderer, didAdd: node, for: anchor)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let pointOfView = parent.sceneView?.pointOfView else { return }

            // Get camera position and direction
            let cameraTransform = pointOfView.transform
            let cameraPosition = SCNVector3(cameraTransform.m41, cameraTransform.m42, cameraTransform.m43)
            let cameraDirection = SCNVector3(-cameraTransform.m31, -cameraTransform.m32, -cameraTransform.m33)

            // Update the panel's position to always stay in front of the camera
            let distance: Float = 0.5
            let newPosition = SCNVector3(
                cameraPosition.x + cameraDirection.x * distance,
                cameraPosition.y + cameraDirection.y * distance,
                cameraPosition.z + cameraDirection.z * distance
            )

            DispatchQueue.main.async { [self] in
                self.shadowPanel?.parentNode.position = newPosition
                
                if(!firstPass){
                    // Throttle distance checks to once per second
                    if time - self.lastDistanceUpdateTime >= 1.0 {
                        self.lastDistanceUpdateTime = time
                            DispatchQueue.main.async {
                                self.gestureHandler?.updatePanelDistances()
                            }
                        }
                    
                    if time - self.lastComUpdateTime >= 10.0 {
                        self.lastComUpdateTime = time
                        if(parent.buttonFunctions.SessionSelected == 2){
                            Task {
                                                            let allPanels = await PanelStorageManager.loadPanels(
                                                                museumID: parent.buttonFunctions.sessionDetails.museumID,
                                                                roomID: parent.buttonFunctions.sessionDetails.roomID,
                                                                sessionSelected: parent.buttonFunctions.SessionSelected,
                                                                accessToken: parent.buttonFunctions.accessToken
                                                            )
    //                                                        for panel in allPanels {
    //                                                            parent.buttonFunctions.placeLoadedPanel(panel: panel)
    //                                                            print(allPanels.count)
    //                                                        }
                                await PanelStorageManager.handleCommunityUpdates(_ARPanelController: panelController, panels: allPanels, buttonFunctions: parent.buttonFunctions)

                            }
                        }
                           
                        }
                }
                else {
                    firstPass = false
                }
                
            }
            
        }
    }

    func checkCommunityPanels(){
        if buttonFunctions.SessionSelected == 2 {
            
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator

        // Create a new scene
        let scene = SCNScene()
        arView.scene = scene

        // Run the AR session
        let configuration = ARWorldTrackingConfiguration()
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
        configuration.detectionImages = referenceImages
        arView.session.run(configuration)

        // Setup AR view on main thread
        DispatchQueue.main.async {
            self.buttonFunctions.setupARView(arView, panelController: self.panelController)
        }

        // Setup handlers
        context.coordinator.setupGestureHandler(for: arView)
        context.coordinator.setupImageDetectionHandler(for: arView)
        context.coordinator.setupSceneView(for: arView)
        context.coordinator.setupShadowPanel()

        if(buttonFunctions.SessionSelected == 2){
            Task{
                await restoreDrawings(to: arView.scene, museumID: buttonFunctions.sessionDetails.museumID, roomID: buttonFunctions.sessionDetails.roomID, accessToken: buttonFunctions.accessToken)
            }
        }
        
        return arView
    }


    func updateUIView(_ uiView: ARSCNView, context: Context) {
        
    }
    
    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        // Stop all AR updates and release GPU resources
        uiView.session.pause()
        
        // Optionally remove all nodes to free SceneKit memory
        uiView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        
        // Clear the delegate to avoid retaining coordinator
        uiView.delegate = nil
    }

}



