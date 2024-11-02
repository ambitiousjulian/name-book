import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Dark gradient background to create a club vibe
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("Night Out Contact Manager")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.pink)
                        .padding(.top, 20)
                    
                    // Capture New Contact button
                    NavigationLink(destination: CaptureContactView()) {
                        Text("Add New Contact")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(15)
                            .shadow(color: .pink, radius: 10, x: 0, y: 10)
                    }
                    
                    // View Saved Contacts button
                    NavigationLink(destination: ContactListView()) {
                        Text("View Saved Contacts")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(15)
                            .shadow(color: .blue, radius: 10, x: 0, y: 10)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
