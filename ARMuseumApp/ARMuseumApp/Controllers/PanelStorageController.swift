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

class PanelStorageManager {
    
    static func savePanel(panel: Panel, sessionSelected: Int, accessToken: String? = nil) async {
        print(panel)
        
        if(sessionSelected == 2){
            await saveCommunityPanelService(panel: panel, museumID: panel.museumID, roomID: panel.roomID, accessToken: accessToken!)
        }
        else{
            await savePanelService(panel: panel)
        }
    }

    static func loadPanels(museumID: String, roomID: String, sessionSelected: Int, accessToken: String? = nil) async -> [Panel] {
        var savedPanels: [Panel] = []
        
        if(sessionSelected == 2){
            savedPanels = await getCommunityPanelsService(museumID: museumID, roomID: roomID, accessToken: accessToken!)
        }
        else{
            savedPanels = await getPanelsByMuseumAndRoomService(museumID: museumID, roomID: roomID)
        }
        print("loaded \(savedPanels.count) panels")
        
        return savedPanels.compactMap { panel in
            let position = SCNVector3(panel.x, panel.y, panel.z)
            
            return Panel(panelID: panel.panelID, museumID: museumID, roomID: roomID, x: panel.x, y: panel.y, z: panel.z, text: panel.text, icon: panel.icon, r: panel.r, g: panel.g, b: panel.b, alpha: panel.alpha, longText: panel.longText, spotlight: panel.spotlight)
        }
    }
    
    static func deletePanelByID(museumID: String, roomID: String, Id id: String, sessionSelected: Int, accessToken: String? = nil) async {
        if(sessionSelected == 2){
            let reponse = await deleteCommunityPanelService(museumID: museumID, roomID: roomID, id: id, accessToken: accessToken!)
        }
        else{
            let response = await deletePanelService(museumID: museumID, roomID: roomID, id: id)
        }
    }
    
    static func handleCommunityUpdates(_ARPanelController: ARPanelController, panels: [Panel], buttonFunctions: ButtonFunctions) async {
        let existingPanels = _ARPanelController.panelsInScene
        
        // Convert existing panels into a dictionary for fast lookup
        var existingDict = Dictionary(uniqueKeysWithValues: existingPanels.map { ($0.panelID, $0) })
        
        // --- Update or Add ---
        for newPanel in panels {
            if let existing = existingDict[newPanel.panelID] {
                var needsUpdate = false
                            
                            if existing.panelText != newPanel.text {
                                needsUpdate = true
                            }
                            if existing.panelIconName != newPanel.icon {
                                needsUpdate = true
                            }
                            
//                            if existing.panelColor != newPanel.panelColor {
//                                needsUpdate = true
//                            }
//                            if existing.detailedText != newPanel.detailedText {
//                                print("detailed")
//                                needsUpdate = true
//                            }
                            
                            if needsUpdate {
                                print("🔄 Updating panel \(newPanel.panelID)")
                            }
            } else {
//                await buttonFunctions.addPanel(text: newPanel.text!, panelColor: convertRGBAToUIColor(r: newPanel.r, g: newPanel.g, b: newPanel.b), panelIcon: newPanel.icon, panelID: newPanel.panelID, positionExisting: position, save: false)
                await buttonFunctions.placeLoadedPanel(panel: newPanel)
            }
            existingDict.removeValue(forKey: newPanel.panelID)

            
        }
        for (_, oldPanel) in existingDict {
            print("🗑 Removing panel \(oldPanel.panelID)")
            if let index = _ARPanelController.panelsInScene.firstIndex(where: { $0.panelID == oldPanel.panelID }) {
                let panelToRemove = _ARPanelController.panelsInScene[index]
                await panelToRemove.parentNode.removeFromParentNode()
                    panelToRemove.panelNodeInScene = false
                _ARPanelController.panelsInScene.remove(at: index)
                }
        }
        
    }

}
