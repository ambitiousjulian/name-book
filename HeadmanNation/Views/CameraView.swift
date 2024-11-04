import SwiftUI
import AVFoundation

// Main view for Night Out Mode
struct NightOutModeView: View {
    @State private var showContactForm = false
    @State private var capturedImage: UIImage?
    @State private var recentContacts: [Contact] = []

    var body: some View {
        NavigationView {
            VStack {
                if let image = capturedImage, !showContactForm {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .padding()
                } else {
                    FallbackView(recentContacts: recentContacts, onOpenCamera: openCamera, onRefreshContacts: loadRecentContacts)
                }
            }
            .sheet(isPresented: $showContactForm, onDismiss: reopenCamera) {
                SaveContactForm(capturedImage: capturedImage, onDismiss: {
                    loadRecentContacts()
                    reopenCamera()
                })
            }
            .onAppear {
                loadRecentContacts()
                openCamera()
            }
            .navigationTitle("Night Out Mode")
        }
    }

    private func openCamera() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let cameraView = UIHostingController(rootView: CameraView(capturedImage: $capturedImage, onDismiss: saveImage))
            window.rootViewController?.present(cameraView, animated: true)
        }
    }

    private func saveImage() {
        if capturedImage != nil {
            showContactForm = true
        }
    }

    private func loadRecentContacts() {
        let allContacts = UserDefaults.standard.loadContacts() ?? []
        let fiveHoursAgo = Date().addingTimeInterval(-5 * 60 * 60)
        recentContacts = allContacts.filter { $0.timestamp >= fiveHoursAgo }
    }
    
    private func reopenCamera() {
        capturedImage = nil
        openCamera()
    }
}

// Fallback view for displaying recent contacts and opening the camera
struct FallbackView: View {
    var recentContacts: [Contact]
    var onOpenCamera: () -> Void
    var onRefreshContacts: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Night Out Mode")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                
                Button(action: onOpenCamera) {
                    Text("Open Camera")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 40)
                
                Text("Recent Contacts (Last 5 Hours)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                if recentContacts.isEmpty {
                    Text("No recent contacts added.")
                        .foregroundColor(.gray)
                } else {
                    List(recentContacts, id: \.id) { contact in
                        NavigationLink(destination: ContactDetailView(contact: contact, onDelete: {
                            onRefreshContacts()
                        })) {
                            HStack {
                                Image(uiImage: contact.photo ?? UIImage(systemName: "person.circle")!)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.pink, lineWidth: 2))
                                VStack(alignment: .leading) {
                                    Text(contact.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(contact.phoneNumber)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: 250)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .padding(.top, 40)
        }
    }
}

// Camera view with image capture functionality
struct CameraView: View {
    @Binding var capturedImage: UIImage?
    var onDismiss: (() -> Void)?
    
    @Environment(\.presentationMode) var presentationMode
    @State private var isUsingFrontCamera = true

    private var captureSession = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var photoCaptureDelegate = PhotoCaptureDelegate()

    init(capturedImage: Binding<UIImage?>, onDismiss: (() -> Void)?) {
        self._capturedImage = capturedImage
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack {
            CameraPreview(captureSession: captureSession)
                .onAppear {
                    setupCamera()
                }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: flipCamera) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                    }
                    .accessibilityLabel("Flip Camera")
                    
                    Button(action: closeCamera) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                            .padding()
                    }
                    .accessibilityLabel("Close Camera")
                }
                .padding(.top, 50)

                Spacer()
                
                Button(action: capturePhoto) {
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 70, height: 70)
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                }
                .padding(.bottom, 30)
                .accessibilityLabel("Capture Photo")
            }
        }
        .navigationBarHidden(true)
    }
    
    private func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
            configureSession(isUsingFrontCamera: isUsingFrontCamera)
            captureSession.startRunning()
        }
    }
    
    private func configureSession(isUsingFrontCamera: Bool) {
        captureSession.beginConfiguration()
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        
        let devicePosition: AVCaptureDevice.Position = isUsingFrontCamera ? .front : .back
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: devicePosition),
           let input = try? AVCaptureDeviceInput(device: device), captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        captureSession.commitConfiguration()
    }
    
    private func flipCamera() {
        isUsingFrontCamera.toggle()
        configureSession(isUsingFrontCamera: isUsingFrontCamera)
    }
    
    private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.maxPhotoDimensions = .init(width: 1920, height: 1080)  // Adjust as needed

        photoCaptureDelegate.onPhotoCaptured = { image in
            DispatchQueue.main.async {
                if let image = image {
                    self.capturedImage = self.adjustOrientation(for: image)
                    self.onDismiss?()
                }
            }
        }
        output.capturePhoto(with: settings, delegate: photoCaptureDelegate)
    }

    private func adjustOrientation(for image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
    }

    private func closeCamera() {
        presentationMode.wrappedValue.dismiss()
        capturedImage = nil
    }
}

// Preview component for live camera feed
struct CameraPreview: UIViewRepresentable {
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var previewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }

    var captureSession: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = captureSession
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}

// Delegate to handle photo capture
class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    var onPhotoCaptured: ((UIImage?) -> Void)?
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation() {
            onPhotoCaptured?(UIImage(data: data))
        }
    }
}
