import Foundation
import SceneKit

// MARK: - Data Model

struct SavedPanel: Codable {
    let position: [Float]       // [x, y, z]
    let systemImageName: String
    let text: String
    let color: String
    let id: Int
    let currentRoom: String
}

// MARK: - Load Result Model

struct LoadedPanel {
    let position: SCNVector3
    let systemImageName: String
    let text: String
    let color: String
    let id: Int
    let currentRoom: String
}

// MARK: - Storage Manager

class PanelStorageManager {
    
    /// Save a new panel (appends to existing ones, but skips if id already exists)
    static func savePanel(position: SCNVector3, imageName: String, text: String, color: String, id: Int, currentRoom: String) {
        var panels = loadSavedPanels()
        
        // ✅ Check if this id already exists
        if panels.contains(where: { $0.id == id }) {
            print("⚠️ Panel with id \(id) already exists. Skipping save.")
            return
        }
        
        let saved = SavedPanel(
            position: [position.x, position.y, position.z],
            systemImageName: imageName,
            text: text,
            color: color,
            id: id,
            currentRoom: currentRoom
        )
        
        panels.append(saved)
        saveAllPanels(panels)
        print("✅ Panel with id \(id) saved.")
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
                color: panel.color,
                id: panel.id,
                currentRoom: panel.currentRoom
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
        saveAllPanels([])
        print("✅ All panels deleted from storage.")
    }
    
    /// Delete panel by id
    static func deletePanel(byId id: Int) {
        var panels = loadSavedPanels()
        let originalCount = panels.count
        
        panels.removeAll { $0.id == id }
        
        if panels.count < originalCount {
            saveAllPanels(panels)
            print("✅ Panel with id \(id) deleted.")
        } else {
            print("⚠️ No panel found with id \(id).")
        }
    }
    /// Generate the next available ID based on saved panels
        static func generateNextId() -> Int {
            let panels = loadSavedPanels()
            let maxId = panels.map { $0.id }.max() ?? 0
            return maxId + 1
        }
}


