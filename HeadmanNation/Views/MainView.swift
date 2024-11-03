import SwiftUI

struct MainView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.stackedLayoutAppearance.normal.iconColor = .white
        appearance.stackedLayoutAppearance.selected.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.gray]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        UITabBar.appearance().tintColor = UIColor.white
    }
    
    var body: some View {
        TabView {
            NavigationView {
                ZStack {
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
                .navigationBarTitle("Home", displayMode: .inline)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            // Settings tab
           NavigationView {
               SettingsView()
                   .navigationBarTitle("Settings", displayMode: .inline)
           }
           .tabItem {
               Label("Settings", systemImage: "gearshape.fill")
           }
        }
        .accentColor(.white) // Customize tab color
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
