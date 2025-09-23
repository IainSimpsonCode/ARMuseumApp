//
//  CommunityController.swift
//  ARMuseumApp
//
//  Created by Senan on 23/09/2025.
//

import Foundation

func loadAndSetCommunityPanels(accessToken: String, museumID: String) async{
    let rooms = await getRoomsService(museumID: museumID)
    
    for room in rooms {
        let panels = await getPanelsByMuseumAndRoomService(museumID: museumID, roomID: room)
    }
    
}
