import SwiftUI

struct SettingsView: View {
    @AppStorage("nightOutModeEnabled") var nightOutModeEnabled: Bool = false
    private let websiteURL = URL(string: "https://www.example.com") // Replace with your actual URL
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .padding(.top, 20)
                
                Form {
                    Section(header: Text("Preferences").foregroundColor(.gray)) {
                        Toggle(isOn: $nightOutModeEnabled) {
                            Text("Enable Night Out Mode")
                                .foregroundColor(.white)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .pink))
                    }
                    
                    Section(header: Text("More Info").foregroundColor(.gray)) {
                        Button(action: openWebsite) {
                            Text("Visit Our Website")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: .purple, radius: 10, x: 0, y: 5)
                        }
                    }
                }
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 10)
            }
        }
    }
    
    private func openWebsite() {
        if let url = websiteURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
