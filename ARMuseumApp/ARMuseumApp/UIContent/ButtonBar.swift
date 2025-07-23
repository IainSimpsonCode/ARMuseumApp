//
//  ButtonBar.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 22/01/2025.
//

import SwiftUI

struct ButtonBar: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions

    var body: some View {
        VStack {
            Spacer()
            // Custom Tab Bar with All Icons Blue
            Color.white.opacity(0.6)
                .edgesIgnoringSafeArea(.vertical)
                .frame(height: 80) // Match height to the original design
                .overlay(
                    HStack {
                        Spacer()
                        
                        // Drawing Button
                        Button(action: buttonFunctions.startDrawing) {
                            ButtonBarItemDesign(iconName: "paintbrush.pointed.fill", buttonText: "Drawing")
                        }
                        
                        Spacer()
                        
                        // Capture Button
                        NavigationLink(destination: ScreenShotView(buttonFunctions: _buttonFunctions)) {
                            ButtonBarItemDesign(iconName: "camera.fill", buttonText: "Capture")
                        }
                        
                        Spacer()
                        
                        // Add Panel Button
                        NavigationLink(destination: AddPanelView(buttonFunctions: _buttonFunctions, needsClosing: false)) {
                            ButtonBarItemDesign(iconName: "plus.rectangle.fill.on.rectangle.fill", buttonText: "Add Panel")
                        }
                        .disabled(!buttonFunctions.sessionRunning)
                        .opacity(buttonFunctions.sessionRunning ? 1.0 : 0.5)
                        
                        Spacer()
                    }
                )
                .cornerRadius(10)
                
        }
    }
}

struct ButtonBarItemDesign: View {
    var iconName: String
    var buttonText: String
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30, alignment: .center)
                .foregroundColor(.blue)
            Text(buttonText)
                .font(.footnote)
                .foregroundColor(.blue)
        }

    }
}
