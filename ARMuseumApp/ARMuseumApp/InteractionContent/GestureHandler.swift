//
//  GestureHandler.swift
//  ARMuseumApp
//
//  Created by Liam Moseley on 24/07/2024.
//

//import UIKit
import ARKit
import SwiftUI

class GestureHandler: NSObject {
    var sceneView: ARSCNView
    var panelController: ARPanelController
    var shadowPanel: ShadowPanel?
    private var panelToChange: ARPanel?
    private var initialScale: SCNVector3?
    private var selectedNode: SCNNode?
    @ObservedObject var buttonFunctions: ButtonFunctions
    
    init(sceneView: ARSCNView, panelController: ARPanelController, buttonFunctions: ButtonFunctions) {
        self.sceneView = sceneView
        self.panelController = panelController
        self.buttonFunctions = buttonFunctions
        super.init()
        addGestures()
    }
    
    private func addGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let holdGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleHold))
        sceneView.addGestureRecognizer(holdGestureRecogniser)
        
        let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        sceneView.addGestureRecognizer(pinchGestureRecogniser)
    }
    
    //When user taps on panel run the animation
    @objc func handleTap(sender: UITapGestureRecognizer) {
        print(buttonFunctions.editModeActive)
        let location = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(location, options: nil)
        
        
        
        if let hitResult = hitTestResults.first {
            let node = hitResult.node
            
            for (index, panelsInScene) in panelController.panelsInScene.enumerated() {
                if(node == panelsInScene.parentNode || node == panelsInScene.iconNode){
                    panelsInScene.handleTap()
                }
                else if(node == panelsInScene.deleteButtonNode || node == panelsInScene.deleteButtonNode.childNodes[0]) {
                    panelsInScene.parentNode.removeFromParentNode()
                    panelController.panelsInScene.remove(at: index)
                }
                else if(node == panelsInScene.editButtonNode || node == panelsInScene.deleteButtonNode.childNodes[0]) {
                    
                }
            }
        }
    }
    
    @objc func handleHold(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(location, options: nil)
        
        if let hitResult = hitTestResults.first {
            let node = hitResult.node
                
            for panelsInScene in panelController.panelsInScene {
                if(node == panelsInScene.parentNode || node == panelsInScene.iconNode){
                    //panelsInScene.handleHold()
                    shadowPanel?.iconNode.position = panelsInScene.iconNode.position
                    shadowPanel?.iconNode.scale = panelsInScene.iconNode.scale
                    shadowPanel?.parentNode.geometry = panelsInScene.parentNode.geometry
                    
                    shadowPanel?.addToScene()
                    buttonFunctions.movingPanel = true
                    shadowPanel?.panelToChnage = panelsInScene
                }
            }
        }
    }

    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
        //guard let panel = panel else {return}
        let location = sender.location(in: sceneView)
        
        switch sender.state {
        case .began:
            let hitTestResults = sceneView.hitTest(location, options: nil)
            let hitResult = hitTestResults.first
            for panelsInScene in panelController.panelsInScene {
                if (hitResult?.node == panelsInScene.parentNode || hitResult?.node == panelsInScene.iconNode) {
                    initialScale = panelsInScene.parentNode.scale
                    panelToChange = panelsInScene
                }
            }
        case .changed:
            guard let initialScale = initialScale else {return}
            let scale = Float(sender.scale)
            panelToChange?.parentNode.scale = SCNVector3(initialScale.x * scale, initialScale.y * scale, initialScale.z * scale)
        case .ended, .cancelled:
            initialScale = nil
            panelToChange = nil
        default:
            break
        }
    }
}

