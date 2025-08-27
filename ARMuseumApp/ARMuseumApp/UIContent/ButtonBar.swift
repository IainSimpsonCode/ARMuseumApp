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
        VStack(spacing: 0) {
            Spacer()
            
            Divider() // native tab bars have a top border

            HStack {
                Spacer()
                
                // End Session Button
                Button(action: {
                    buttonFunctions.endSession()
                }) {
                    ButtonBarItemDesign(iconName: "xmark.circle.fill", buttonText: "End")
                }
                .disabled(!buttonFunctions.sessionRunning)
                .opacity(buttonFunctions.sessionRunning ? 1.0 : 0.4)
                
                Spacer()
                
                // Capture Button
                NavigationLink(destination: ScreenShotView(buttonFunctions: _buttonFunctions)) {
                    ButtonBarItemDesign(iconName: "camera.fill", buttonText: "Capture")
                }
                
                Spacer()
                
                // Drawing Button
                Button(action: {
                    buttonFunctions.toggleDrawingMode()
                }) {
                    ButtonBarItemDesign(
                        iconName: buttonFunctions.isDrawingMode ? "paintbrush.fill" : "paintbrush", // icon changes when active
                        buttonText: buttonFunctions.isDrawingMode ? "Stop" : "Draw"
                    )
                }


                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(.ultraThinMaterial) // semi-blur, modern native style
            .clipShape(RoundedRectangle(cornerRadius: 0)) // native tab bars are square

        }
        .ignoresSafeArea(.keyboard, edges: .bottom) // ensures bar doesn't shift when keyboard shows
    }
}


struct ButtonBarItemDesign: View {
    var iconName: String
    var buttonText: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 22, weight: .regular))
            Text(buttonText)
                .font(.caption2)
        }
        .foregroundColor(.accentColor)
    }
}

