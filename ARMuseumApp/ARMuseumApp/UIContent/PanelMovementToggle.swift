//
//  PanelMovementToggle.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 22/01/2025.
//

//import SwiftUI
//
//struct PanelMovementToggle: View {
//    @EnvironmentObject var buttonFunctions: ButtonFunctions
//
//    var body: some View {
//        if(buttonFunctions.editModeActive) {
//            VStack {
//                ZStack {
//                    Capsule(style: .continuous)
//                        .fill(Color.white.opacity(0.6))
//                        .frame(width: 50, height: 100)
//
//                    VStack {
//                        // First Button
//                        Button(action: {
//                            buttonFunctions.movementModeBool = true
//                        }, label: {
//                            Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
//                                .font(.system(size: 24))
//                                .padding(3)
//                                .background(buttonFunctions.movementModeBool ? Color.green : Color.gray) // Active color if true
//                                .cornerRadius(20)
//                                .frame(width: 30, height: 30)
//                        }).padding(5)
//
//                        // Second Button
//                        Button(action: {
//                            buttonFunctions.movementModeBool = false
//                        }, label: {
//                            Image(systemName: "move.3d")
//                                .font(.system(size: 24))
//                                .padding(3)
//                                .background(!buttonFunctions.movementModeBool ? Color.green : Color.gray) // Active color if false
//                                .cornerRadius(20)
//                                .frame(width: 30, height: 30)
//                        }).padding(5)
//                    }
//                }.offset(x: 168, y: -270)
//            }
//        }
//    }
//}
