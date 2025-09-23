//
//  ButtonBar.swift
//  ARMuseumApp
//

import SwiftUI

struct ButtonBar: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @State private var showingChangeRoomConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Divider()

            HStack {
                Spacer()

                // Add Panel Button
                NavigationLink(
                    destination: AddPanelView(buttonFunctions: _buttonFunctions, needsClosing: false)
                ) {
                    ButtonBarItemDesign(iconName: "plus.circle.fill", buttonText: "Add Panel")
                }
                .disabled(!buttonFunctions.sessionRunning)
                .opacity(buttonFunctions.sessionRunning ? 1.0 : 0.5)

                Spacer()

                Button(action: {
                    showingChangeRoomConfirmation = true
                }) {
                    ButtonBarItemDesign(iconName: "arrow.right.arrow.left", buttonText: "Change Room")
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
        // Confirmation dialog for Change Room
        .confirmationDialog("Are you sure you want to change rooms? You will have to go to the starting point to come back to this room", isPresented: $showingChangeRoomConfirmation, titleVisibility: .visible) {
            Button("Yes, change room", role: .destructive) {
                changeRoom()
            }
            Button("Cancel", role: .cancel) { }
        }
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
        .frame(minWidth: 50)
    }
}

func changeRoom() {
    print("Room changed!")
}
