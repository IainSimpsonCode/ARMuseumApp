//
//  PanelsService.swift
//  ARMuseumApp
//
//  Created by Senan on 04/09/2025.
//
import Foundation
import SceneKit

// MARK: - Data Model

struct SavedPanel: Codable {
    let position: [Float]
    let systemImageName: String
    let text: String
    let color: String
    let id: String
    let currentRoom: String
}

// MARK: - Load Result Model

struct LoadedPanel {
    let position: SCNVector3
    let systemImageName: String
    let text: String
    let color: String
    let id: String
    let currentRoom: String
}


// MARK: - Storage Manager

class PanelStorageManager {
    
    static func savePanel(panel: Panel) async {
        var panelToSave = panel
        
        print(panelToSave)
        
        await savePanelService(panel: panelToSave)
        
    }

    /// Load and return `LoadedPanel`s with SCNVector3 positions
    static func loadPanels(museumID: String, roomID: String) async -> [Panel] {
        let savedPanels = await getPanelsByMuseumAndRoomService(museumID: museumID, roomID: roomID)
        print("loaded \(savedPanels.count) panels")
        
        return savedPanels.compactMap { panel in
            let position = SCNVector3(panel.x, panel.y, panel.z)
            
            return Panel(panelID: panel.panelID, museumID: museumID, roomID: roomID, x: panel.x, y: panel.y, z: panel.z, text: panel.text, icon: panel.icon, r: panel.r, g: panel.g, b: panel.b, alpha: panel.alpha)
        }
    }

    // MARK: - Internal Helpers
    
    static func deletePanelByID(museumID: String, roomID: String, Id id: String) async {
        let response = await deletePanelService(museumID: museumID, roomID: roomID, id: id)
    }
    
}
