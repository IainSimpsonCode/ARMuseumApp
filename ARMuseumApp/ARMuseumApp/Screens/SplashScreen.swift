//
//  PanelsService.swift
//  ARMuseumApp
//
//  Created by Senan on 04/09/2025.
//
import SwiftUI
import RealityKit
import ARKit

struct SplashScreen: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @State private var museums: [String] = []
    @State private var selectedMuseum: String? = nil
    @State private var showDropdown = false
    @State private var goToNextScreen = false
    @State var arModel: ARViewModel
    
    @State private var serverUp = false
    @State private var showServerModal = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // AR Camera view safely wrapped
                ARCameraForMenu(model: arModel)
                    .edgesIgnoringSafeArea(.all)
                
                Color.black
                    .opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Welcome to \nAR Museum")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    // Dropdown + Begin button
                    VStack {
                        // Dropdown
                        VStack(spacing: 0) {
                            Button(action: { withAnimation { showDropdown.toggle() } }) {
                                HStack {
                                    Text(selectedMuseum ?? "Select an option")
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: showDropdown ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(width: 300)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 4)
                            }
                            
                            if showDropdown {
                                VStack(spacing: 0) {
                                    ForEach(museums, id: \.self) { museum in
                                        Button(action: {
                                            selectedMuseum = museum
                                            showDropdown = false
                                            saveSelection(museum)
                                        }) {
                                            Text(museum)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.white)
                                                .foregroundColor(.black)
                                        }
                                        Divider()
                                    }
                                }
                                .frame(width: 300)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 4)
                                .transition(.move(edge: .top))
                            }
                        }
                        
                        // Begin button
                        if selectedMuseum != nil && serverUp {
                            Button(action: {
                                buttonFunctions.sessionDetails.museumID = selectedMuseum!
                                goToNextScreen = true
                                
                            }) {
                                Text("Begin")
                                    .frame(width: 200, height: 50)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .font(.title2)
                            }
                            .padding(.top, 20)
                        }
                    }
                    .padding(.bottom, 50)
                    
                    // NavigationLink
                    NavigationLink(
                        destination: SessionSelectionScreen(),
                        isActive: $goToNextScreen
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                
                // MARK: - Server Down Modal
                if showServerModal {
                        VStack(spacing: 12) {
                            Text("Flipping the server switch…")
                                .font(.headline)

                            Text(serverUp ? "And we’re live again!" :
                                 "Server’s on a coffee break.\nGive it a minute to recharge.")
                                .multilineTextAlignment(.center)
                                .font(.subheadline)


                            if !serverUp {
                                ProgressView()
                                    .padding(.top, 8)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .frame(maxWidth: 300)
                    }

            }
            .onAppear {
                loadLastSelection()
                checkServerHealth()
            }
        }
    }
    
    // MARK: - Local Storage
    func saveSelection(_ museum: String) {
        UserDefaults.standard.set(museum, forKey: "lastSelectedMuseum")
        selectedMuseum = museum
    }
    
    func loadLastSelection() {
        if let savedMuseum = UserDefaults.standard.string(forKey: "lastSelectedMuseum") {
            selectedMuseum = savedMuseum
        }
    }
    
    // MARK: - Load Museums from API
    func loadMuseums() {
        Task {
            self.museums = await getMuseumsService()
        }
        
    }
    
    // MARK: - Server Health Check
    func checkServerHealth() {
        showServerModal = false  // Start with modal hidden

        Task {
            // Start a timer to show the modal after 2s if still waiting
            let timerTask = Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                if !Task.isCancelled {  // Only show if not cancelled
                    showServerModal = true
                }
            }

            let message = await healthCheckService()

            // Cancel the timer if the API finished in time
            timerTask.cancel()

            if message.contains("Server is OK and online.") {
                serverUp = true
                showServerModal = false  // Hide modal when server is up
                loadMuseums()
            } else {
                serverUp = false
                showServerModal = true   // Show modal if server is down
                try? await Task.sleep(nanoseconds: 10_000_000_000) // Retry in 10s
                checkServerHealth()
            }
        }
    }


}
