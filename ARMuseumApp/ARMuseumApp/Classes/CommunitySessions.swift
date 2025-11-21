//
//  CommunitySessions.swift
//  ARMuseumApp
//
//  Created by Senan on 29/09/2025.
//

import Foundation

struct session: Decodable, Hashable{
    let sessionID: String
    let isPrivate: Bool
}
