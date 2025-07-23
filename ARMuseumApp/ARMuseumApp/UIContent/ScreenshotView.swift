//
//  ScreenshotView.swift
//  ARMuseumApp
//
//  Created by Liam Moseley on 24/09/2024.
//

import SwiftUI

struct ScreenShotView: View {
    @EnvironmentObject var buttonFunctions: ButtonFunctions
    var body: some View {
        VStack {
            if let image = buttonFunctions.captureImage() {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .border(Color.black, width: 3)
                    .padding(20)
            }
        }
        .navigationBarTitle("Screenshot", displayMode: .inline)
        .navigationBarItems(trailing: ShareButton(image: buttonFunctions.captureImage()!))
    }
}

struct ShareButton: View {
    var image: UIImage
    
    var body: some View {
        Button(action: {
            shareImage(image)
        }) {
            Image(systemName: "square.and.arrow.up")
        }
    }
    
    func shareImage(_ image: UIImage) {
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityController, animated: true, completion: nil)
    }
}
