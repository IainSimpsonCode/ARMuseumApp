//
//  PreviewARPanel.swift
//  ARMuseumApp
//
//  Created by Imaginarium UCLan on 10/09/2025.
//

import Foundation
import SwiftUI

struct PreviewARPanel: View {
    let text: String
    let borderColor: Color
    let icon: String

    var body: some View {
        ZStack {
            // Transparent background with colored border
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 2)
                .background(Color.clear)
            
            HStack(spacing: 8) {
                // Icon
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .padding(.leading, 8)
                
                // Panel text
                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 8)
            }
            .padding(.vertical, 8)
        }
        .frame(width: 260, height: 100)
        .shadow(radius: 2)
    }
}
