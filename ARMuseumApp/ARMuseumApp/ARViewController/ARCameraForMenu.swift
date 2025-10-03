//
//  PanelsService.swift
//  ARMuseumApp
//
//  Created by Senan on 04/09/2025.
//
import SwiftUI
import ARKit
import RealityKit

class ARViewModel: ObservableObject {
    let arView: ARView
    
    init() {
        arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
    }
}

struct ARCameraForMenu: UIViewRepresentable {
    @ObservedObject var model: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        return model.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    static func dismantleUIView(_ uiView: ARView, coordinator: ()) {
        // Optional: Pause only if you want to completely stop AR
        // model.arView.session.pause()
    }
    
//    func resume(){
//        arView = ARView(frame: .zero)
//        let config = ARWorldTrackingConfiguration()
//        arView.session.run(config)
//    }
}
