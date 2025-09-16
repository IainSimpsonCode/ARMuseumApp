import SwiftUI

// MARK: - Shared Options

let sharedColorOptions: [Color] = [.red, .green, .blue, .orange, .yellow, .purple]

let sharedIconOptions: [String] = [
    "text.book.closed.fill", "list.bullet.clipboard.fill", "books.vertical.fill",
    "person.fill", "globe.europe.africa.fill", "rainbow", "flame.fill"
]

struct AddPanelView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @Environment(\.presentationMode) var presentationMode
    @State var needsClosing: Bool
    @State private var panels: [PanelDetails] = []  // Loaded panels

    var exhibits: [Exhibits] {
        // Group panels by title
        let grouped = Dictionary(grouping: panels, by: { $0.title })
        
        return grouped.map { title, panelsForTitle in
            // Convert each panel to TextAndID
            let textOptions = panelsForTitle.map { TextAndID(text: $0.text, panelID: $0.panelID) }
            return Exhibits(title: title, textOptions: textOptions)
        }
    }


    var body: some View {
        List {
            ForEach(exhibits) { panel in
                Button(action: {
                    buttonFunctions.sessionDetails.panelCreationMode = true
                    
                    // Assign the selected panel to some shared object if needed
                    buttonFunctions.sessionDetails.selectedExhibit = panel
                    
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(panel.title)
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Exhibits")
        .onAppear {
            if needsClosing { presentationMode.wrappedValue.dismiss() }
            Task {
                panels = await getNewPanelsService(
                    museumID: buttonFunctions.sessionDetails.museumID,
                    roomID: buttonFunctions.sessionDetails.roomID
                )
            }
        }
    }
}



import SwiftUI

struct PanelCreatorView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @Environment(\.presentationMode) var presentationMode
    @Binding var needsClosing: Bool

    let exhibit: Exhibits

    @State private var selectedColor: Color?
    @State private var selectedIcon: String = "nil"
    @State private var selectedOption: TextAndID?

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Your AR background stays behind everything
            Color.clear.edgesIgnoringSafeArea(.all)
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Panel Designer")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose a text to display")
                        .font(.headline)
                        .foregroundColor(.white)

                    Picker("Text Option", selection: $selectedOption) {
                        ForEach(exhibit.textOptions, id: \.self) { option in
                            Text(option.text).tag(option) // tag now matches type of selectedOption
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top, 50)


                Spacer()

                PreviewARPanel(
                    text: selectedOption?.text ?? "",
                    borderColor: selectedColor ?? .blue,
                    icon: selectedIcon
                )
                .frame(maxHeight: 200)
                .padding(.vertical, 20)

                Spacer()

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Panel Color")
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

                    Button(action: {
                        if selectedOption!.text != "nil", let selectedColor = selectedColor, selectedIcon != "nil" {
                            Task {
                                await buttonFunctions.addPanel(
                                    text: exhibit.title + ":\n\n" + selectedOption!.text,
                                    panelColor: UIColor(selectedColor),
                                    panelIcon: selectedIcon,
                                    panelID: selectedOption!.panelID
                                )
                                needsClosing = true
                                presentationMode.wrappedValue.dismiss()
                                buttonFunctions.sessionDetails.panelCreationMode = false
                            }
                        }
                    }) {
                        Text("Add To Scene")
                            .font(.system(.headline, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

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
        .onAppear {
            if selectedOption == nil {
                    selectedOption = exhibit.textOptions.first
                }
            if selectedColor == nil { selectedColor = sharedColorOptions.first }
            if selectedIcon == "nil" { selectedIcon = sharedIconOptions.first ?? "nil" }
        }
    }
}


struct ColorButton: View {
    let buttonColor: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(buttonColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}




