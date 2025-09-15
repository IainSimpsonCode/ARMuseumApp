import SwiftUI

struct ContentView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    
    var body: some View {
        if buttonFunctions.sessionDetails.sessionType == 0{
            SplashScreen()
        }
        else if buttonFunctions.sessionDetails.isSessionActive{
            NavigationView {
                ZStack {
                    //stack the UI on top of the AR Camera
                    ZStack {
                        //AR Camera - will handle all AR related content
                        ARViewContainer(buttonFunctions: buttonFunctions, panelController: ARPanelController())
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                        
                        
                        
                        if(!buttonFunctions.sessionDetails.panelCreationMode){
                            TopBarButtons()
                                .environmentObject(buttonFunctions)
                            
                            //Main UI elements
                            VStack {
                                Spacer()
                                ButtonBar()
                            }.edgesIgnoringSafeArea(.all)
                            
//                            AddPanelButton()
                            
                            ImageDetectionOverlay()
                            
//                            TutorialButton()
                            
                            //PanelMovementToggle()
                            
                            MovingPanelButtons()
                        }
                        else {
                            // Provide a binding for needsClosing
                            @State var needsClosing = false
                            // Provide an actual exhibit, for example the first one
                            let selectedExhibit = exhibits.first!

                            PanelCreatorView(
                                buttonFunctions: _buttonFunctions,
                                needsClosing: $needsClosing, 
                                exhibit: selectedExhibit
                            )
                        }
                        
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
