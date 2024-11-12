import SwiftUI
import Contacts
import ContactsUI

struct ContactDetailView: View {
    var contact: Contact
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteConfirmation = false
    @State private var showCopiedAlert = false // To show a confirmation when the number is copied
    var onDelete: (() -> Void)? // Callback for deletion

    var body: some View {
        ZStack {
            // Enhanced background gradient
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.85)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Contact photo with refined styling
                if let photo = contact.photo {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.pink, lineWidth: 5))
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 4)
                        .padding(.top, 30)
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 5))
                        .foregroundColor(.gray)
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 4)
                        .padding(.top, 30)
                }
                
                // Contact name with custom styling
                Text(contact.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                // Contact phone number with copy functionality
                HStack(spacing: 10) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                    Text(contact.phoneNumber)
                        .font(.title2)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            UIPasteboard.general.string = contact.phoneNumber
                            showCopiedAlert = true
                        }
                        .alert(isPresented: $showCopiedAlert) {
                            Alert(title: Text("Copied!"), message: Text("Phone number copied to clipboard."), dismissButton: .default(Text("OK")))
                        }
                    Image(systemName: "doc.on.doc.fill")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            UIPasteboard.general.string = contact.phoneNumber
                            showCopiedAlert = true
                        }
                }

                // Small, minimalistic Message button
                Button(action: openMessages) {
                    HStack {
                        Image(systemName: "message.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Message")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.9))
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 4)
                }
                .padding(.top, 10)

                Spacer()
                
                // Delete contact button with custom gradient
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("Delete Contact")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.red.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
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
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.1))
                    .blur(radius: 10)
                    .padding(.horizontal, 20)
            )
            .navigationTitle("Contact Details")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
    
    private func confirmDeleteContact() {
        var savedContacts = UserDefaults.standard.loadContacts() ?? []
        
        print("DEBUG: Contacts before deletion:", savedContacts.map { $0.id })
        
        savedContacts.removeAll { $0.id == contact.id }
        
        UserDefaults.standard.saveContacts(savedContacts)
        
        let updatedContacts = UserDefaults.standard.loadContacts() ?? []
        print("DEBUG: Contacts after deletion:", updatedContacts.map { $0.id })
        
        onDelete?()
        presentationMode.wrappedValue.dismiss()
    }

    // Open Messages with the contact's phone number
    private func openMessages() {
        if let url = URL(string: "sms:\(contact.phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
}
