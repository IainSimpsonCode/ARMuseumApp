import SwiftUI

struct CommunitySessionsScreen: View {
    @Environment(\.dismiss) var dismiss   // ✅ Allows closing the entire screen
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @State private var sessions: [String] = []
    @State private var selectedSession: String? = nil
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
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
                            destination: CuratorLoginScreen(comSessionID: 1)
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
            .navigationTitle("Community Sessions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {   // ✅ Close the whole screen
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
        }
    }
    
    func fetchSessions() {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let response = try await getCommunitySessionsAPI()
                sessions = response
            } catch {
                errorMessage = "Failed to load sessions: \(error.localizedDescription)"
            }
        }
    }
}

func getCommunitySessionsAPI() async throws -> [String] {
    try await Task.sleep(nanoseconds: 1_000_000_000)
    return ["session123", "session456", "session789"]
}
