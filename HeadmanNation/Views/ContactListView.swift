import SwiftUI

struct ContactListView: View {
    @State private var contactList: [Contact] = []
    @State private var searchText: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                // Search bar for filtering contacts
                TextField("Search Contacts", text: $searchText)
                    .padding(8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    .padding([.leading, .trailing], 16)
                    .foregroundColor(.white)
                
                List {
                    ForEach(filteredContacts, id: \.id) { contact in
                        NavigationLink(destination: ContactDetailView(contact: contact, onDelete: {
                            loadContacts()
                        })) {
                            HStack {
                                Image(uiImage: contact.photo ?? UIImage(systemName: "person.fill")!)
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteContact(contact)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                // Placeholder action for calling contact
                            } label: {
                                Label("Call", systemImage: "phone")
                            }
                            .tint(.green)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .listRowBackground(Color.black.opacity(0.7))
            }
            .onAppear(perform: loadContacts)
        }
        .navigationTitle("Contacts")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contactList
        } else {
            return contactList.filter { $0.name.contains(searchText) || $0.phoneNumber.contains(searchText) }
        }
    }
    
    private func loadContacts() {
        contactList = UserDefaults.standard.loadContacts() ?? []
    }
    
    private func deleteContact(_ contact: Contact) {
        contactList.removeAll { $0.id == contact.id }
        UserDefaults.standard.saveContacts(contactList)
    }
}
