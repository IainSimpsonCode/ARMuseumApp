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
                    Section {
                            Text("Select an exhibit below to view all the available panels for the exhibit")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 4)
                        }
                    
                    ForEach(exhibits) { panel in
                        Button(action: {
                            buttonFunctions.sessionDetails.panelCreationMode = true
                            buttonFunctions.sessionDetails.selectedExhibit = panel
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text(panel.title)
                                    .font(.system(.headline, design: .rounded))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.9)
                                Spacer() // pushes text to the left, fills row
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            .contentShape(Rectangle()) // makes the whole HStack tappable
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

    func resetPanels() {
        if(buttonFunctions.SessionSelected == 2){
            Task{
                await resetCommunityPanelsService(museumID: buttonFunctions.sessionDetails.museumID, roomID: buttonFunctions.sessionDetails.roomID, accessToken: buttonFunctions.accessToken)
            }
        }
        else if(buttonFunctions.SessionSelected == 1){
            Task{
                await resetPanelsService(museumID: buttonFunctions.sessionDetails.museumID, roomID: buttonFunctions.sessionDetails.roomID)
            }
        }
        
    }
}

// MARK: - PanelCreatorView
import SwiftUI

struct PanelCreatorView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    @Environment(\.presentationMode) var presentationMode
    @Binding var needsClosing: Bool
    let exhibit: Exhibits

    @State private var selectedColor: Color?
    @State private var selectedOption: TextAndID?

    var currentIcon: String {
        if let selected = selectedOption {
            return exhibit.icon.first(where: { $0.panelID == selected.panelID })?.icon ?? "person.fill"
        }
        return "person.fill"
    }

    var currentLongText: String {
        if let selected = selectedOption {
            return exhibit.longTextByID.first(where: { $0.panelID == selected.panelID })?.longText ?? ""
        }
        return ""
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.3).ignoresSafeArea()

            VStack(spacing: 20) {

                // TITLE
                Text("Panel Designer")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 4)

                // PICKER: show all panels with title + icon
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose a panel to display")
                        .font(.headline)
                        .foregroundColor(.white)

                    Menu {
                        ForEach(exhibit.textOptions) { option in
                            Button(action: {
                                selectedOption = option
                            }) {
                                Label(
                                    option.text,
                                    systemImage: exhibit.icon.first(where: { $0.panelID == option.panelID })?.icon ?? "person.fill"
                                )
                                .foregroundColor(.white) // this works
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedOption?.text ?? "Select Panel")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                }
                .padding(.top, 20)

                Spacer()

                // PREVIEW PANEL
                VStack(spacing: 12) {
                    PreviewARPanel(
                        text: selectedOption?.text ?? "",
                        borderColor: selectedColor ?? .blue,
                        icon: currentIcon
                    )
                    .frame(maxHeight: 200)
                    .padding(.vertical, 8)

                    // SHOW LONGTEXT WHEN PANEL SELECTED
                    if let _ = selectedOption {
                        ScrollView {
                            Text(currentLongText)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .frame(maxHeight: 150)
                        .transition(.slide)
                    }
                }

                Spacer()

                // COLOR + ADD BUTTON
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
                                    longText: currentLongText
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

            // BACK BUTTON
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
