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
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.purple.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                if let image = capturedImage {
                    // Full-frame image view, styled nicely
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.pink, lineWidth: 5))
                        .shadow(radius: 10)
                        .padding(.top)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.gray)
                        .padding(.top)
                }

                Form {
                    Section(header: Text("Contact Information").foregroundColor(.white).font(.headline)) {
                        TextField("Name", text: $contactName)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.1)))
                            .foregroundColor(.white)
                        
                        TextField("Phone Number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.1)))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: saveContact) {
                        Text("Save Contact")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 10)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal)
            }
            .padding()
            
            if showSuccessMessage {
                VStack {
                    Text("Contact Saved Successfully!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                    
                    Button(action: { showSuccessMessage = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding(.top, 10)
                    }
                }
                .frame(width: 250, height: 120)
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            presentationMode.wrappedValue.dismiss()
            onDismiss()
        }
    }
}
