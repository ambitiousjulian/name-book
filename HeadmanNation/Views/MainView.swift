import SwiftUI

struct MainView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .black
        appearance.stackedLayoutAppearance.normal.iconColor = .white
        appearance.stackedLayoutAppearance.selected.iconColor = .systemPink
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemPink]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        UITabBar.appearance().tintColor = UIColor.systemPink
    }
    
    var body: some View {
        GeometryReader { geometry in
            TabView {
                // Home Tab
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                
                // Night Out Mode Tab - Opens Camera Directly
                NightOutModeView()
                    .tabItem {
                        Image(systemName: "moon.fill")
                        Text("Night Out")
                    }
            }
            .accentColor(.pink)
            .frame(width: geometry.size.width, height: geometry.size.height) // Adjust to full screen
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView()
                .previewDevice("iPhone 13 Pro")
            MainView()
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        }
    }
}
