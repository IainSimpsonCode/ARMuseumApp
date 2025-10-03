//
//  DrawingService.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 26/09/2025.
//

import Foundation

func getDrawingNodeService(museumID: String, roomID: String, accessToken : String) async -> [DrawingPoint] {
    let endpoint = "/api/\(museumID)/\(roomID)/community/\(accessToken)/drawing"
    
    do {
        let data = try await APIService.request(endpoint: endpoint, method: .GET)
        
        let decoded = try JSONDecoder().decode([DrawingPoint].self, from: data)
        return decoded
        
    } catch {
        print(error)
        return []
    }
}

func saveDrawingNodeService(drawingPoint: DrawingPoint, museumID: String, roomID: String, accessToken : String) async -> String {
    do {
        let endpoint = "/api/\(museumID)/\(roomID)/community/\(accessToken)/drawing"
        
        let jsonData = try JSONEncoder().encode(drawingPoint)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        
        let data = try await APIService.request(endpoint: endpoint, method: .POST, body: jsonObject)
        
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

func deleteDrawingNodeService(museumID: String, roomID: String, id: String, accessToken : String) async -> String {
    do {
        let endpoint = "/api/\(museumID)/\(roomID)/community/\(accessToken)/drawing/\(id)"
        
        let data = try await APIService.request(endpoint: endpoint, method: .DELETE)
        
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
