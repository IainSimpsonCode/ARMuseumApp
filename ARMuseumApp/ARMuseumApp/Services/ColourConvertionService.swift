//
//  ColourConvertionService.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 10/09/2025.
//

import Foundation
import SwiftUI

func colourToString(_ colour: Color) -> String {
    switch colour {
    case .red: return "red"
    case .green: return "green"
    case .blue: return "blue"
    case .orange: return "orange"
    case .yellow: return "yellow"
    case .purple: return "purple"
    default: return "unknown"
    }
}

// MARK: - Convert String to Colour
func stringToColour(_ string: String) -> Color {
    switch string.lowercased() {
    case "red": return .red
    case "green": return .green
    case "blue": return .blue
    case "orange": return .orange
    case "yellow": return .yellow
    case "purple": return .purple
    default: return .black // fallback colour
    }
}
