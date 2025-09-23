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
            
            return Panel(panelID: panel.panelID, museumID: museumID, roomID: roomID, x: panel.x, y: panel.y, z: panel.z, text: panel.text, icon: panel.icon, r: panel.r, g: panel.g, b: panel.b, alpha: panel.alpha)
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
}
