import SwiftUI
import PhotosUI

struct CaptureContactView: View {
    @State private var contactName: String = ""
    @State private var phoneNumber: String = ""
    @State private var contactPhoto: UIImage? = nil
    @State private var showImagePicker = false
    @State private var isCamera = false
    @State private var showSuccessMessage = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Add New Contact")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .padding(.top)
                
                ZStack {
                    if let contactPhoto = contactPhoto {
                        Image(uiImage: contactPhoto)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.pink, lineWidth: 5))
                            .shadow(radius: 10)
                    } else {
                        Circle()
                            .fill(Color.pink.opacity(0.5))
                            .frame(width: 150, height: 150)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                            )
                            .shadow(radius: 10)
                    }
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            isCamera = true
                            showImagePicker = true
                        }) {
                            Image(systemName: "camera")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        
                        Button(action: {
                            isCamera = false
                            showImagePicker = true
                        }) {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                    }
                    .padding(.top, 110)
                }
                
                VStack(spacing: 15) {
                    TextField("Enter Name", text: $contactName)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.1)))
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    
                    TextField("Enter Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.1)))
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                }
                
                Button(action: saveContact) {
                    Text("Save Contact")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .shadow(color: Color.pink.opacity(0.7), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(isCamera: isCamera, selectedImage: $contactPhoto)
            }
            
            // Success Message Overlay
            if showSuccessMessage {
                VStack {
                    Text("Contact Saved!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .padding(.top, 100)
                    
                    Button(action: { showSuccessMessage = false }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                }
                .frame(width: 200, height: 150)
                .background(Color.black.opacity(0.85))
                .cornerRadius(15)
                .shadow(radius: 10)
                .transition(.scale)
                .zIndex(1)
            }
        }
    }
    
    private func saveContact() {
        // Ensure there's input data to save
        guard !contactName.isEmpty && !phoneNumber.isEmpty else { return }
        
        let newContact = Contact(name: contactName, phoneNumber: phoneNumber, photo: contactPhoto)
        
        // Load existing contacts from UserDefaults, add new contact, and save back
        var contacts = UserDefaults.standard.loadContacts() ?? []
        contacts.append(newContact)
        UserDefaults.standard.saveContacts(contacts)
        
        withAnimation {
            showSuccessMessage = true
        }
        
        // Dismiss success message after delay, then go back to main screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSuccessMessage = false
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// Image picker for selecting photo from camera or library
struct ImagePicker: UIViewControllerRepresentable {
    var isCamera: Bool
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = isCamera ? .camera : .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
