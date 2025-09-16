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
        print(error)
        return []
    }
}

func savePanelService(panel: Panel) async -> String {
    do {
        let endpoint = "/api/\(panel.museumID)/\(panel.roomID)/panel"
        
        
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
        return "API Error: \(error.localizedDescription)"
    }
}

func deletePanelService(museumID: String, roomID: String,id: String) async -> String {
    do {
        let endpoint = "/api/\(museumID)/\(roomID)/panel"
        
        // Create dictionary directly
        let jsonObject: [String: Any] = ["panelID": id]
        
        // Convert dictionary to Data
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        
        // Make the API request
        let data = try await APIService.request(endpoint: endpoint, method: .DELETE, body: jsonObject)
        
        // Convert response Data to String
        if let responseString = String(data: data, encoding: .utf8) {
            print("Request posted successfully: \(responseString)")
            return responseString
        } else {
            return "Request posted successfully but could not decode response."
        }
        
    } catch {
        return "API Error: \(error.localizedDescription)"
    }
}

func updatePanelService(panel: Panel) async -> String {
    do {
        let endpoint = "/api/\(panel.museumID)/\(panel.roomID)/panel"

        // Prepare fields dictionary
        let fields: [String: Any] = [
            "x": panel.x,
            "y": panel.y,
            "z": panel.z,
            "alpha": panel.alpha,
            "icon": panel.icon,
        ]

        // Wrap with docID
        let jsonObject: [String: Any] = [
            "panelID": panel.panelID,
            "fields": fields
        ]

        // Make the API request
        let data = try await APIService.request(endpoint: endpoint, method: .PATCH, body: jsonObject)

        if let responseString = String(data: data, encoding: .utf8) {
            print("Request posted successfully: \(responseString)")
            return responseString
        } else {
            return "Request posted successfully but could not decode response."
        }
    } catch {
        return "API Error: \(error.localizedDescription)"
    }
}

func getNewPanelsService(museumID: String, roomID: String) async -> [PanelDetails] {
    let endpoint = "/api/\(museumID)/\(roomID)/curator/availablePanels"
    
    do {
        let data = try await APIService.request(endpoint: endpoint, method: .GET)
        
        // Decode JSON array into [MuseumItem]
        let decoded = try JSONDecoder().decode([PanelDetails].self, from: data)
        return decoded
        
    } catch {
        print(error)
        return []
    }
}


