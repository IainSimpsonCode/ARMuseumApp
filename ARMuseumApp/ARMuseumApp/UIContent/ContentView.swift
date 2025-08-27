import SwiftUI

struct ContentView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    
    var body: some View {
        if buttonFunctions.sessionRunning{
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
                        
                        AddPanelButton()
                        
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
        else{
            ZStack {
                //stack the UI on top of the AR Camera
                ZStack {
                    //AR Camera - will handle all AR related content
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
