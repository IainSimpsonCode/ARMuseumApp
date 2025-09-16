import SwiftUI
import SwiftUI
import SceneKit

struct EditPanelView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @Environment(\.presentationMode) var presentationMode
    @Binding var needsClosing: Bool
    
    let panel: ARPanel
    
    @State private var selectedText: String
    @State private var selectedColor: Color
    @State private var selectedIcon: String

    init(panel: ARPanel, needsClosing: Binding<Bool>) {
        self.panel = panel
        self._needsClosing = needsClosing
        self._selectedText = State(initialValue: panel.panelText)
        self._selectedColor = State(initialValue: Color(panel.panelSides.diffuse.contents as? UIColor ?? UIColor.blue))
        self._selectedIcon = State(initialValue: panel.panelIconName)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Edit Panel")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Panel Text")
                        .font(.headline)
                        .foregroundColor(.white)

                    TextEditor(text: $selectedText)
                        .frame(height: 80)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top, 50)

                Spacer()

                PreviewARPanel(
                    text: selectedText,
                    borderColor: selectedColor,
                    icon: selectedIcon
                )
                .frame(maxHeight: 200)
                .padding(.vertical, 20)

                Spacer()

                VStack(spacing: 16) {
                    // Color picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Border Color")
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack(spacing: 16) {
                            ForEach(sharedColorOptions, id: \.self) { color in
                                ColorButton(buttonColor: color, isSelected: selectedColor == color) {
                                    selectedColor = color
                                }
                            }
                        }
                    }

                    // Icon picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Panel Icon")
                            .font(.headline)
                            .foregroundColor(.white)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(sharedIconOptions, id: \.self) { symbol in
                                    Button(action: { selectedIcon = symbol }) {
                                        Image(systemName: symbol)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 36, height: 36)
                                            .padding(10)
                                            .background(selectedIcon == symbol ? Color.blue.opacity(0.5) : Color.clear)
                                            .foregroundColor(selectedIcon == symbol ? .white : .primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.blue, lineWidth: selectedIcon == symbol ? 2 : 0)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }

                    // Update button
                    Button(action: {
                        // Update panel text
                        panel.panelText = selectedText
                        panel.editTextNode(text: selectedText,  color: UIColor.black)
                        
                        // Update border only
                        panel.panelSides.diffuse.contents = UIColor(selectedColor)
                        panel.currentGeometry.materials = [
                            panel.transparentPanelFace,
                            panel.panelSides,
                            panel.panelSides,
                            panel.panelSides,
                            panel.panelSides,
                            panel.panelSides
                        ]

                        // Update icon
                        let newIconImage = UIImage(
                            systemName: selectedIcon,
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 128)
                        ) ?? UIImage(systemName: "questionmark.circle")!

                        panel.iconNode.geometry?.firstMaterial?.diffuse.contents = newIconImage

                        needsClosing = true
                        presentationMode.wrappedValue.dismiss()
                        buttonFunctions.sessionDetails.panelCreationMode = false
                        Task {
                            await updatePanelService(panel: panel.convertToPanel(museumID: buttonFunctions.sessionDetails.museumID, roomID: buttonFunctions.sessionDetails.roomID))
                        }
                    }) {
                        Text("Update Panel")
                            .font(.system(.headline, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            // Back button
            Button(action: {
                needsClosing = true
                presentationMode.wrappedValue.dismiss()
                buttonFunctions.sessionDetails.panelCreationMode = false
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                    Text("Back")
                        .font(.system(.headline, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.5))
                .clipShape(Capsule())
                .padding(.leading)
                .padding(.top, 10)
            }
        }
    }
}
