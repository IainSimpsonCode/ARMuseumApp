import SwiftUI

struct Exhibit {
    let imageName: String
    let name: String
    let textOptions: [String]
}

// Shared color and icon options
let sharedColorOptions: [Color] = [.red, .green, .blue, .orange, .yellow, .purple]
let sharedIconOptions: [String] = [
    "text.book.closed.fill", "list.bullet.clipboard.fill", "books.vertical.fill",
    "person.fill", "globe.europe.africa.fill", "rainbow", "flame.fill"
]

// Sample exhibits data
let exhibits: [Exhibit] = [
    Exhibit(
        imageName: "WashingMachineImage",
        name: "Washing Machine",
        textOptions: ["Discovered in 2024", "Used for washing\nclothes", "Consumes 500W per\nhour"]
    ),
    Exhibit(
        imageName: "DiningTableImage",
        name: "Dining Table",
        textOptions: ["Made of oak wood", "Seats up to 6 people", "Used since ancient\ntimes"]
    ),
    Exhibit(
        imageName: "DoorToKitchenImage",
        name: "Door to Kitchen",
        textOptions: ["Connects two rooms", "Made of mahogany", "Installed in 2021"]
    ),
    Exhibit(
        imageName: "TelescopeImage",
        name: "Telescope",
        textOptions: ["Invented in 1608", "Used for astronomy", "Can magnify up to\n1000x"]
    )
]

struct AddPanelView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @Environment(\.presentationMode) var presentationMode
    @State var needsClosing: Bool
    
    var body: some View {
        List(exhibits.indices, id: \.self) { index in
            NavigationLink(destination: PanelCreatorView(buttonFunctions: _buttonFunctions, needsClosing: $needsClosing, exhibit: exhibits[index]), label: {
                HStack {
                    Image(exhibits[index].imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .cornerRadius(4)
                        .padding(.vertical, 4)
                    
                    Text(exhibits[index].name)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                }
            }).isDetailLink(false)
        }
        .navigationTitle("Exhibits")
        .onAppear {
            if needsClosing {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct PanelCreatorView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @Environment(\.presentationMode) var presentationMode
    @Binding var needsClosing: Bool
    
    let exhibit: Exhibit
    
    @State private var selectedText: String = "nil"
    @State private var selectedColor: Color?
    @State private var selectedIcon: String = "nil"
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Image(exhibit.imageName)
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
            
            Text("Panel Designer")
                .bold()
                .font(.title)
            
            // Text Selector
            Text("Choose a text to display:")
                .font(.headline)

            Picker("", selection: $selectedText) {
                ForEach(exhibit.textOptions, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 280, height: 60)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            
            // Panel color selector
            Text("Select Panel Color:")
                .font(.headline)
            
            HStack(spacing: 16) {
                ForEach(sharedColorOptions, id: \.self) { color in
                    ColorButton(buttonColor: color, isSelected: selectedColor == color) {
                        selectedColor = color
                    }
                }
            }
            .padding(.horizontal, 8)
            
            // Icon Selector
            Text("Panel Icon:")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(sharedIconOptions, id: \.self) { symbol in
                        Button(action: {
                            selectedIcon = symbol
                        }) {
                            Image(systemName: symbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(selectedIcon == symbol ? .white : .blue)
                                .background(selectedIcon == symbol ? Color.blue : Color.clear)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: selectedIcon == symbol ? 2 : 0)
                                )
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            
            Spacer()
            
            Button(action: {
                if selectedText != "nil", let selectedColor = selectedColor, selectedIcon != "nil" {
                    buttonFunctions.addPanel(text: exhibit.name + ":\n\n" + selectedText, panelColor: UIColor(selectedColor), panelIcon: selectedIcon)
                    needsClosing = true
                    presentationMode.wrappedValue.dismiss()
                }
            }){
                Text("Add To Scene")
                    .bold()
                    .font(.title2)
                    .frame(width: 250, height: 50)
                    .background(Color(.systemBlue))
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }
            
        }
        .navigationTitle(exhibit.name)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(20)
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
                        .stroke(isSelected ? Color.black : Color.clear, lineWidth: 3)
                )
        }
    }
}
