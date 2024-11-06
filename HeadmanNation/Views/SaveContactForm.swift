import SwiftUI

struct SaveContactForm: View {
    @State private var contactName: String = ""
    @State private var phoneNumber: String = ""
    @State private var showSuccessMessage = false
    @Environment(\.presentationMode) var presentationMode
    var capturedImage: UIImage?
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.8), Color.purple.opacity(0.85)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 25) {
                // Profile Image or Placeholder
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.pink, lineWidth: 5))
                        .shadow(radius: 10)
                        .padding(.top, 20)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }

                // Contact Form Fields
                VStack(spacing: 16) {
                    TextField("Name", text: $contactName)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.1)))
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.1)))
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
                }
                .padding(.horizontal, 24)

                // Save Contact Button
                Button(action: saveContact) {
                    Text("Save Contact")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .padding()

            // Success Message Overlay
            if showSuccessMessage {
                VStack {
                    Text("Contact Saved!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(12)
                        .shadow(radius: 8)
                    
                    Button(action: { showSuccessMessage = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 22))
                            .padding(.top, 10)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.85))
                .cornerRadius(15)
                .shadow(radius: 10)
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }

    private func saveContact() {
        print("DEBUG: Saving contact with name: \(contactName), phone: \(phoneNumber)")
        let contact = Contact(name: contactName, phoneNumber: phoneNumber, photo: capturedImage)
        
        if var savedContacts = UserDefaults.standard.loadContacts() {
            savedContacts.append(contact)
            UserDefaults.standard.saveContacts(savedContacts)
            print("DEBUG: Contact saved successfully in UserDefaults")
        } else {
            UserDefaults.standard.saveContacts([contact])
            print("DEBUG: First contact saved in UserDefaults")
        }
        
        withAnimation {
            showSuccessMessage = true
        }

        // Automatically dismiss the form after a brief delay for smooth UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            presentationMode.wrappedValue.dismiss()
            onDismiss()
        }
    }
}
