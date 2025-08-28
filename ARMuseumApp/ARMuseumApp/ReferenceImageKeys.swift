import SwiftUI
import ARKit

private struct ReferenceImagesKey: EnvironmentKey {
    static let defaultValue: Set<ARReferenceImage> = []
}

extension EnvironmentValues {
    var referenceImages: Set<ARReferenceImage> {
        get { self[ReferenceImagesKey.self] }
        set { self[ReferenceImagesKey.self] = newValue }
    }
}
S