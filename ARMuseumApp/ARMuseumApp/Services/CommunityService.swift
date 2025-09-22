//
//  CommunityService.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 17/09/2025.
//

import Foundation


func getCommunitySessionsService(museumID: String) async -> [String] {
    let endpoint = "/api/\(museumID)/community"
    
    do {
        let data = try await APIService.request(endpoint: endpoint, method: .GET)
        
        // Decode JSON array
        let decoded = try JSONDecoder().decode([String].self, from: data)
        return decoded
        
    } catch {
        print(error)
        return []
    }
}

func createSessionService(museumID: String, name: String, password: String) async -> String {
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

