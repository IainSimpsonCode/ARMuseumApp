//
//  ImageDetectionLineUp.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 22/01/2025.
//

import SwiftUI

struct ImageDetectionOverlay: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    var body: some View {
        if(!buttonFunctions.sessionRunning){
            ZStack {
                Color.clear
                Rectangle()
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 320, height: 500) // You can adjust the size of the box
                    .overlay(
                        Text("Align Image Here")
                            .foregroundColor(.white)
                            .font(.headline)
                    )
            }
            .edgesIgnoringSafeArea(.all) // Ensures the box is on top of everything

        }
    }
}

