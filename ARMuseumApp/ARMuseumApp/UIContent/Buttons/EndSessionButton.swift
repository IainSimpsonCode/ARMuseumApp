import SwiftUI

struct EndSessionButton: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    var body: some View {
        VStack {
            if (buttonFunctions.sessionRunning) {
                Button(action: {
                    buttonFunctions.endSession()
                }){
                    Text("Stop Session")
                        .bold()
                        .font(.title2)
                        .frame(width: 250, height: 50)
                        .background(Color(.systemBlue))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            Spacer()
        }
    }
}
