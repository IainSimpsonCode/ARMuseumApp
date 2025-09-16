import SwiftUI

struct CuratorLoginScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    
    @State private var curatorID: String = ""
    @State private var curatorPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showPassword: Bool = false

    var comSessionID: Int? = 0
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                if(comSessionID == 0){
                    Text("Curator Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                }
                else{
                    Text("Login to Session")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                }
                
                
                VStack(spacing: 15) {
                    TextField("Username", text: $curatorID)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    ZStack(alignment: .trailing) {
                        if showPassword {
                            TextField("Password", text: $curatorPassword)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Password", text: $curatorPassword)
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
                
                // Inline error message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Button(action: login) {
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
    
    func login() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let response = try await loginServie(
                    museumID: buttonFunctions.sessionDetails.museumID,
                    curatorID: curatorID,
                    curatorPassword: curatorPassword
                )
                
                if response.contains("Login successful.") {
                    print("Login OK")
                    // Call next function here
                } else {
                    errorMessage = "Incorrect username or password. Please try again"
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
