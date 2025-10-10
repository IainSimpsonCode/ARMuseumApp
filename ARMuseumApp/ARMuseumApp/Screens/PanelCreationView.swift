//
//  PanelsService.swift
//  ARMuseumApp
//
//  Created by Senan on 04/09/2025.
//
import SwiftUI

// MARK: - Shared Options
let sharedColorOptions: [Color] = [.red, .green, .blue, .orange, .yellow, .purple]

//let sharedIconOptions: [String] = [
//    "text.book.closed.fill", "list.bullet.clipboard.fill", "books.vertical.fill",
//    "person.fill", "globe.europe.africa.fill", "rainbow", "flame.fill"
//]

// MARK: - AddPanelView
struct AddPanelView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @Environment(\.presentationMode) var presentationMode
    @State var needsClosing: Bool
    @State private var panels: [PanelDetails] = []
    @State private var showResetConfirmation = false // New state for modal

    var exhibits: [Exhibits] {
        let grouped = Dictionary(grouping: panels, by: { $0.title })
        return grouped.map { title, panelsForTitle in
            let textOptions = panelsForTitle.map {
                TextAndID(text: $0.text, panelID: $0.panelID)
            }
            let icons = panelsForTitle.map {
                iconByID(panelID: $0.panelID, icon: $0.icon ?? "person.fill")
            }
            let longText = panelsForTitle.map {
                longTextByID(panelID: $0.panelID, longText: $0.longText)
            }
            return Exhibits(title: title, textOptions: textOptions, icon: icons, longTextByID: longText)
        }
    }

    var body: some View {
        Group {
            if exhibits.isEmpty {
                VStack {
                    Spacer()
                    Text("No exhibits available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
            } else {
                List {
                    ForEach(exhibits) { panel in
                        Button(action: {
                            buttonFunctions.sessionDetails.panelCreationMode = true
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
            }
        }
        .navigationTitle("Exhibits")
        .toolbar {
            if buttonFunctions.SessionSelected != 3 {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset Panels") {
                        showResetConfirmation = true
                    }
                }
            }
        }
        .alert(isPresented: $showResetConfirmation) {
            Alert(
                title: Text("Reset Panels"),
                message: Text("This will reset all the panels to their original state. Continue?"),
                primaryButton: .destructive(Text("Reset")) {
                    resetPanels()
                },
                secondaryButton: .cancel()
            )
        }
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

    // Call your actual function here
    func resetPanels() {
    }
}

// MARK: - PanelCreatorView
struct PanelCreatorView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @Environment(\.presentationMode) var presentationMode
    @Binding var needsClosing: Bool
    let exhibit: Exhibits

    @State private var selectedColor: Color?
    @State private var selectedOption: TextAndID?

    // 🧩 Automatically find the correct icon for the selected text
    var currentIcon: String {
        if let selected = selectedOption {
            return exhibit.icon.first(where: { $0.panelID == selected.panelID })?.icon ?? "person.fill"
        }
        return "person.fill"
    }

    var longText: String {
        if let selected = selectedOption {
            return exhibit.longTextByID.first(where: { $0.panelID == selected.panelID })?.longText ?? "More info about this.."
        }
        return "More info about this.."
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background dim layer
            Color.black.opacity(0.3).ignoresSafeArea()

            VStack(spacing: 20) {
                // Title
                Text("Panel Designer")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 4)

                // Picker for text options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose a text to display")
                        .font(.headline)
                        .foregroundColor(.white)

                    Picker("Text Option", selection: $selectedOption) {
                        ForEach(exhibit.textOptions) { option in
                            Text(option.text).tag(option as TextAndID?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top, 40)

                Spacer()

                // ✅ Preview with correct icon
                PreviewARPanel(
                    text: selectedOption?.text ?? "",
                    borderColor: selectedColor ?? .blue,
                    icon: currentIcon
                )
                .frame(maxHeight: 200)
                .padding(.vertical, 20)

                Spacer()

                VStack(spacing: 16) {
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

                    Button(action: {
                        if let selectedOption = selectedOption, let selectedColor = selectedColor {
                            Task {
                                await buttonFunctions.addPanel(
                                    text: selectedOption.text,
                                    panelColor: UIColor(selectedColor),
                                    panelIcon: currentIcon,
                                    panelID: selectedOption.panelID,
                                    longText: longText
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
                            .shadow(radius: 3)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            // ✅ BACK BUTTON
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
            if selectedOption == nil { selectedOption = exhibit.textOptions.first }
            if selectedColor == nil { selectedColor = sharedColorOptions.first }
        }
    }
}



// MARK: - ColorButton
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
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
