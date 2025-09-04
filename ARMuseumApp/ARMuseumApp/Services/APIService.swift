//
//  APIService.swift
//  ARMuseumApp
//
//  Created by Senan on 04/09/2025.
//

import Foundation

enum HTTPMethod: String {
    case GET, POST, PATCH, DELETE
}

struct APIService {
    
    private static let baseURL = "https://armuseumapp.onrender.com"
    
    static func request(
        endpoint: String,
        method: HTTPMethod,
        body: [String: Any]? = nil
    ) async throws -> Data {
        
        let fullURL = baseURL + endpoint
        
        // Validate URL
        guard let url = URL(string: fullURL) else {
            throw URLError(.badURL)
        }
        
        // Configure request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add body for POST, PATCH if available
        if let body = body, method == .POST || method == .PATCH {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        // Execute request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check status code
        if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
            return data
        } else {
            throw URLError(.badServerResponse)
        }
    }
}


