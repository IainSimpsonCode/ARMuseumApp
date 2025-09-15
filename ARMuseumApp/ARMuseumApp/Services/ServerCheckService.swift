//
//  APIService.swift
//  ARMuseumApp
//
//  Created by Senan on 04/09/2025.

import Foundation

func healthCheckService() async -> String {
    do {
        let data = try await APIService.request(
            endpoint: "/server/health",
            method: .GET
        )
        
        // Print raw response
        if let responseString = String(data: data, encoding: .utf8) {
            print("Health Check Response: \(responseString)")
        }
        
        // Parse JSON manually without a struct
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["message"] as? String {
            return message
        }
        
        return "Unknown"
        
    } catch {
        print("GET API Error: \(error)")
        return "Error"
    }
}

