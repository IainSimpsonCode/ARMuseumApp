//
//  AuthenticationService.swift
//  ARMuseumApp
//
//  Created by Senan on 16/09/2025.
//

import Foundation

func loginService(museumID: String, curatorID: String, curatorPassword: String) async -> String {
    do {
        let endpoint = "/api/\(museumID)/authenticate"
        
        // Create dictionary directly
        let jsonObject: [String: Any] = ["curatorID": curatorID, "curatorPassword": curatorPassword]
        
        // Convert dictionary to Data
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        
        // Make the API request
        let data = try await APIService.request(endpoint: endpoint, method: .POST, body: jsonObject)
        
        // Convert response Data to String
        if let responseString = String(data: data, encoding: .utf8) {
            print("Logged In successfully: \(responseString)")
            return responseString
        } else {
            return "Request posted successfully but could not decode response."
        }
        
    } catch {
        return "API Error: \(error.localizedDescription)"
    }
}
