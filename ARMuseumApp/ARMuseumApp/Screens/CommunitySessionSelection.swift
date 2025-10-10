//
//  PanelsService.swift
//  ARMuseumApp
//
//  Created by Senan on 04/09/2025.
//
import SwiftUI

struct CommunitySessionsScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @State private var sessions: [session] = []
    @State private var selectedSession: String? = nil
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // New states for modal
    @State private var showingAddSessionModal = false
    @State private var newSessionName = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var passwordsMatch = true
    @State private var isPrivate: Bool = true // true = private, false = public
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if isLoading {
                        ProgressView("Loading Sessions...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .padding()
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else if sessions.isEmpty {
                        Text("No community sessions found.")
                            .foregroundColor(.gray)
                            .italic()
                            .padding()
                    } else {
                        List(sessions, id: \.self) { session in
                            NavigationLink(
                                destination: CuratorLoginScreen(comSession: session.sessionID, requireLogin: session.isPrivate)
                                    .environmentObject(buttonFunctions)
                            ) {
                                HStack {
                                    Text(session.sessionID) // adjust according to your session model
                                        .font(.headline)
                                        .padding(.vertical, 5)
                                    
                                    if session.isPrivate {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddSessionModal = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Community Sessions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
            .onAppear {
                fetchSessions()
            }
            .sheet(isPresented: $showingAddSessionModal) {
                VStack(spacing: 16) {
                    Text("Add Community Session")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                    
                    TextField("Session Name", text: $newSessionName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Password", text: $newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Toggle("Private Session", isOn: $isPrivate)
                                .padding(.vertical)
                    
                    if !passwordsMatch {
                        Text("Passwords do not match")
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    
                    Button(action: {
                        guard !newSessionName.isEmpty, !newPassword.isEmpty else { return }
                        guard newPassword == confirmPassword else {
                            passwordsMatch = false
                            return
                        }
                        
                        let sessionName = newSessionName
                        let sessionPassword = newPassword
                        
                        // Reset modal
                        newSessionName = ""
                        newPassword = ""
                        confirmPassword = ""
                        passwordsMatch = true
                        showingAddSessionModal = false
                        
                        Task {
                            await addNewCommunitySession(name: sessionName, password: sessionPassword, isPrivate: isPrivate)
                        }
                    }) {
                        Text("Create Session")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom)
                }
                .padding()
            }
        }
    }
    
    func fetchSessions() {
        isLoading = true
        errorMessage = nil
        Task {
            defer { isLoading = false }
            do {
                let response = try await getCommunitySessionsService(museumID: buttonFunctions.sessionDetails.museumID)
                sessions = response
            } catch {
                errorMessage = "Failed to load sessions: \(error.localizedDescription)"
            }
        }
    }
    
    func addNewCommunitySession(name: String, password: String, isPrivate: Bool) async {
        await createSessionService(museumID: buttonFunctions.sessionDetails.museumID, name: name, password: password, isPrivate: isPrivate)
        await fetchSessionsAsync()
    }
    
    func fetchSessionsAsync() async {
        do {
            let response = try await getCommunitySessionsService(museumID: buttonFunctions.sessionDetails.museumID)
            sessions = response
        } catch {
            errorMessage = "Failed to load sessions: \(error.localizedDescription)"
        }
    }
}
