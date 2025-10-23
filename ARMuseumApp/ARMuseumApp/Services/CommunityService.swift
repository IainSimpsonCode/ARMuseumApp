//
//  CommunityService.swift
//  ARMuseumApp
//
//  Created by Senan on 17/09/2025.
//

import Foundation


func getCommunitySessionsService(museumID: String) async -> [session] {
    let endpoint = "/api/\(museumID)/community"
    
    do {
        let data = try await APIService.request(endpoint: endpoint, method: .GET)
        
        // Decode JSON array
        let decoded = try JSONDecoder().decode([session].self, from: data)
        return decoded
        
    } catch {
        print(error)
        return []
    }
}

func createSessionService(museumID: String, name: String, password: String, isPrivate: Bool) async -> String {
    do {
        let endpoint = "/api/\(museumID)/community"
        
        let jsonObject: [String: Any] = ["sessionID": name, "sessionPassword": password]
        
        // Convert dictionary to Data
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        
        // Make the API request
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

func joinCommunitySessionService(museumID: String, name: String, password: String) async -> String {
    do {
        let endpoint = "/api/\(museumID)/community/join"
        
        let jsonObject: [String: Any] = [
            "sessionID": name,
            "sessionPassword": password
        ]
        
        // Make the API request
        let data = try await APIService.request(endpoint: endpoint, method: .POST, body: jsonObject)
        
        // Parse JSON response
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let message = json["message"] as? String {
            print(message)
            return message
        } else {
            return "Unexpected response format"
        }
        
    } catch {
        return "API Error: \(error.localizedDescription)"
    }
}

func getCommunityPanelsService(museumID: String, roomID: String, accessToken: String) async -> [Panel] {
    let endpoint = "/api/\(museumID)/\(roomID)/community/\(accessToken)/panel"
    
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

func saveCommunityPanelService(panel: Panel, museumID: String, roomID: String, accessToken: String) async -> String {
    do {
        let endpoint = "/api/\(museumID)/\(roomID)/community/\(accessToken)/panel"
        
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

func updateCommunityPanelService(panel: Panel, accessToken: String) async -> String {
    do {
        let endpoint = "/api/\(panel.museumID)/\(panel.roomID)/community/\(accessToken)/panel"

        // Prepare fields dictionary
        let fields: [String: Any] = [
            "x": panel.x,
            "y": panel.y,
            "z": panel.z,
            "alpha": panel.alpha,
            "icon": panel.icon,
            "r": panel.r,
            "g": panel.g,
            "b": panel.b
        ]

        // Wrap with docID
        let jsonObject: [String: Any] = [
            "docID": panel.panelID,
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

func deleteCommunityPanelService(museumID: String, roomID: String,id: String, accessToken: String) async -> String {
    do {
        let endpoint = "/api/\(museumID)/\(roomID)/community/\(accessToken)/panel"
        
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


func resetCommunityPanelsService(museumID: String, roomID: String, accessToken: String) async {
    let endpoint = "/api/\(museumID)/\(roomID)/community/\(accessToken)/reset"
    
    do {
        let data = try await APIService.request(endpoint: endpoint, method: .GET)
        
        
    } catch {
        print(error)
    }
}

