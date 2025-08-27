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
                NavigationLink(
                    destination: PanelCreatorView(
                        buttonFunctions: _buttonFunctions,
                        needsClosing: $needsClosing,
                        exhibit: exhibits[index]
                    )
                ) {
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

// MARK: - PanelCreatorView

struct PanelCreatorView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @Environment(\.presentationMode) var presentationMode
    @Binding var needsClosing: Bool

    let exhibit: Exhibit

    @State private var selectedText: String = "nil"
    @State private var selectedColor: Color?
    @State private var selectedIcon: String = "nil"

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(exhibit.imageName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.bottom, 10)
                
                Text("Panel Designer")
                    .font(.system(.title2, design: .rounded).weight(.bold))

                // MARK: Text Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose a text to display")
                        .font(.headline)
                    
                    Picker("Text Option", selection: $selectedText) {
                        ForEach(exhibit.textOptions, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // MARK: Color Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Panel Color")
                        .font(.headline)

                    HStack(spacing: 16) {
                        ForEach(sharedColorOptions, id: \.self) { color in
                            ColorButton(buttonColor: color, isSelected: selectedColor == color) {
                                selectedColor = color
                            }
                        }
                    }
                }

                // MARK: Icon Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Panel Icon")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(sharedIconOptions, id: \.self) { symbol in
                                Button(action: {
                                    selectedIcon = symbol
                                }) {
                                    Image(systemName: symbol)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 36, height: 36)
                                        .padding(10)
                                        .background(selectedIcon == symbol ? Color.blue : Color(.systemGray5))
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

                // MARK: Add Button
                Button(action: {
                    if selectedText != "nil", let selectedColor = selectedColor, selectedIcon != "nil" {
                        buttonFunctions.addPanel(
                            text: exhibit.name + ":\n\n" + selectedText,
                            panelColor: UIColor(selectedColor),
                            panelIcon: selectedIcon
                        )
                        needsClosing = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Add To Scene")
                        .font(.system(.headline, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top, 10)
            }
            .padding(20)
        }
        .navigationTitle(exhibit.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // ✅ Set default selections if not yet set
            if selectedText == "nil" {
                selectedText = exhibit.textOptions.first ?? "nil"
            }
            if selectedColor == nil {
                selectedColor = sharedColorOptions.first
            }
            if selectedIcon == "nil" {
                selectedIcon = sharedIconOptions.first ?? "nil"
            }
        }
    }
}


// MARK: - ColorButton View

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
