//
//  PanelsService.swift
//  ARMuseumApp
//
//  Created by Senan on 04/09/2025.
//
import SwiftUI

struct CuratorLoginScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    
    @State private var curatorID: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showPassword: Bool = false
    
    var comSession: String? = "" // community sess
    var requireLogin: Bool = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                if comSession == "" {
                    Text("Curator Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                } else {
                    Text("Login to \(comSession ?? "")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                }
                
                if requireLogin {
                    // Show username/password fields
                    VStack(spacing: 15) {
                        if comSession == "" {
                            TextField("Username", text: $curatorID)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                            ZStack(alignment: .trailing) {
                                if showPassword {
                                    TextField("Password", text: $password)
                                        .padding()
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(10)
                                        .autocapitalization(.none)
                                } else {
                                    SecureField("Password", text: $password)
                                        .padding()
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(10)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 15)
                                }
                            }                        
                    }
                    .padding(.horizontal, 20)
                } else {
                    // Show text saying “Connect to session” if login not required
                    if let sessionName = comSession {
                        Text("Connect to \(sessionName)")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.vertical)
                    }
                }
                
                // Inline error message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Login button
                Button(action: requireLogin ? (comSession == "" ? loginCurator : loginCommunity) : loginCommunity) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    } else {
                        Text("Login")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading)
                .padding(.horizontal, 20)
                
                Spacer()
            }

            .navigationTitle("")
            .navigationBarHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
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
    
    func loginCurator() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let response = try await loginServie(
                    museumID: buttonFunctions.sessionDetails.museumID,
                    curatorID: curatorID,
                    curatorPassword: password
                )
                
                if response.contains("Login successful.") {
                    buttonFunctions.SessionSelected = 3
                } else {
                    errorMessage = "Incorrect username or password. Please try again"
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func loginCommunity() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            if(!requireLogin){
                password = "password"
            }
            do {
                let response = try await joinCommunitySessionService(
                    museumID: buttonFunctions.sessionDetails.museumID,
                    name: comSession!,
                    password: password
                )

                if response.contains("Incorrect password") || response.contains("API Error"){
                    errorMessage = "Incorrect password. Please try again"
                } else {
                    // store accessToken if needed
                    buttonFunctions.SessionSelected = 2
                    buttonFunctions.accessToken = response
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    
}
