import SwiftUI
import SceneKit

struct ContentView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    
    // Add any state you need for PanelCreatorView
    @State private var needsClosing = false

    // You need a target node for StartSessionButton
    // For now, create a placeholder node; replace with your actual node
    @State private var myNode = SCNNode()
    
    var body: some View {
        if buttonFunctions.sessionDetails.sessionType == 0 {
            SplashScreen()
        }
        else if buttonFunctions.sessionDetails.isSessionActive {
            NavigationView {
                ZStack {
                    ARViewContainer(buttonFunctions: buttonFunctions, panelController: ARPanelController())
                        .edgesIgnoringSafeArea(.all)
                    
                    if !buttonFunctions.sessionDetails.panelCreationMode {
                        TopBarButtons()
                            .environmentObject(buttonFunctions)
                        
                        VStack {
                            Spacer()
                            ButtonBar()
                        }
                        
                        MovingPanelButtons()
                    } else {
                        if let selectedExhibit = buttonFunctions.sessionDetails.selectedExhibit {
                            PanelCreatorView(
                                needsClosing: $needsClosing,
                                exhibit: selectedExhibit
                            )
                            .environmentObject(buttonFunctions)

                        }
                    }
                    
                    TutorialPages()
                }
            }
        }
        else {
            ZStack {
                ARViewContainer(buttonFunctions: buttonFunctions, panelController: ARPanelController())
                    .edgesIgnoringSafeArea(.all)
                
                StartSessionButton(
                    targetNode: myNode,
                    posterName: "SecondPoster"
                )
                .environmentObject(buttonFunctions)
                
                MovingPanelButtons()
            }
        }
    }
}
