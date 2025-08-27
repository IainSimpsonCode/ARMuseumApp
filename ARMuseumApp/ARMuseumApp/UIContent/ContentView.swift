import SwiftUI

struct ContentView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @State private var showRoomPopup = false   // <-- popup state

    var body: some View {
        if buttonFunctions.sessionRunning {
            NavigationView {
                ZStack {
                    ZStack {
                        ARViewContainer(buttonFunctions: buttonFunctions, panelController: ARPanelController())
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)

                        VStack {
                            Spacer()
                            ButtonBar()
                        }.edgesIgnoringSafeArea(.all)

                        AddPanelButton()
                        ImageDetectionOverlay()
                        TutorialButton()
                        EditModeButton()
                        MovingPanelButtons()
                    }
                    .disabled(buttonFunctions.tutorialVisible)

                    TutorialPages()
                }
            }
            .onChange(of: buttonFunctions.currentRoom) { newRoom in
                if let _ = newRoom {
                    showRoomPopup = true
                }
            }
            .alert(isPresented: $showRoomPopup) {
                Alert(
                    title: Text("Room Detected"),
                    message: Text("You are in room \(buttonFunctions.currentRoom ?? "Unknown")"),
                    dismissButton: .default(Text("OK"))
                )
            }
        } else {
            ZStack {
                ZStack {
                    ARViewContainer(buttonFunctions: buttonFunctions, panelController: ARPanelController())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)

                    ImageDetectionOverlay()
                    MovingPanelButtons()
                }
            }
        }
    }
}
