//
//  PanelsDetails.swift
//  ARMuseumApp
//
//  Created by Senan on 04/09/2025.
//

import Foundation
import SwiftUI

struct Panel: Codable {
    var panelID: String
    var museumID: String
    var roomID: String
    var x: Float
    var y: Float
    var z: Float
    var text: String
    var icon: String
    var r: Int
    var g: Int
    var b: Int
    var alpha: Float
    var detailedText: String?
}

struct PanelDetails: Identifiable, Codable{
    var id: UUID? = UUID()
    var panelID: String
    var title: String
    var text: String
}

struct Exhibits: Identifiable, Codable {
    var id = UUID()
    let title: String
    let textOptions: [TextAndID]
}

struct TextAndID: Identifiable, Codable, Hashable {
    let text: String
    let panelID: String

    var id: String { panelID } 
}


