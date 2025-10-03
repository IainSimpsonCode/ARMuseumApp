import SwiftUI

struct TutorialPages: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions

    var body: some View {
        if buttonFunctions.tutorialVisible {
            VStack {
                TabView {
//                    TutorialWelcomePage()
                    ViewingPanels()
                    AddingAndEditing()
                    TutorialEditMode()
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
            .overlay(
                // Close Button
                Button(action: {
                    buttonFunctions.tutorialVisible = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                }
                .padding(8),
                alignment: .topTrailing
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
            Text("Welcome to AR Museum!")
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

struct ViewingPanels: View {
    var body: some View {
        VStack {
            Text("Viewing Panels")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

                        
            Text("Panels are placed across the room.")
                .multilineTextAlignment(.leading)
                .padding()
            
            Text("Panels expand as you move closer to them, so don't worry if you can't see too many yet.")
                .multilineTextAlignment(.leading)
                .padding()
            
            Text("Panels also shrink as you move further from them so you view isnt cluttered.")
                .multilineTextAlignment(.leading)
                .padding()
            
            Text("Click on a panel to expand it and view more details.")
                .multilineTextAlignment(.leading)
                .padding()
            
        }
    }
}

struct AddingAndEditing: View {
    var body: some View {
        VStack {
            Text("Adding And Editing Panels")
                .font(.title)
                .bold()
                .padding()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("If you're on a private session, changes will be visible only to you and only for the duration of this session")
                .multilineTextAlignment(.leading)
                .padding()
                .fixedSize(horizontal: false, vertical: true)
            
            Text("If you're on a community session, any changes you make will also be visible to other users on the same session.")
                .multilineTextAlignment(.leading)
                .padding()
                .fixedSize(horizontal: false, vertical: true)
            
            Text("To add a new panel, simply click the add panel button at the bottom left of your screen.")
                .multilineTextAlignment(.leading)
                .padding()
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Here you can decide which panel to add (if they're available), edit its icon and colour and then place it into the scene")
                .multilineTextAlignment(.leading)
                .padding()
                .fixedSize(horizontal: false, vertical: true)
            
            
        }
    }
}


struct TutorialEditMode: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    var body: some View {
        VStack {
            Text("Edit Mode Interactions")
                .font(.title)
                .bold()
                .padding()
                .multilineTextAlignment(.center)

            Text("Holding down on a panel gives you the following options:")
                .multilineTextAlignment(.leading)
                .padding()
                .fixedSize(horizontal: false, vertical: true)
            Text("Move Content - To change where a Information panel is you can hold down on the panel and place it in a new location using the red and green buttons.")
                .multilineTextAlignment(.leading)
                .padding()
            Text("Edit Content - you can press the edit button next to the delete button to change aspects of each panel.")
                .multilineTextAlignment(.leading)
                .padding()
            
//            // image at the bottom
//            Image("EditPanelImage")
//                .resizable()
//                .scaledToFit()
//                .frame(height: 100)
//                .padding(.bottom, 20)
            
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
//            Spacer()
        }
    }
}

