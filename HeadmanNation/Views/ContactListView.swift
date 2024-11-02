import SwiftUI

struct ContactListView: View {
    @State private var contactList: [Contact] = [
        Contact(name: "Samantha", phoneNumber: "555-1234", photo: Image(systemName: "person.fill")),
        Contact(name: "Jessica", phoneNumber: "555-5678", photo: Image(systemName: "person.fill"))
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            List(contactList) { contact in
                NavigationLink(destination: ContactDetailView(contact: contact)) {
                    HStack {
                        contact.photo?
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.pink, lineWidth: 3))
                        
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
                .listRowBackground(Color.black.opacity(0.7))
            }
            .navigationTitle("Contacts")
            .scrollContentBackground(.hidden)
        }
    }
}
