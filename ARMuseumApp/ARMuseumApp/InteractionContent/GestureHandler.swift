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
    var panelCollapseTimers: [String: Timer] = [:] // Use panelID or some unique key

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
        
        guard let hitResult = hitTestResults.first else { return }
        let node = hitResult.node
        
        for (index, panel) in panelController.panelsInScene.enumerated() {
            // DELETE BUTTON
            if node == panel.deleteButtonNode || node == panel.deleteButtonNode.childNodes.first {
                panel.parentNode.removeFromParentNode()
                panelController.panelsInScene.remove(at: index)
                if(buttonFunctions.SessionSelected != 1){
                    Task {
                            await PanelStorageManager.deletePanelByID(
                                museumID: buttonFunctions.sessionDetails.museumID,
                                roomID: buttonFunctions.sessionDetails.roomID,
                                Id: panel.panelID,
                                sessionSelected: buttonFunctions.SessionSelected,
                                accessToken: buttonFunctions.accessToken
                            )
                        }
                }
                
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.success)
                return
            }
            
            // EDIT BUTTON
            else if node == panel.editButtonNode || node == panel.editButtonNode.childNodes.first {
                DispatchQueue.main.async {
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    let window = windowScene?.windows.first
                    let root = window?.rootViewController

                    let editView = UIHostingController(
                        rootView: EditPanelView(panel: panel, needsClosing: .constant(false))
                            .environmentObject(self.buttonFunctions)
                    )

                    root?.present(editView, animated: true)
                }
                return
            }

            // MOVE BUTTON
            else if node == panel.moveButtonNode || node == panel.moveButtonNode.childNodes.first {
                shadowPanel?.iconNode.position = panel.iconNode.position
                shadowPanel?.iconNode.scale = panel.iconNode.scale
                shadowPanel?.parentNode.geometry = panel.parentNode.geometry
                shadowPanel?.addToScene()
                buttonFunctions.movingPanel = true
                buttonFunctions.movingPanelPanel = panel
                shadowPanel?.panelToChnage = panel
               
                return
            }
            // SPOTLIGHT BUTTON
            else if node == panel.spotlightButtonNode || node == panel.spotlightButtonNode.childNodes.first {
                panel.setSpotlight()
                if(buttonFunctions.SessionSelected != 1){
                    Task{
                        await updatePanelService(panel:panel.convertToPanel(museumID: buttonFunctions.sessionDetails.museumID, roomID: buttonFunctions.sessionDetails.roomID))
                    }
                }
               
                return
            }
            else if node == panel.parentNode || node == panel.iconNode {
                let panelID = panel.panelID // Or any unique identifier for the panel
                
                if panel.isTemporarilyExpanded {
                    // Cancel any existing collapse timer for this panel
                    panelCollapseTimers[panelID]?.invalidate()
                    panelCollapseTimers[panelID] = nil
                    
                    // Revert panel size
                    panel.isTemporarilyExpanded = false
                    
                    let distance = self.distanceBetween(self.sceneView.pointOfView!.worldPosition,
                                                        panel.parentNode.worldPosition)
                    if distance < 2 {
                        panel.changePanelSize(size: 2)
                    } else if distance > 2 && distance < 4 {
                        panel.changePanelSize(size: 1)
                    } else {
                        panel.changePanelSize(size: 0)
                    }
                } else {
                    // Expand panel safely
                    panel.isTemporarilyExpanded = true
                    panel.panelState = 3

                    // Calculate how many "lines" of text roughly to expect
                    let charCount = panel.longText.count / 12

                    // Define base size parameters
                    let baseHeight: CGFloat = 0.1      // Minimum panel height
                    let heightPerChar: CGFloat = 0.005 // How much height to add per 12 characters
                    let maxHeight: CGFloat = 0.8       // 🧱 Maximum allowed panel height (prevents crash)

                    // Compute dynamic height and clamp it safely
                    var dynamicHeight = baseHeight + (CGFloat(charCount) * heightPerChar)
                    dynamicHeight = min(dynamicHeight, maxHeight)

                    // Create new geometry with safe height
                    let state3Geometry = SCNBox(
                        width: 0.4,
                        height: dynamicHeight,
                        length: 0.04,
                        chamferRadius: 1
                    )

                    // Animate the geometry transition
                    panel.animatePanel(
                        panelNode: panel.parentNode,
                        currentGeometry: panel.currentGeometry,
                        targetGeometry: state3Geometry
                    )

                    // Cancel any previous collapse timer for this panel
                    panelCollapseTimers[panelID]?.invalidate()

                    // Schedule a new collapse timer to shrink back after 10s
                    panelCollapseTimers[panelID] = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { _ in
                        panel.isTemporarilyExpanded = false

                        // Compute camera distance
                        let distance = self.distanceBetween(
                            self.sceneView.pointOfView!.worldPosition,
                            panel.parentNode.worldPosition
                        )

                        // Adjust panel size depending on user distance
                        if distance < 2 {
                            panel.changePanelSize(size: 2)
                        } else if distance > 2 && distance < 4 {
                            panel.changePanelSize(size: 1)
                        } else {
                            panel.changePanelSize(size: 0)
                        }

                        // Remove timer reference after it fires
                        self.panelCollapseTimers[panelID] = nil
                    }
                }
                return
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
            if buttonFunctions.isEraserMode {
                eraseFloatingAtTouch(location: location)
            } else {
                drawFloatingAtTouch(location: location)
            }
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
        
        Task{
            if(buttonFunctions.SessionSelected == 2){
                await saveDrawingNode(node, museumID: buttonFunctions.sessionDetails.museumID, roomID: buttonFunctions.sessionDetails.roomID, accessToken: buttonFunctions.accessToken)
            }
        }
        
    }

    private func interpolate(from: SCNVector3, to: SCNVector3, factor: Float) -> SCNVector3 {
        return SCNVector3(
            from.x + (to.x - from.x) * factor,
            from.y + (to.y - from.y) * factor,
            from.z + (to.z - from.z) * factor
        )
    }

    private func eraseFloatingAtTouch(location: CGPoint) {
        guard let currentFrame = sceneView.session.currentFrame else { return }

        // Convert screen touch point to a 3D point on far plane
        let rayResult = sceneView.unprojectPoint(SCNVector3(location.x, location.y, 1.0)) // far plane
        let cameraTransform = currentFrame.camera.transform
        let cameraPosition = SCNVector3(cameraTransform.columns.3.x,
                                        cameraTransform.columns.3.y,
                                        cameraTransform.columns.3.z)

        // Direction from camera to ray point
        let rayDirection = SCNVector3(rayResult.x - cameraPosition.x,
                                      rayResult.y - cameraPosition.y,
                                      rayResult.z - cameraPosition.z)

        let eraseRadius: Float = 0.02 // 2 cm

        // Remove any node whose distance from the ray is < eraseRadius
        let nodesToErase = sceneView.scene.rootNode.childNodes.filter { node in
            guard node.geometry is SCNSphere else { return false }

            // Vector from camera to node
            let toNode = SCNVector3(node.position.x - cameraPosition.x,
                                    node.position.y - cameraPosition.y,
                                    node.position.z - cameraPosition.z)

            // Project toNode onto rayDirection
            let t = (toNode.x * rayDirection.x + toNode.y * rayDirection.y + toNode.z * rayDirection.z) /
                    (rayDirection.x * rayDirection.x + rayDirection.y * rayDirection.y + rayDirection.z * rayDirection.z)

            // Closest point on ray
            let closestPoint = SCNVector3(cameraPosition.x + rayDirection.x * t,
                                          cameraPosition.y + rayDirection.y * t,
                                          cameraPosition.z + rayDirection.z * t)

            // Distance from node to ray
            let dx = node.position.x - closestPoint.x
            let dy = node.position.y - closestPoint.y
            let dz = node.position.z - closestPoint.z
            let distance = sqrt(dx*dx + dy*dy + dz*dz)

            return distance < eraseRadius
        }

        // Remove nodes from scene AND UserDefaults
        for node in nodesToErase {
            node.removeFromParentNode()
            removeDrawingNode(node)
        }
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
    
    func updatePanelDistances() {
        guard let pointOfView = sceneView.pointOfView else { return }
        let cameraPosition = pointOfView.worldPosition
        
        for panel in panelController.panelsInScene {
            // Skip panels that are temporarily expanded
            if panel.isTemporarilyExpanded { continue }
            
            let panelPosition = panel.parentNode.worldPosition
            let distance = distanceBetween(cameraPosition, panelPosition)
            
            if distance < 2 {
                panel.changePanelSize(size: 2)
                panel.checkAndSetSpotlight(far: false)
            } else if distance > 2 && distance < 4 {
                panel.changePanelSize(size: 1)
                panel.checkAndSetSpotlight(far: true)
            } else {
                panel.changePanelSize(size: 0)
                panel.checkAndSetSpotlight(far: true)
            }
        }
    }


    // Utility
    private func distanceBetween(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        let dx = a.x - b.x
        let dy = a.y - b.y
        let dz = a.z - b.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }

}
