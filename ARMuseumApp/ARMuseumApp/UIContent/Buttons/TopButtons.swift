//
//  TopButtons.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 08/09/2025.
//

import SwiftUI

struct TopBarButtons: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions

    var body: some View {
        VStack {
            HStack {
                // Stop Session Button - top left
                if buttonFunctions.sessionRunning {
                    VStack(spacing: 4) {
                        Button(action: {
                            buttonFunctions.endSession()
                            buttonFunctions.sessionDetails.sessionType = 0 
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.blue.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        Text("Stop")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel("Stop Session")
                }

                Spacer()

                // Tutorial Button - top right
                VStack(spacing: 4) {
                    Button(action: {
                        withAnimation {
                            buttonFunctions.tutorialVisible = true
                        }
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.blue.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    Text("Help")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .accessibilityLabel("Show Tutorial")
            }
            .padding([.top, .leading, .trailing], 20)

            Spacer()
        }
    }
}
