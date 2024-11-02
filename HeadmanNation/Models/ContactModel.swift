import SwiftUI

struct Contact: Identifiable {
    var id = UUID()
    var name: String
    var phoneNumber: String
    var photo: Image? // Make this optional
}

