import SwiftUI

struct CommunitySessionsScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @State private var sessions: [String] = []
    @State private var selectedSession: String? = nil
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // New states for modal
    @State private var showingAddSessionModal = false
    @State private var newSessionName = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var passwordsMatch = true
    
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
                    } else {
                        List(sessions, id: \.self) { session in
                            NavigationLink(
                                destination: CuratorLoginScreen(comSession: session)
                                    .environmentObject(buttonFunctions)
                            ) {
                                Text(session)
                                    .font(.headline)
                                    .padding(.vertical, 5)
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
                
                // Floating + button
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
                    
                    // Password fields (always visible)
                    TextField("Password", text: $newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Error message if passwords don't match
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
                        
                        // Capture the values before resetting
                        let sessionName = newSessionName
                        let sessionPassword = newPassword
                        
                        // Reset and dismiss modal
                        newSessionName = ""
                        newPassword = ""
                        confirmPassword = ""
                        passwordsMatch = true
                        showingAddSessionModal = false
                        
                        // Now call the async function
                        Task {
                            await addNewCommunitySession(name: sessionName, password: sessionPassword)
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
    
    // Placeholder for your function
    func addNewCommunitySession(name: String, password: String) async {
        await createSessionService(museumID: buttonFunctions.sessionDetails.museumID, name: name, password: password)
        await fetchSessions()
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
