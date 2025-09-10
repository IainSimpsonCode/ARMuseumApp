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
                    buttonFunctions.sessionDetails.panelCreationMode = true
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(exhibits[index].name)
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
                .padding(.top, 50)


                Spacer()

                PreviewARPanel(
                    text: selectedText,
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
                        if selectedText != "nil", let selectedColor = selectedColor, selectedIcon != "nil" {
                            Task {
                                await buttonFunctions.addPanel(
                                    text: exhibit.name + ":\n\n" + selectedText,
                                    panelColor: UIColor(selectedColor),
                                    panelIcon: selectedIcon
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




