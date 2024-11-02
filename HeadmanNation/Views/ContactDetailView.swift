import SwiftUI

struct ContactDetailView: View {
    var contact: Contact
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                // Conditional photo display
                if let photo = contact.photo {
                    photo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.pink, lineWidth: 5))
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 5))
                }
                
                Text(contact.name)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                
                Text(contact.phoneNumber)
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding()
        }
    }
}
