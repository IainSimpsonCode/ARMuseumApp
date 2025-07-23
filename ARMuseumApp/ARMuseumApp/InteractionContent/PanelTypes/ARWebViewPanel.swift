//
//  ARWebViewPanel.swift
//  ARMuseumApp
//
//  Created by Liam Moseley on 24/09/2024.
//

import Foundation
import SceneKit
import ARKit
import WebKit
import SwiftUI

class WebViewPanel {
    let sceneView: ARSCNView
    let url: URL
    
    
    
    init(sceneView: ARSCNView, url: URL) {
        self.sceneView = sceneView
        self.url = url
        
        addWebView(url: url, at: SCNVector3(x: 0, y: 0, z: -5))
    }
    
    func addWebView(url: URL, at position: SCNVector3) {
        let webView = WebView(url: url)
        let webViewNode = SCNNode()
        
        // Create a plane geometry for the web view
        let plane = SCNPlane(width: 10.0, height: 10.6) // Adjust size as needed
        webViewNode.geometry = plane
        
        // Create a material to display the web view
        let material = SCNMaterial()
        material.diffuse.contents = webView
        plane.materials = [material]
        
        webViewNode.position = position
        
        sceneView.scene.rootNode.addChildNode(webViewNode)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
