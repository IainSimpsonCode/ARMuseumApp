import SwiftUI
import ARKit

struct ARCameraForMenu: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        
        // Empty scene, no panels
        arView.scene = SCNScene()
        
        // Camera feed
        arView.backgroundColor = .clear
        arView.automaticallyUpdatesLighting = true
        
        // Run a simple AR session
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) { }
}
