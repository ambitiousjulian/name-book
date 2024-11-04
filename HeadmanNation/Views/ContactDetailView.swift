import SwiftUI

struct ContactDetailView: View {
    var contact: Contact
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteConfirmation = false
    var onDelete: (() -> Void)? // Callback for deletion

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                // Display contact photo with an optimized frame
                if let photo = contact.photo {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.pink, lineWidth: 5))
                        .shadow(radius: 8)
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 5))
                        .shadow(radius: 8)
                }
                
                // Contact name
                Text(contact.name)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                // Contact phone number
                Text(contact.phoneNumber)
                    .font(.title2)
                    .foregroundColor(.gray)

                // Delete contact button
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("Delete Contact")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
                .padding(.top, 20)
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Contact"),
                        message: Text("Are you sure you want to delete this contact? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            confirmDeleteContact()
                        },
                        secondaryButton: .cancel()
                    )
                }

                Spacer()
            }
            .padding()
        }
    }
    
    private func confirmDeleteContact() {
        var savedContacts = UserDefaults.standard.loadContacts() ?? []
        
        // Log current state of contacts before deletion
        print("DEBUG: Contacts before deletion:", savedContacts.map { $0.id })
        
        // Remove contact with matching ID
        savedContacts.removeAll { $0.id == contact.id }
        
        // Save updated contacts to UserDefaults
        UserDefaults.standard.saveContacts(savedContacts)
        
        // Confirm deletion in UserDefaults
        let updatedContacts = UserDefaults.standard.loadContacts() ?? []
        print("DEBUG: Contacts after deletion:", updatedContacts.map { $0.id })
        
        // Notify parent view of deletion and close the detail view
        onDelete?()
        presentationMode.wrappedValue.dismiss()
    }
}
