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
        print("URL:", fullURL)
        if let body = body {
            print("Body:", body)
        }
        
        guard let url = URL(string: fullURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body, method == .POST || method == .PATCH || method == .DELETE {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    return data
                } else {
                    if let responseBody = String(data: data, encoding: .utf8) {
                        print("Server error. Status code:", httpResponse.statusCode)
                        print("Response body:", responseBody)
                    } else {
                        print("Server error. Status code:", httpResponse.statusCode)
                    }
                    throw URLError(.badServerResponse)
                }
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            throw error
        }
    }
}
