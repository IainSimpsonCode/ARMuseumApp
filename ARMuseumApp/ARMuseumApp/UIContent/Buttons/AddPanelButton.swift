//
//  AddPanelButton.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 14/08/2025.
//

import Foundation
import SwiftUI

struct AddPanelButton: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions

    var body: some View {
        VStack {
            // NavigationLink with custom-styled button
            NavigationLink(
                destination: AddPanelView(buttonFunctions: _buttonFunctions, needsClosing: false)
            ) {
                // Custom button design (acts as the label for NavigationLink)
                Text("Add Panel")
                    .bold()
                    .font(.title2)
                    .frame(width: 250, height: 50)
                    .background(Color(.systemBlue))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!buttonFunctions.sessionRunning)
            .opacity(buttonFunctions.sessionRunning ? 1.0 : 0.5)

            Spacer()
        }
    }
}
