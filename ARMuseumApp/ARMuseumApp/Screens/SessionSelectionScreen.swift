//
//  PanelsService.swift
//  ARMuseumApp
//
//  Created by Senan on 04/09/2025.
//
import SwiftUI

struct SessionSelectionScreen: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @State private var showCommunityScreen = false
    @State private var showLoginScreen = false
    @StateObject private var arModel = ARViewModel()

    var body: some View {
        ZStack {
            ARCameraForMenu(model: arModel)
                        .edgesIgnoringSafeArea(.all)
            
            Color.black
                    .opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                Text("Choose an Option")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                
                Text("\(buttonFunctions.sessionDetails.museumID)")
                    .font(.title3)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.bottom, 50)
                
                    Button(action: privateS) {
                        Text("Private")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: community) {
                        Text("Community")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: curator) {
                        Text("Curator")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .buttonStyle(PlainButtonStyle())
                

                
                Spacer()
            }
            .padding(.top, 100)
        }
        // full-screen modal
        .fullScreenCover(isPresented: $showCommunityScreen) {
            CommunitySessionsScreen()
        }
        .fullScreenCover(isPresented: $showLoginScreen) {
            CuratorLoginScreen()
        }
    }
    
    func privateS() {
        buttonFunctions.sessionDetails.sessionType = 1
    }
    
    func community() {
        showCommunityScreen = true
    }
    
    func curator() {
        showLoginScreen = true
    }
}


