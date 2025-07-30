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
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // stretch to fill the screen
                        .edgesIgnoringSafeArea(.all)
                    
                    //Main UI elements

                    //Show this VStack at the bottom of the screen
                    VStack {
                        Spacer() // Push the buttons to the bottom
                        ButtonBar()
                    }.edgesIgnoringSafeArea(.all)
                    
                    // Other UI elements are placed on top of the AR view
                    EndSessionButton()
                    
                    ImageDetectionOverlay()
                    
                    TutorialButton()
                    
                    EditModeButton()
                    //PanelMovementToggle()
                    
                    MovingPanelButtons()
                }.disabled(buttonFunctions.tutorialVisible) // Disable interaction when tutorial is visible
                
                // Show the tutorial pages above all other content
                TutorialPages()
            }
        }
    }
}
