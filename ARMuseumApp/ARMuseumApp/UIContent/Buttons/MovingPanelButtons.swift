//
//  MovingPanelButtons.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 27/01/2025.
//

import SwiftUI

struct MovingPanelButtons: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    var body: some View {
        if(buttonFunctions.movingPanel){
            VStack {
                Spacer()
                
                HStack(spacing: 16) { // Adjust spacing between buttons
                    Button(action: {
                        buttonFunctions.movePanelButtons(option: 2)
                        buttonFunctions.movingPanel = false
                    }) {
                        Text("X")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 40)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                    
                    Button(action: {
                        // Action for the ✓ button
                        buttonFunctions.movePanelButtons(option: 1)
                        buttonFunctions.movingPanel = false
                        if(buttonFunctions.SessionSelected == 3){
                            Task{
                                await updatePanelService(panel: buttonFunctions.movingPanelPanel!.convertToPanel(museumID: buttonFunctions.sessionDetails.museumID, roomID: buttonFunctions.sessionDetails.roomID))
                            }
                        }
                        else if (buttonFunctions.SessionSelected == 2){
                            Task{
                                await updateCommunityPanelService(panel: buttonFunctions.movingPanelPanel!.convertToPanel(museumID: buttonFunctions.sessionDetails.museumID, roomID: buttonFunctions.sessionDetails.roomID), accessToken:buttonFunctions.accessToken)
                            }
                        }
                    }) {
                        Text("✓")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 40)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }
}
