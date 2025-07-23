//
//  ARMuseumAppApp.swift
//  ARMuseumApp
//
//  Created by Liam Moseley on 24/07/2024.
//

import SwiftUI

@main
struct ARMuseumApp: App {
    //Passed down so it can be accessed from the entire project
    @StateObject private var buttonFunctions = ButtonFunctions()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(buttonFunctions)
        }
    }
}
