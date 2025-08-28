//
//  ARMuseumAppApp.swift
//  ARMuseumApp
//
//  Created by Liam Moseley on 24/07/2024.
//

// import SwiftUI

// @main
// struct ARMuseumApp: App {
//     //Passed down so it can be accessed from the entire project
//     @StateObject private var buttonFunctions = ButtonFunctions()
//     var body: some Scene {
//         WindowGroup {
//             ContentView()
//                 .environmentObject(buttonFunctions)
//         }
//     }
// }

import SwiftUI
import ARKit

@main
struct ARMuseumApp: App {
    @StateObject private var buttonFunctions = ButtonFunctions()
    @State private var referenceImages: Set<ARReferenceImage> = []
    @State private var isLoading = true

    init() {
        Task {
            await preloadReferenceImages()
        }
    }

    var body: some Scene {
        WindowGroup {
            if isLoading {
                VStack {
                    ProgressView("Loading reference images...")
                    Text("Please wait, preparing AR session")
                }
            } else {
                ContentView()
                    .environmentObject(buttonFunctions)
                    .environment(\.referenceImages, referenceImages)
            }
        }
    }

    // Preload images before showing main content
    private func preloadReferenceImages() async {
        print("Fetching reference images...")
        let images = await DBController.getReferenceImages(for: "testMuseum")

        // Log what we actually got
        for img in images {
            print("Loaded reference image: \(img.name ?? "unknown") " +
                  "width=\(img.physicalSize.width)m height=\(img.physicalSize.height)m")
        }

        DispatchQueue.main.async {
            self.referenceImages = images
            self.isLoading = false
            print("Finished loading \(images.count) reference images")
        }
    }
}

