//
//  SessionDetails.swift
//  ARMuseumApp
//
//  Created by Senan on 03/09/2025.
//

import Foundation

struct SessionDetails{
    var museumID: String
    var roomID: String
    var communitySessionID: Int
    var isSessionActive: Bool
    var panelCreationMode: Bool
    var selectedExhibit: Exhibits?
}
