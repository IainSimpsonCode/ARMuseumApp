import SwiftUI

struct TutorialPages: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions

    var body: some View {
        if buttonFunctions.tutorialVisible {
            VStack {
                TabView {
                    TutorialWelcomePage()
                    TutorialImageScanPage()
                    TutorialEditMode()
                    TutorialEditModePartTwo()
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
            .frame(width: 320, height: 650)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .transition(.scale) // Smooth transition effect
            .zIndex(2) // Ensure tutorial stays on top
        }
    }
}

struct TutorialWelcomePage: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    
    var body: some View {
        VStack {
            Text("Welcome to the App!")
                .font(.title)
                .bold()
                .padding()
            
            Text("This is a quick tutorial to guide you through using this app. Swipe left and right to move across the tutorial pages to learn what you can do.")
                .multilineTextAlignment(.center)
                .padding()
            
            Text("This app will allow you to view and change the content being showed in each exhibit. Shape the information how you like and create your own museum experience.")
                .multilineTextAlignment(.center)
                .padding()
            
            Text("Most importantly, Have Fun!")
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
    }
}

struct TutorialImageScanPage: View {
    var body: some View {
        VStack {
            Text("How To Start")
                .font(.title)
                .bold()
                .padding()
            
            Text("IMAGE WILL GO HERE")
                .bold()
                .padding(60)
            
            Text("To start an experince find a poster in one of the exhibit rooms and face the camera towards it as straight as you can.\n\nYou will then be asked where you want to pull the information from, select one of these options and the panels will be placed in the room.")
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
    }
}

struct TutorialEditMode: View {
    var body: some View {
        VStack {
            Text("Edit Mode Interactions")
                .font(.title)
                .bold()
                .padding()
                .multilineTextAlignment(.center)

            Text("The app gives you many ways to change the panels using diffirent finger movements, as listed below: ")
                .multilineTextAlignment(.center)
                .padding()
            
            Text("Expand Content - You can tap on the panels to expand them to show content or minimise them to show just a icon.")
                .multilineTextAlignment(.leading)
                .padding()
            Text("Move Content - To change where a Information panel is you can hold down on the panel and place it in a new location using the red and green buttons.")
                .multilineTextAlignment(.leading)
                .padding()
            Text("Resize Content - You can change the size of the panel by pinching your fingers inwards/outwards.")
                .multilineTextAlignment(.leading)
                .padding()
            Spacer()
        }
    }
}

struct TutorialEditModePartTwo: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    var body: some View {
        VStack{
            Text("Add, Remove and Edit")
                .font(.title)
                .bold()
                .padding()
                .multilineTextAlignment(.center)
            
            Text("Add Content - You can add new content to the experince by using the Add Panel button on your bottom bar. You can only have one panel for each information text.")
                .multilineTextAlignment(.leading)
                .padding()
            Text("Remove Content - You can press the Trash Can button while in edit mode on any panel and it will remove it from the experince.")
                .multilineTextAlignment(.leading)
                .padding()
            Text("Edit Content - you can press the edit button next to the delete button to change aspects of each panel.")
                .multilineTextAlignment(.leading)
                .padding()
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    buttonFunctions.tutorialVisible = false
                }
            }) {
                Text("Got it!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 100)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            .padding(.top, 10)
            .offset(y: -50)
        }
    }
}
