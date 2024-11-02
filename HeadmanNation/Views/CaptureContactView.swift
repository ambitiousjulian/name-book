import SwiftUI

struct CaptureContactView: View {
    @State private var contactName: String = ""
    @State private var phoneNumber: String = ""
    @State private var contactPhoto: Image? = nil // Optional photo placeholder
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Add New Contact")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .padding(.top)
                
                // Camera button to capture photo
                Button(action: {
                    // Add code to open camera and capture photo
                }) {
                    ZStack {
                        if let contactPhoto = contactPhoto {
                            contactPhoto
                                .resizable()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.pink, lineWidth: 5))
                        } else {
                            Image(systemName: "camera")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.pink).frame(width: 100, height: 100))
                                .shadow(radius: 10)
                        }
                    }
                }
                
                // Name and phone number input fields
                TextField("Enter Name", text: $contactName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                TextField("Enter Phone Number", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // Save Contact button
                Button(action: {
                    // Code to save contact details
                }) {
                    Text("Save Contact")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .cornerRadius(15)
                        .shadow(color: .pink, radius: 10, x: 0, y: 10)
                }
                .padding(.horizontal)
            }
            .padding(.top, 40)
        }
    }
}
