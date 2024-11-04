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
                // Update only positions and opacity for efficiency
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

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                // Particle overlay for shimmer effect
                ForEach(particleVM.particles) { particle in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: particle.size, height: particle.size)
                        .position(x: UIScreen.main.bounds.width * particle.x,
                                  y: UIScreen.main.bounds.height * particle.y)
                        .opacity(particle.opacity)
                }

                VStack(spacing: 30) {
                    // Title with custom font
                    Text("Night Out Contact Manager")
                        .font(.custom("Avenir-Heavy", size: 28))
                        .foregroundColor(.pink)
                        .padding(.top, 20)

                    // Button to add a new contact with an icon
                    NavigationLink(destination: CaptureContactView()) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("Add New Contact")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                    }
                    .padding(.horizontal, 40)

                    // Button to view saved contacts with an icon
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

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Home", displayMode: .inline)
        }
    }
}
