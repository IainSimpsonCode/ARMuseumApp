//
//  EditModeButton.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 22/01/2025.
//

import SwiftUI

struct EditModeButton: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Button(action: buttonFunctions.toggleEditMode, label: {
                    Image(systemName: "pencil.and.ruler.fill")
                        .font(.system(size: 32))
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(10)
                        .padding(10)
                })
            }
            Spacer()
        }
    }
}
