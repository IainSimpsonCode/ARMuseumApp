import Foundation
import SceneKit

// MARK: - Data Model

struct SavedPanel: Codable {
    let position: [Float]       // [x, y, z]
    let systemImageName: String
    let text: String
    let color: String
}

// MARK: - Load Result Model

struct LoadedPanel {
    let position: SCNVector3
    let systemImageName: String
    let text: String
    let color: String
}

// MARK: - Storage Manager

class PanelStorageManager {
    
    /// Save a new panel (appends to existing ones)
    static func savePanel(position: SCNVector3, imageName: String, text: String, color: String) {
        var panels = loadSavedPanels()
        
        print(position)
        let saved = SavedPanel(
            position: [position.x, position.y, position.z],
            systemImageName: imageName,
            text: text,
            color: color
        )
        
        panels.append(saved)
        saveAllPanels(panels)
    }

    /// Load and return `LoadedPanel`s with SCNVector3 positions
    static func loadPanels() -> [LoadedPanel] {
        let savedPanels = loadSavedPanels()
        
        return savedPanels.compactMap { panel in
            guard panel.position.count == 3 else { return nil }
            let position = SCNVector3(panel.position[0], panel.position[1], panel.position[2])
            
            return LoadedPanel(
                position: position,
                systemImageName: panel.systemImageName,
                text: panel.text,
                color: panel.color
            )
        }
    }

    // MARK: - Internal Helpers

    /// Load raw saved panels
    private static func loadSavedPanels() -> [SavedPanel] {
        let url = getSaveURL()
        
        do {
            let data = try Data(contentsOf: url)
            let panels = try JSONDecoder().decode([SavedPanel].self, from: data)
            return panels
        } catch {
            return []
        }
    }
    
    /// Overwrite all saved panels
    private static func saveAllPanels(_ panels: [SavedPanel]) {
        let url = getSaveURL()
        
        do {
            let data = try JSONEncoder().encode(panels)
            try data.write(to: url)
        } catch {
            print("Failed to save panels: \(error)")
        }
    }
    
    /// File URL for saved_panels.json
    private static func getSaveURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("saved_panels.json")
    }
    
    /// Delete all saved panels
    static func deleteAllPanels() {
        let url = getSaveURL()
        do {
            let data = try JSONEncoder().encode([SavedPanel]()) // empty array
            try data.write(to: url)
            print("✅ All panels deleted from storage.")
        } catch {
            print("⚠️ Failed to delete panels: \(error)")
        }
    }

}
