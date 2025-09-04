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
                
                Text("You selected: \(buttonFunctions.sessionDetails.museumID)")
                    .font(.title3)
                    .padding()
                
                Button("Private", action: handleOption1)
                    .buttonStyle(.borderedProminent)
                
                Button("Community", action: handleOption2)
                    .buttonStyle(.borderedProminent)
                
                Button("Curator", action: handleOption3)
                    .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding(.top, 100)
        }
        // full-screen modal
        .fullScreenCover(isPresented: $showCommunityScreen) {
            CommunityScreen()
        }
        .fullScreenCover(isPresented: $showLoginScreen) {
            CuratorLoginScreen()
        }
    }
    
    func handleOption1() {
        print("Option 1 selected")
        buttonFunctions.sessionDetails.sessionType = 1
    }
    
    func handleOption2() {
        print("Option 2 selected")
        showCommunityScreen = true   // <-- triggers full-screen modal
    }
    
    func handleOption3() {
        print("Option 3 selected")
        showLoginScreen = true
    }
}

struct CommunityScreen: View {
    @Environment(\.dismiss) var dismiss  // used to close the modal
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.green.opacity(0.3).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Community Screen")
                        .font(.largeTitle)
                        .padding()
                    
                    Text("Community Session Screen")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                }
            }
            .navigationBarTitle("", displayMode: .inline) // optional: empty title
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                            Text("Back")
                        }
                    }
                }
            }
        }
    }
}

struct CuratorLoginScreen: View {
    @Environment(\.dismiss) var dismiss  // used to close the modal
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.green.opacity(0.3).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Login Screen")
                        .font(.largeTitle)
                        .padding()
                    
                    
                    
                    Spacer()
                }
            }
            .navigationBarTitle("", displayMode: .inline) // optional: empty title
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                            Text("Back")
                        }
                    }
                }
            }
        }
    }
}
