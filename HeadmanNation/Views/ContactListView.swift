import SwiftUI

struct ContactListView: View {
    @State private var contactList: [Contact] = []
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .name
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.85)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.purple.opacity(0.7))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                    
                    Text("Contacts")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(6)
                            .background(Color.purple.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                .padding([.top, .horizontal], 16)
                
                // Search and Sorting bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search Contacts", text: $searchText)
                        .padding(8)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: { sortOption = .name }) {
                            Label("Name", systemImage: sortOption == .name ? "checkmark" : "")
                        }
                        Button(action: { sortOption = .dateAdded }) {
                            Label("Date Added", systemImage: sortOption == .dateAdded ? "checkmark" : "")
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down.circle")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            Text(sortOption == .name ? "Name" : "Date")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                
                // Favorites section
                if !favoriteContacts.isEmpty {
                    Text("Favorites")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(favoriteContacts) { contact in
                                VStack {
                                    Image(uiImage: contact.photo ?? UIImage(systemName: "person.circle")!)
                                        .resizable()
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.pink, lineWidth: 2))
                                    
                                    Text(contact.name)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(15)
                                .shadow(radius: 10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                }
                
                // Contact list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sortedFilteredContacts, id: \.id) { contact in
                            NavigationLink(destination: ContactDetailView(contact: contact, onDelete: {
                                loadContacts()
                            })) {
                                ContactCardView(contact: contact, onFavoriteToggle: { toggleFavorite(contact) })
                                    .padding(.horizontal, 16)
                            }
                            .contextMenu {
                                Button(action: { deleteContact(contact) }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button(action: { /* Call action */ }) {
                                    Label("Call", systemImage: "phone")
                                }
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
            .onAppear(perform: loadContacts)
        }
        .navigationBarHidden(true)
    }
    
    private var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contactList
        } else {
            return contactList.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.phoneNumber.contains(searchText) }
        }
    }

    private var sortedFilteredContacts: [Contact] {
        filteredContacts.sorted {
            switch sortOption {
            case .name:
                return $0.name < $1.name
            case .dateAdded:
                return $0.timestamp > $1.timestamp
            }
        }
    }
    
    private var favoriteContacts: [Contact] {
        contactList.filter { $0.isFavorite }
    }
    
    private func loadContacts() {
        contactList = UserDefaults.standard.loadContacts() ?? []
    }
    
    private func deleteContact(_ contact: Contact) {
        contactList.removeAll { $0.id == contact.id }
        UserDefaults.standard.saveContacts(contactList)
    }
    
    private func toggleFavorite(_ contact: Contact) {
        if let index = contactList.firstIndex(where: { $0.id == contact.id }) {
            contactList[index].isFavorite.toggle()
            UserDefaults.standard.saveContacts(contactList)
        }
    }
}

// Sorting Options Enum
enum SortOption {
    case name, dateAdded
}

struct ContactCardView: View {
    var contact: Contact
    var onFavoriteToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Image(uiImage: contact.photo ?? UIImage(systemName: "person.fill")!)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.pink, lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(contact.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Favorite button
            Button(action: onFavoriteToggle) {
                Image(systemName: contact.isFavorite ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .opacity(contact.isFavorite ? 1.0 : 0.5)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(12)
        .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.purple.opacity(0.5)]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
