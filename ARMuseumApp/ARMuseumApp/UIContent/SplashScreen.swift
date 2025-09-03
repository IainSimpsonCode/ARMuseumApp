import SwiftUI

struct Option: Identifiable {
    let id: Int
    let title: String
}

struct SplashScreen: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @State private var selectedOption: Option? = nil
    @State private var showDropdown = false
    @State private var goToNextScreen = false

    let options = [
        Option(id: 1, title: "Museum 1"),
        Option(id: 2, title: "Museum 2"),
        Option(id: 3, title: "Museum 3")
    ]

    var body: some View {
        NavigationView {
            ZStack {
                ARCameraForMenu()
                    .edgesIgnoringSafeArea(.all)
                
                Color.black
                        .opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Welcome to \nAR Museum")
                            .font(.largeTitle)          // makes it big
                            .fontWeight(.bold)          // bold text
                            .multilineTextAlignment(.center)
                            .padding(.top, 50)
                    
                    Spacer() // Push dropdown to bottom

                    // Dropdown menu
                    VStack(spacing: 0) {
                        Button(action: { withAnimation { showDropdown.toggle() } }) {
                            HStack {
                                Text(selectedOption?.title ?? "Select an option")
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
                                ForEach(options) { option in
                                    Button(action: {
                                        selectedOption = option
                                        showDropdown = false
                                        saveSelection(option)
                                    }) {
                                        Text(option.title)
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
                    if selectedOption != nil {
                        Button(action: {
                            buttonFunctions.sessionDetails.museumID = selectedOption!.title
                            goToNextScreen = true
                        }) {
                            Text("Begin")
                                .frame(width: 200, height: 50)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.title2)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(.bottom, 50) // space from bottom

                // NavigationLink to next screen
                NavigationLink(
                    destination: SessionSelectionScreen(),
                    isActive: $goToNextScreen
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .onAppear {
                loadLastSelection()
            }
        }
    }

    // MARK: - Local Storage

    func saveSelection(_ option: Option) {
        UserDefaults.standard.set(option.id, forKey: "lastSelectedOption")
    }

    func loadLastSelection() {
        let savedId = UserDefaults.standard.integer(forKey: "lastSelectedOption")
        if let option = options.first(where: { $0.id == savedId }) {
            selectedOption = option
        }
    }
}




