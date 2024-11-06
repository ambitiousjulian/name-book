import SwiftUI

struct Contact: Identifiable, Codable {
    var id: UUID
    var name: String
    var phoneNumber: String
    var photoData: Data?
    var timestamp: Date
    var isFavorite: Bool = false  // Added favorite property
    
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
    
    init(id: UUID = UUID(), name: String, phoneNumber: String, photo: UIImage? = nil, timestamp: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.timestamp = timestamp
        self.isFavorite = isFavorite
        self.photoData = photo?.jpegData(compressionQuality: 0.8)
    }
}

// UserDefaults helpers
extension UserDefaults {
    private static let contactsKey = "savedContacts"

    func saveContacts(_ contacts: [Contact]) {
        if let encoded = try? JSONEncoder().encode(contacts) {
            self.set(encoded, forKey: UserDefaults.contactsKey)
        }
    }

    func loadContacts() -> [Contact]? {
        if let savedData = self.data(forKey: UserDefaults.contactsKey),
           let decoded = try? JSONDecoder().decode([Contact].self, from: savedData) {
            return decoded
        }
        return []
    }
}
