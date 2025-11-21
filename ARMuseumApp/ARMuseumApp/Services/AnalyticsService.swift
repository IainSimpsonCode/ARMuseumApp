//
//  SessionService.swift
//  ARMuseumApp
//
//  Created by Senan on 24/10/2025.
//

import Foundation

func getSessionIDService(museumID: String, roomID: String) async -> String {
    let endpoint = "/api/\(museumID)/\(roomID)/sessionID"
    
    do {
        let data = try await APIService.request(endpoint: endpoint, method: .GET)
        
        let responseString = String(data: data, encoding: .utf8)
        
        return responseString!
        
    } catch {
        print(error)
        return ""
    }
}

func endSessionService(sessionID: String) async{
    let endpoint = "/api/\(sessionID)/endSession"

    do {
        let data = try await APIService.request(endpoint: endpoint, method: .GET)

        
    } catch {
        print(error)
    }
}

func clickedOnPanelService(sessionID: String, panelID: String, expanded: Bool) async {
    let endpoint = "/api/\(sessionID)/\(panelID)/\(expanded)/expandedPanel"

    do {
        let data = try await APIService.request(endpoint: endpoint, method: .GET)

        
    } catch {
        print(error)
    }
}
