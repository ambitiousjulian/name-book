import SwiftUI

struct Contact: Identifiable, Codable {
    var id: UUID  // Make `id` mutable for decoding
    var name: String
    var phoneNumber: String
    var photoData: Data?  // Store photo as Data for Codable compatibility
    var timestamp: Date   // Property to store when the contact was added
    
    var photo: UIImage? {
        get {
            if let data = photoData {
                return UIImage(data: data)
            }
            return nil
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.8)
        }
    }
    
    // Initializer with default `photo` and `timestamp` values if not provided
    init(id: UUID = UUID(), name: String, phoneNumber: String, photo: UIImage? = nil, timestamp: Date = Date()) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.timestamp = timestamp
        // Directly assign to `photoData` to avoid accessing `self` too early
        self.photoData = photo?.jpegData(compressionQuality: 0.8)
    }
}

// UserDefaults helpers
extension UserDefaults {
    private static let contactsKey = "savedContacts"

    func saveContacts(_ contacts: [Contact]) {
        if let encoded = try? JSONEncoder().encode(contacts) {
            self.set(encoded, forKey: UserDefaults.contactsKey)
            print("DEBUG: Contacts saved successfully") // Logging save action
        } else {
            print("ERROR: Failed to encode contacts for saving")
        }
    }

    func loadContacts() -> [Contact]? {
        if let savedData = self.data(forKey: UserDefaults.contactsKey),
           let decoded = try? JSONDecoder().decode([Contact].self, from: savedData) {
            print("DEBUG: Contacts loaded successfully") // Logging load action
            return decoded
        } else {
            print("ERROR: Failed to decode contacts for loading")
        }
        return []
    }
}
