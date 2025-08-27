import SwiftUI

struct TutorialButton: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        buttonFunctions.tutorialVisible = true
                    }
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.accentColor)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Show Tutorial")

                Spacer()
            }
            Spacer()
        }
        .padding([.leading, .bottom, .trailing])
    }
}
