//
//  Colours.swift
//  ARMuseumApp
//
//  Created by Senan on 15/09/2025.
//

import Foundation
import UIKit

struct Colors {
    static let red = UIColor.systemRed
    static let green = UIColor.systemGreen
    static let blue = UIColor.systemBlue
    static let orange = UIColor.systemOrange
    static let yellow = UIColor.systemYellow
    static let purple = UIColor.systemPurple
    
    // Optional: dictionary for easy lookup by name
    static let allColors: [String: UIColor] = [
        "red": red,
        "green": green,
        "blue": blue,
        "orange": orange,
        "yellow": yellow,
        "purple": purple
    ]
    
    // Helper: get color by name with fallback
    static func getUIColour(named name: String) -> UIColor {
        return allColors[name.lowercased()] ?? .black
    }
}
