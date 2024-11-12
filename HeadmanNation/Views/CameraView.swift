import SwiftUI
import AVFoundation

// Main view for Night Out Mode
struct NightOutModeView: View {
    @State private var showContactForm = false
    @State private var capturedImage: UIImage?
    @State private var recentContacts: [Contact] = []

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.85)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    if let image = capturedImage, !showContactForm {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.pink, lineWidth: 5))
                            .shadow(radius: 10)
                            .padding()
                    } else {
                        FallbackView(recentContacts: recentContacts, onOpenCamera: openCamera, onRefreshContacts: loadRecentContacts)
                    }
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
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures single-column layout on iPad
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
            
            VStack(spacing: 25) {
                Text("Night Out Mode")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                
                Button(action: onOpenCamera) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Open Camera")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.pink.opacity(0.6), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 40)
                
                Text("Recent Contacts")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                if recentContacts.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.bottom, 10)
                        
                        Text("No recent contacts? Seriously?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 5)
                        
                        Text("Get out there, make some memories, and add a few new faces here! 🕶️")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(recentContacts, id: \.id) { contact in
                                ContactRow(contact: contact)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 5)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    .shadow(radius: 8)
                }
                
                Spacer()
            }
            .padding(.top, 40)
        }
    }
}

// Enhanced contact row view, non-clickable and without star icon
struct ContactRow: View {
    var contact: Contact
    
    var body: some View {
        HStack {
            Image(uiImage: contact.photo ?? UIImage(systemName: "person.circle")!)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.pink, lineWidth: 2))
                .shadow(radius: 5)
            
            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(contact.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.purple.opacity(0.6)]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(15)
        .shadow(radius: 8)
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
                    self.capturedImage = self.applyFrontCameraMirrorIfNeeded(image)
                    self.onDismiss?()
                }
            }
        }
        output.capturePhoto(with: settings, delegate: photoCaptureDelegate)
    }

    private func applyFrontCameraMirrorIfNeeded(_ image: UIImage) -> UIImage {
        guard isUsingFrontCamera, let cgImage = image.cgImage else { return image }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: .leftMirrored)
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
