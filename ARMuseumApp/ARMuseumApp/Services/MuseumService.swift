//
//  APIService.swift
//  ARMuseumApp
//
//  Created by Senan on 04/09/2025.

import Foundation

func getMuseumsService() async -> [String] {
    do {
        let data = try await APIService.request(
            endpoint: "/api/museums",
            method: .GET
        )
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Get Museums Response: \(responseString)")
        }
        
        // Parse JSON into array of strings if API returns JSON array of objects
        if let decoded = try? JSONDecoder().decode([String].self, from: data) {
            return decoded
        }
        
        // Fallback placeholder if parsing fails
        return [""]
        
    } catch {
        return []
    }
}

func getRoomsService(museumID: String) async -> [String] {
    do {
        let data = try await APIService.request(
            endpoint: "/api/\(museumID)/rooms",
            method: .GET
        )
        
        // Parse JSON dynamically
        if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            let roomNames = jsonArray.compactMap { $0["name"] as? String }
            return roomNames
        }
        
        // Fallback if the response is already a simple array of strings
        if let stringArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
            return stringArray
        }
        
        return []
    } catch {
        print("Error fetching rooms: \(error.localizedDescription)")
        return []
    }
}

