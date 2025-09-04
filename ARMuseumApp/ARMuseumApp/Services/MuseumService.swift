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
        // Example JSON: ["Museum 1", "Museum 2", "Museum 3"]
        if let decoded = try? JSONDecoder().decode([String].self, from: data) {
            return decoded
        }
        
        // Fallback placeholder if parsing fails
        return [""]
        
    } catch {
        print("GET API Error: \(error)")
        return []
    }
}
