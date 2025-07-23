import SwiftUI

struct ContentView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    
    var body: some View {
        NavigationView {
            ZStack {
                //stack the UI on top of the AR Camera
                ZStack {
                    //AR Camera - will handle all AR related content
                    ARViewContainer(buttonFunctions: buttonFunctions, panelController: ARPanelController())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    
                    //Main UI elements
                    VStack {
                        Spacer()
                        ButtonBar()
                    }.edgesIgnoringSafeArea(.all)
                    
                    EndSessionButton()
                    
                    ImageDetectionOverlay()
                    
                    TutorialButton()
                    
                    EditModeButton()
                    //PanelMovementToggle()
                    
                    MovingPanelButtons()
                }.disabled(buttonFunctions.tutorialVisible)
                
                TutorialPages()
            }
        }
    }
}
