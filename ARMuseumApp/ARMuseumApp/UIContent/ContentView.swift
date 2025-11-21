import SwiftUI
import SceneKit

struct ContentView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    
    @State private var needsClosing = false

    @State private var myNode = SCNNode()
    @EnvironmentObject var arModel: ARViewModel

    var body: some View {
        if buttonFunctions.SessionSelected == 0 {
            
//            NavigationView {
//                ZStack {
//                // Camera always at the back
//                ARCameraForMenu(model: arModel)
//                    .edgesIgnoringSafeArea(.all)

                // Then overlay splash content
                    SplashScreen()
//                }
//                
//            }
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
                // Camera background
                CameraView()
                    .edgesIgnoringSafeArea(.all)
                
                // Semi-transparent overlay
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                StartSessionButton()
                    .environmentObject(buttonFunctions)
                
                MovingPanelButtons()
            }
            
        }
    }
}
