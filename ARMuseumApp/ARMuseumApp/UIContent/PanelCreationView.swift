import SwiftUI

// MARK: - Data Model

struct Exhibit {
    let imageName: String
    let name: String
    let textOptions: [String]
}

// MARK: - Shared Options

let sharedColorOptions: [Color] = [.red, .green, .blue, .orange, .yellow, .purple]

let sharedIconOptions: [String] = [
    "text.book.closed.fill", "list.bullet.clipboard.fill", "books.vertical.fill",
    "person.fill", "globe.europe.africa.fill", "rainbow", "flame.fill"
]

let exhibits: [Exhibit] = [
    Exhibit(imageName: "WashingMachineImage", name: "Washing Machine", textOptions: ["Discovered in 2024", "Used for washing\nclothes", "Consumes 500W per\nhour"]),
    Exhibit(imageName: "DiningTableImage", name: "Dining Table", textOptions: ["Made of oak wood", "Seats up to 6 people", "Used since ancient\ntimes"]),
    Exhibit(imageName: "DoorToKitchenImage", name: "Door to Kitchen", textOptions: ["Connects two rooms", "Made of mahogany", "Installed in 2021"]),
    Exhibit(imageName: "TelescopeImage", name: "Telescope", textOptions: ["Invented in 1608", "Used for astronomy", "Can magnify up to\n1000x"])
]

// MARK: - AddPanelView

struct AddPanelView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @Environment(\.presentationMode) var presentationMode
    @State var needsClosing: Bool

    var body: some View {
        List {
            ForEach(exhibits.indices, id: \.self) { index in
                Button(action: {
                    // Run your code here
                    buttonFunctions.sessionDetails.panelCreationMode = true
                    
                    // Optionally navigate
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 16) {
                        Image(exhibits[index].imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Text(exhibits[index].name)
                            .font(.system(.headline, design: .rounded))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.vertical, 4)
                }
            }

        }
        .listStyle(.insetGrouped)
        .navigationTitle("Exhibits")
        .onAppear {
            if needsClosing {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

import SwiftUI

struct PanelCreatorView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @Environment(\.presentationMode) var presentationMode
    @Binding var needsClosing: Bool

    let exhibit: Exhibit

    @State private var selectedText: String = "nil"
    @State private var selectedColor: Color?
    @State private var selectedIcon: String = "nil"

    var body: some View {
        ZStack {
            Color.clear.edgesIgnoringSafeArea(.all)
            Color.black.opacity(0.2)
                    .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // --- Above center ---
                Text("Panel Designer")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose a text to display")
                        .font(.headline)
                        .foregroundColor(.white)

                    Picker("Text Option", selection: $selectedText) {
                        ForEach(exhibit.textOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Spacer()

                // --- EXACT CENTER: Placeholder ---
                // Centered dummy panel
                    DummyARPanel(
                        text: selectedText,
                        borderColor: selectedColor ?? .blue,
                        icon: selectedIcon
                    )
                    .frame(maxHeight: 200)
                    .padding(.vertical, 20)

                Spacer()

                // --- Below center ---
                VStack(spacing: 16) {
                    // Color Selector
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

                    // Icon Selector
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

                    // Add Button
                    Button(action: {
                        if selectedText != "nil", let selectedColor = selectedColor, selectedIcon != "nil" {
                            buttonFunctions.addPanel(
                                text: exhibit.name + ":\n\n" + selectedText,
                                panelColor: UIColor(selectedColor),
                                panelIcon: selectedIcon
                            )
                            needsClosing = true
                            presentationMode.wrappedValue.dismiss()
                            buttonFunctions.sessionDetails.panelCreationMode = false
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
        }
        .onAppear {
            if selectedText == "nil" { selectedText = exhibit.textOptions.first ?? "nil" }
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

struct DummyARPanel: View {
    let text: String
    let borderColor: Color
    let icon: String

    var body: some View {
        ZStack {
            // Transparent background with colored border
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 2)
                .background(Color.clear)
            
            HStack(spacing: 8) {
                // Icon on the left
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .padding(.leading, 8)
                
                // Panel text
                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 8)
            }
            .padding(.vertical, 8)
        }
        .frame(width: 260, height: 100)
        .shadow(radius: 2) // optional subtle shadow like AR panel
    }
}


