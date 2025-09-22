import SwiftUI
import ARKit

struct StartSessionButton: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    
    let targetNode: SCNNode
    let posterName: String
    
    // State for room selection
    @State private var rooms: [String] = []
    @State private var selectedRoom: String? = nil
    @State private var isLoadingRooms = true
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Instruction
            Text("Place your phone in the correct position for calibration, then select a room and start the session.")
                .multilineTextAlignment(.center)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding(.top, 50)
            
            // Room Picker
            if isLoadingRooms {
                ProgressView("Loading rooms...")
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
            }
            
            // Start button
            Button(action: {
                startSession()
            }) {
                Text("Start Session")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedRoom == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(selectedRoom == nil)
            .padding(.horizontal)
        }
        .onAppear {
            Task {
                await loadRooms()
            }
        }
        .padding()
    }
    
    func startSession() {
        guard !buttonFunctions.sessionRunning, let room = selectedRoom else { return }
        
        // Set the selected room
        buttonFunctions.sessionDetails.roomID = room
        buttonFunctions.sessionDetails.isSessionActive = true
        
        // Start session
        buttonFunctions.startSession(
            node: targetNode,
            posterName: posterName
        )
        
        Task {
            let allPanels = await PanelStorageManager.loadPanels(
                museumID: buttonFunctions.sessionDetails.museumID,
                roomID: buttonFunctions.sessionDetails.roomID
            )
            for panel in allPanels {
                buttonFunctions.placeLoadedPanel(panel: panel)
            }
        }
    }
    
    // Dummy API call to get room names
    func loadRooms() async {
        isLoadingRooms = true
        defer { isLoadingRooms = false }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000) // simulate delay
        rooms = ["TestRoom", "Imaginarium"] // dummy rooms
    }
}
