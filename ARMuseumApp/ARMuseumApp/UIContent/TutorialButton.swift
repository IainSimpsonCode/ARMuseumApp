//
//  TutorialButton.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 28/01/2025.
//

import SwiftUI

struct TutorialButton: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    var body: some View {
        VStack {
            HStack{
                Button(action: {
                    withAnimation {
                        buttonFunctions.tutorialVisible = true
                    }
                },
                label: {
                    Image(systemName: "questionmark")
                        .font(.system(size: 36))
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(10)
                        .padding(10)
                })
                Spacer()
            }
            Spacer()
        }
    }
}
