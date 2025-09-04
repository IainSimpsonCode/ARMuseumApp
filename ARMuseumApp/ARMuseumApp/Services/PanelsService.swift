//
//  PanelsService.swift
//  ARMuseumApp
//
//  Created by Senan on 04/09/2025.
//

import Foundation

func getPanelsByMuseumAndRoomService(museumID: String, roomID: String) async -> [Panel] {
    let endpoint = "/api/\(museumID)/\(roomID)/panel"
    
    do {
        let data = try await APIService.request(endpoint: endpoint, method: .GET)
        
        // Decode JSON array into [MuseumItem]
        let decoded = try JSONDecoder().decode([Panel].self, from: data)
        return decoded
        
    } catch {
        print("GET API Error: \(error)")
        return []
    }
}

func savePanelService(museumID: String, roomID: String, panel: Panel) async -> String {
    do {
        let endpoint = "/api/\(museumID)/\(roomID)/panel"
        
        // Convert the Codable object to [String: Any]
        let jsonData = try JSONEncoder().encode(panel)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        
        let data = try await APIService.request(endpoint: endpoint, method: .POST, body: jsonObject)
        
        // Convert response Data to String for logging/return
        if let responseString = String(data: data, encoding: .utf8) {
            print("Item posted successfully: \(responseString)")
            return responseString
        } else {
            return "Item posted successfully but could not decode response."
        }
        
    } catch {
        print("POST API Error: \(error)")
        return "POST API Error: \(error.localizedDescription)"
    }
}
