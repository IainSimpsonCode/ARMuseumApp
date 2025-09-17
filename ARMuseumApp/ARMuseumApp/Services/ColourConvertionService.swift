//
//  ColourConversionService.swift
//  ARMuseumApp
//
//  Created by Senan on 10/09/2025.
//

import UIKit

func convertUIColourToRGBA(from color: UIColor) -> (red: Int, green: Int, blue: Int, alpha: Float) {
    let resolvedColor = color.resolvedColor(with: UITraitCollection.current)
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    let success = resolvedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    if !success {
        return (0, 0, 0, 1.0)
    }
    
    return (
        Int(red * 255),
        Int(green * 255),
        Int(blue * 255),
        Float(alpha)  // keep alpha as Float 0–1
    )
}
    
// MARK: - Convert RGBA 0–255 integers + alpha float → UIColor
func convertRGBAToUIColor(r: Int, g: Int, b: Int, a: CGFloat = 1.0) -> UIColor {
    return UIColor(
        red: CGFloat(r) / 255.0,
        green: CGFloat(g) / 255.0,
        blue: CGFloat(b) / 255.0,
        alpha: a // already a float between 0 and 1
    )
}

