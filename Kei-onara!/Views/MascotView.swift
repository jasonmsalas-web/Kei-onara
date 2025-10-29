import SwiftUI

struct MascotView: View {
    @State private var isAnimating = false
    @State private var showingMessage = false
    @State private var currentMessage = ""
    @State private var messageType: MessageType = .greeting
    
    enum MessageType {
        case greeting, encouragement, reminder, achievement, maintenance
        
        var messages: [String] {
            switch self {
            case .greeting:
                return [
                    "Hello! Ready to track your Kei adventures? 🚛",
                    "Welcome back! How's your truck doing today? 🚛",
                    "Hey there! Time to log some miles? 🚛"
                ]
            case .encouragement:
                return [
                    "Great driving! You're doing awesome! 🌟",
                    "Keep up the excellent fuel efficiency! ⛽",
                    "Your maintenance is on point! 👏",
                    "You're a responsible Kei owner! 🎉"
                ]
            case .reminder:
                return [
                    "Don't forget to log your fuel! ⛽",
                    "Time for a maintenance check? 🔧",
                    "Remember to update your odometer! 📊"
                ]
            case .achievement:
                return [
                    "Congratulations! You've reached a milestone! 🏆",
                    "Amazing! You've saved money on fuel! 💰",
                    "Excellent! Your truck is running perfectly! 🚛✨"
                ]
            case .maintenance:
                return [
                    "Your oil change is coming up! 🛢️",
                    "Tire rotation time soon! 🛞",
                    "Don't forget the brake check! 🛑"
                ]
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Kei Truck Mascot
            ZStack {
                // Truck body
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue)
                    .frame(width: 120, height: 80)
                    .offset(y: isAnimating ? -5 : 0)
                
                // Truck bed
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 100, height: 60)
                    .offset(x: 20, y: -10)
                
                // Wheels
                Circle()
                    .fill(Color.black)
                    .frame(width: 20, height: 20)
                    .offset(x: -30, y: 25)
                
                Circle()
                    .fill(Color.black)
                    .frame(width: 20, height: 20)
                    .offset(x: 30, y: 25)
                
                // Headlights
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 8, height: 8)
                    .offset(x: -45, y: -15)
                
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 8, height: 8)
                    .offset(x: -45, y: 5)
                
                // Windows
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cyan.opacity(0.6))
                    .frame(width: 30, height: 20)
                    .offset(x: -20, y: -15)
                
                // Exhaust (animated)
                Circle()
                    .fill(Color.gray)
                    .frame(width: 6, height: 6)
                    .offset(x: 50, y: 10)
                    .opacity(isAnimating ? 0.3 : 0.8)
                    .scaleEffect(isAnimating ? 1.5 : 1.0)
            }
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            
            // Message bubble
            if showingMessage {
                VStack(spacing: 8) {
                    Text(currentMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 4)
                    
                    // Message tail
                    Triangle()
                        .fill(Color(.systemBackground))
                        .frame(width: 20, height: 10)
                        .offset(y: -5)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Action buttons
            HStack(spacing: 16) {
                Button("Greet") {
                    showMessage(.greeting)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Encourage") {
                    showMessage(.encouragement)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Remind") {
                    showMessage(.reminder)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            isAnimating = true
            showMessage(.greeting)
        }
    }
    
    private func showMessage(_ type: MessageType) {
        messageType = type
        currentMessage = type.messages.randomElement() ?? "Hello! 🚛"
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showingMessage = true
        }
        
        // Hide message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingMessage = false
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct MascotWidget: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Mini Kei truck
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
                    .frame(width: 60, height: 40)
                    .offset(y: isAnimating ? -2 : 0)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 50, height: 30)
                    .offset(x: 10, y: -5)
                
                Circle()
                    .fill(Color.black)
                    .frame(width: 12, height: 12)
                    .offset(x: -15, y: 15)
                
                Circle()
                    .fill(Color.black)
                    .frame(width: 12, height: 12)
                    .offset(x: 15, y: 15)
                
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 4, height: 4)
                    .offset(x: -22, y: -8)
            }
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            
            Text("🚛")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var backgroundOpacity: Double = 0.0
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some View {
        if isActive {
            // Show Steve Jobs UI as default
            SteveJobsUIView(vehicleManager: appDelegate.vehicleManager)
        } else {
            ZStack {
                // Steve Jobs style background - Pure white with subtle gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color.gray.opacity(0.02),
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .opacity(backgroundOpacity)
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // App Icon with Steve Jobs style
                    ZStack {
                        // Icon background with glass effect
                        RoundedRectangle(cornerRadius: 32)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.95),
                                        Color.gray.opacity(0.05),
                                        Color.white.opacity(0.9)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.gray.opacity(0.2),
                                                Color.gray.opacity(0.1)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
                        
                        // App Icon
                        Image(systemName: "car.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .foregroundColor(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    // App Name with Steve Jobs typography
                    VStack(spacing: 12) {
                        Text("KEI-ONARA!")
                            .font(.system(size: 36, weight: .thin))
                            .foregroundColor(.black)
                            .tracking(4)
                        
                        Text("Vehicle Management")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.gray)
                            .tracking(2)
                    }
                    .opacity(textOpacity)
                    
                    Spacer()
                    
                    // Loading indicator with Steve Jobs style
                    VStack(spacing: 16) {
                        // Minimal loading dots
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 8, height: 8)
                                    .opacity(0.3)
                                    .scaleEffect(1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 0.6)
                                            .repeatForever()
                                            .delay(Double(index) * 0.2),
                                        value: isActive
                                    )
                            }
                        }
                        
                        Text("Loading...")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.gray)
                            .tracking(1)
                    }
                    .opacity(textOpacity)
                    .padding(.bottom, 60)
                }
                .padding(.horizontal, 40)
            }
            .onAppear {
                // Animate elements in sequence
                withAnimation(.easeOut(duration: 0.8)) {
                    backgroundOpacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        logoScale = 1.0
                        logoOpacity = 1.0
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeOut(duration: 0.6)) {
                        textOpacity = 1.0
                    }
                }
                
                // Transition to main app after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        isActive = true
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .showFuelEntry)) { _ in
                // Handle Siri shortcut for fuel entry
                print("Siri shortcut: Show fuel entry")
                // This will be handled by the main app flow
            }
            .onReceive(NotificationCenter.default.publisher(for: .showSpeedometer)) { _ in
                // Handle Siri shortcut for start ride
                print("Siri shortcut: Start ride")
                // This will be handled by the main app flow
            }
            .onReceive(NotificationCenter.default.publisher(for: .showMaintenance)) { _ in
                // Handle Siri shortcut for maintenance
                print("Siri shortcut: Show maintenance")
                // This will be handled by the main app flow
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        MascotView()
        MascotWidget()
    }
    .padding()
} 