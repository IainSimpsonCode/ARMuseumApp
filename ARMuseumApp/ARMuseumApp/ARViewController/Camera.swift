import SwiftUI
import AVFoundation

// UIView subclass to hold AVCaptureVideoPreviewLayer and resize automatically
class CameraPreviewView: UIView {
    let session: AVCaptureSession
    private var previewLayer: AVCaptureVideoPreviewLayer!

    init(session: AVCaptureSession) {
        self.session = session
        super.init(frame: .zero)
        backgroundColor = .black

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}

struct CameraView: UIViewRepresentable {
    private let session = AVCaptureSession()

    func makeUIView(context: Context) -> UIView {
        let view = CameraPreviewView(session: session)
        configureSession()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        if let view = uiView as? CameraPreviewView {
            view.session.stopRunning()
        }
    }

    private func configureSession() {
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            print("⚠️ Cannot access camera")
            return
        }

        session.beginConfiguration()
        session.addInput(input)
        session.commitConfiguration()

        // Start session on main thread
        DispatchQueue.main.async {
            self.session.startRunning()
        }
    }
}
