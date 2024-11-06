import SwiftUI
import Combine

// Particle effect model for the animated background
struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat = CGFloat.random(in: 0...1)
    var y: CGFloat = CGFloat.random(in: 0...1)
    var opacity: Double = Double.random(in: 0.5...1)
    var size: CGFloat = CGFloat.random(in: 2...5)
}

// ViewModel to manage particle animation
class ParticleViewModel: ObservableObject {
    @Published var particles = [Particle]()
    private var timer: AnyCancellable?

    init() {
        particles = (0..<20).map { _ in Particle() }
        startAnimation()
    }

    private func startAnimation() {
        timer = Timer.publish(every: 0.7, on: .main, in: .common).autoconnect()
            .sink { _ in
                withAnimation(.easeInOut(duration: 0.7)) {
                    self.particles = self.particles.map { particle in
                        var newParticle = particle
                        newParticle.x = CGFloat.random(in: 0...1)
                        newParticle.y = CGFloat.random(in: 0...1)
                        newParticle.opacity = Double.random(in: 0.4...1)
                        return newParticle
                    }
                }
            }
    }
}

struct HomeView: View {
    @ObservedObject private var particleVM = ParticleViewModel()
    @State private var favorites: [Contact] = []

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ForEach(particleVM.particles) { particle in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: particle.size, height: particle.size)
                        .position(x: UIScreen.main.bounds.width * particle.x,
                                  y: UIScreen.main.bounds.height * particle.y)
                        .opacity(particle.opacity)
                }

                VStack(spacing: 20) {
                    Text("🔥 Hotlist: Night Out Contact Manager 🔥")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing))
                        .shadow(color: .purple.opacity(0.4), radius: 8, x: 0, y: 4)
                        .padding(.top, 25)
                        .padding(.horizontal, 10)
                        .overlay(
                            Text("🔥")
                                .font(.system(size: 40))
                                .offset(x: -150, y: -10),
                            alignment: .leading
                        )
                        .overlay(
                            Text("🔥")
                                .font(.system(size: 40))
                                .offset(x: 150, y: -10),
                            alignment: .trailing
                        )

                        
                    Spacer()
                    // Main Action Buttons
                    VStack(spacing: 20) {
//                        NavigationLink(destination: CaptureContactView()) {
//                            HStack {
//                                Image(systemName: "plus.circle.fill")
//                                    .font(.title2)
//                                    .foregroundColor(.white)
//                                Text("Add New Contact")
//                                    .font(.headline)
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.white)
//                            }
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: .leading, endPoint: .trailing))
//                            .cornerRadius(15)
//                            .shadow(radius: 10)
//                        }
//                        .padding(.horizontal, 40)

                        NavigationLink(destination: ContactListView()) {
                            HStack {
                                Image(systemName: "book.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("View Saved Contacts")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(15)
                            .shadow(radius: 10)
                        }
                        .padding(.horizontal, 40)
                    }

                    Spacer()

                    // Favorites Section
                    if !favorites.isEmpty {
                        Text("Favorites")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom, 5)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(favorites) { contact in
                                    VStack {
                                        Image(uiImage: contact.photo ?? UIImage(systemName: "person.circle")!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.pink, lineWidth: 3))
                                            .shadow(radius: 10)

                                        Text(contact.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .frame(width: 100)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.black.opacity(0.6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.pink.opacity(0.8), lineWidth: 2)
                                            )
                                    )
                                    .shadow(radius: 8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .onAppear {
                loadFavorites()
            }
        }
    }

    private func loadFavorites() {
        favorites = UserDefaults.standard.loadContacts()?.filter { $0.isFavorite } ?? []
    }
}
