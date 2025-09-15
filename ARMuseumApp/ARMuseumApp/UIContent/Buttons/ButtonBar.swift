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
            Divider()

            HStack {
                Spacer()

//                // End Session Button
//                Button(action: { buttonFunctions.endSession() }) {
//                    ButtonBarItemDesign(
//                        iconName: "xmark.circle.fill",
//                        buttonText: "End"
//                    )
//                }
//                .disabled(!buttonFunctions.sessionRunning)
//                .opacity(buttonFunctions.sessionRunning ? 1.0 : 0.4)
//                
//                Spacer()

                NavigationLink(
                    destination: AddPanelView(buttonFunctions: _buttonFunctions, needsClosing: false)
                ) {
                    ButtonBarItemDesign(iconName: "plus.circle.fill", buttonText: "Add Panel")
                }
                .disabled(!buttonFunctions.sessionRunning)
                .opacity(buttonFunctions.sessionRunning ? 1.0 : 0.5)
                
                Spacer()
                
                // Capture Button
                NavigationLink(destination: ScreenShotView(buttonFunctions: _buttonFunctions)) {
                    ButtonBarItemDesign(iconName: "camera.fill", buttonText: "Capture")
                }

                Spacer()

                // Draw / Stop Drawing Button
                Button(action: { buttonFunctions.toggleDrawingMode() }) {
                    ButtonBarItemDesign(
                        iconName: buttonFunctions.isDrawingMode ? "paintbrush.fill" : "paintbrush",
                        buttonText: buttonFunctions.isDrawingMode ? "Stop Drawing" : "Draw"
                    )
                    .foregroundColor(buttonFunctions.isDrawingMode ? .blue : .accentColor)
                }

                Spacer()

                // Erase Button — show only if drawing mode is active
                if buttonFunctions.isDrawingMode {
                    Button(action: { buttonFunctions.toggleEraserMode() }) {
                        ButtonBarItemDesign(
                            iconName: buttonFunctions.isEraserMode ? "eraser.fill" : "eraser",
                            buttonText: buttonFunctions.isEraserMode ? "Stop Erasing" : "Erase"
                        )
                        .foregroundColor(buttonFunctions.isEraserMode ? .red : .accentColor)
                    }
                    Spacer()
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(.ultraThinMaterial)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
        .frame(minWidth: 50) // keep items uniform
    }
}


