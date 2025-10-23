import SwiftUI

struct StartSessionButton: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @Environment(\.dismiss) private var dismiss
    
    @State private var rooms: [String] = []
    @State private var selectedRoom: String? = nil
    @State private var isLoadingRooms = true
    @State private var showAlert = false
    @State private var showPhonePositionAlert = false

    var body: some View {
        ZStack {
            
            
            VStack {
                VStack(spacing: 16) {
                    HStack {
                        Button(action: { goBack() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                            Text("Back")
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                    
                    Text(buttonFunctions.SessionSelected == 1 ? "Curator's Tour" : "Community Tour")
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("Place your phone in the correct position for calibration, then select a room and start the session.")
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                    
                    if isLoadingRooms {
                        ProgressView("Loading rooms...")
                    } else if rooms.isEmpty {
                        Text("No rooms found.")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Picker("Select Room", selection: $selectedRoom) {
                            Text("Select a room").tag(String?.none)
                            ForEach(rooms, id: \.self) { room in
                                Text(room).tag(String?.some(room))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                    
                    Spacer()
                }
                
                // Bottom pinned button
                Button(action: {
                    guard selectedRoom != nil else {
                        showAlert = true
                        return
                    }
                    showPhonePositionAlert = true
                }) {
                    Text("Calibrate And Start")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedRoom == nil || rooms.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            Task { await loadRooms() }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Room Not Selected"),
                message: Text("Please select a room before starting the session."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("Is your phone in the correct start position?", isPresented: $showPhonePositionAlert) {
            Button("Yes (Proceed)") { proceedToStartSession() }
            Button("No (Go Back)", role: .cancel) { /* do nothing */ }
        }
    }
    
    func proceedToStartSession() {
        guard !buttonFunctions.sessionRunning else { return }
        guard let room = selectedRoom else {
            showAlert = true
            return
        }

        buttonFunctions.sessionDetails.roomID = room
        buttonFunctions.sessionDetails.isSessionActive = true
        buttonFunctions.startSession()
        
        Task {
            let allPanels = await PanelStorageManager.loadPanels(
                museumID: buttonFunctions.sessionDetails.museumID,
                roomID: buttonFunctions.sessionDetails.roomID,
                sessionSelected: buttonFunctions.SessionSelected,
                accessToken: buttonFunctions.accessToken
            )
            for panel in allPanels {
                buttonFunctions.placeLoadedPanel(panel: panel)
            }
        }
        
        buttonFunctions.isDrawingMode = false
        buttonFunctions.isEraserMode = false
    }
    
    func loadRooms() async {
        isLoadingRooms = true
        defer { isLoadingRooms = false }
        rooms = await getRoomsService(museumID: buttonFunctions.sessionDetails.museumID)
    }
    
    func goBack() {
        buttonFunctions.SessionSelected = 0
    }
}
