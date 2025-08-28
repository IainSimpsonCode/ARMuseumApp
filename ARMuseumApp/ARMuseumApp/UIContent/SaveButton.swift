//
//  EditModeButton.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 22/01/2025.
//

import SwiftUI

struct SaveButton: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: buttonFunctions.save) {
                    Image(systemName: "square.and.arrow.down") // Save icon
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.accentColor)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Save Changes")
            }
            Spacer()
        }
        .padding([.leading, .bottom, .trailing])
    }
}
