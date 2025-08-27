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
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        sceneView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
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
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.prepare()
                    generator.notificationOccurred(.success)

                }
                else if(node == panelsInScene.editButtonNode || node == panelsInScene.deleteButtonNode.childNodes[0]) {
                    // Placeholder for edit functionality
                }
                else if(node == panelsInScene.moveButtonNode || node == panelsInScene.moveButtonNode.childNodes[0]) {
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
    
    @objc func handleHold(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        let location = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(location, options: nil)
        
        if let hitResult = hitTestResults.first {
            let node = hitResult.node
                
            for panelsInScene in panelController.panelsInScene {
                if(node == panelsInScene.parentNode || node == panelsInScene.iconNode){
                    panelsInScene.editModeToggle()
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.prepare()
                                    generator.impactOccurred()
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        panelsInScene.editModeToggle()
                    }
                }
            }
        }
    }

    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
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
            guard let initialScale = initialScale else { return }
            let scale = Float(sender.scale)
            panelToChange?.parentNode.scale = SCNVector3(initialScale.x * scale, initialScale.y * scale, initialScale.z * scale)
        case .ended, .cancelled:
            initialScale = nil
            panelToChange = nil
        default:
            break
        }
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        guard buttonFunctions.isDrawingMode else { return }

        let location = sender.location(in: sceneView)

        switch sender.state {
        case .began, .changed:
            drawFloatingAtTouch(location: location)
        default:
            break
        }
    }


    private func drawFloatingAtTouch(location: CGPoint) {
        guard let currentFrame = sceneView.session.currentFrame else { return }

        let cameraTransform = currentFrame.camera.transform
        let cameraPosition = SCNVector3(cameraTransform.columns.3.x,
                                        cameraTransform.columns.3.y,
                                        cameraTransform.columns.3.z)

        // Convert screen touch point to a ray in world space
        let rayResult = sceneView.unprojectPoint(SCNVector3(location.x, location.y, 0.997)) // z near 1 = far
        let touchWorldPoint = SCNVector3(rayResult.x, rayResult.y, rayResult.z)

        // Place drawing point between the camera and the far ray point
        let interpolated = interpolate(from: cameraPosition, to: touchWorldPoint, factor: 0.9)

        let sphere = SCNSphere(radius: 0.003)
        sphere.firstMaterial?.diffuse.contents = UIColor.systemBlue

        let node = SCNNode(geometry: sphere)
        node.position = interpolated
        sceneView.scene.rootNode.addChildNode(node)
    }

    private func interpolate(from: SCNVector3, to: SCNVector3, factor: Float) -> SCNVector3 {
        return SCNVector3(
            from.x + (to.x - from.x) * factor,
            from.y + (to.y - from.y) * factor,
            from.z + (to.z - from.z) * factor
        )
    }

    private func addPointInFrontOfCamera() {
        guard let pointOfView = sceneView.pointOfView else { return }

        let transform = pointOfView.transform
        let cameraPosition = SCNVector3(transform.m41, transform.m42, transform.m43)
        let direction = SCNVector3(-transform.m31, -transform.m32, -transform.m33)

        let distance: Float = 0.05
        let drawPosition = SCNVector3(
            cameraPosition.x + direction.x * distance,
            cameraPosition.y + direction.y * distance,
            cameraPosition.z + direction.z * distance
        )

        let sphere = SCNSphere(radius: 0.002)
        sphere.firstMaterial?.diffuse.contents = UIColor.systemBlue

        let node = SCNNode(geometry: sphere)
        node.position = drawPosition
        sceneView.scene.rootNode.addChildNode(node)
    }
}
