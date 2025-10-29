import SwiftUI

struct SiriShortcutsView: View {
    @ObservedObject var siriManager = SiriShortcutsManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddShortcut = false
    @State private var selectedActivity: NSUserActivity?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Siri Shortcuts")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Create custom voice commands for quick actions")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                .padding(.top, 40)
                
                // Shortcuts List
                ScrollView {
                    VStack(spacing: 20) {
                        // Available Shortcuts
                        VStack(spacing: 16) {
                            Text("Available Shortcuts")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 12) {
                                ShortcutCard(
                                    title: "Log my gas",
                                    subtitle: "Quickly log a fuel entry",
                                    icon: "fuelpump.fill",
                                    color: .green
                                ) {
                                    siriManager.donateLogGasShortcut()
                                }
                                
                                ShortcutCard(
                                    title: "Start my ride",
                                    subtitle: "Begin GPS tracking",
                                    icon: "location.fill",
                                    color: .blue
                                ) {
                                    siriManager.donateStartRideShortcut()
                                }
                                
                                ShortcutCard(
                                    title: "Log maintenance",
                                    subtitle: "Record a maintenance service",
                                    icon: "wrench.and.screwdriver.fill",
                                    color: .orange
                                ) {
                                    siriManager.donateLogMaintenanceShortcut()
                                }
                            }
                        }
                        
                        // Instructions
                        VStack(spacing: 16) {
                            Text("How to Use")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 12) {
                                InstructionRow(
                                    number: "1",
                                    text: "Tap a shortcut above to add it to Siri"
                                )
                                
                                InstructionRow(
                                    number: "2",
                                    text: "Say \"Hey Siri\" followed by the command"
                                )
                                
                                InstructionRow(
                                    number: "3",
                                    text: "The app will open and perform the action"
                                )
                            }
                        }
                        
                        // Add Custom Shortcut Button
                        Button(action: {
                            showingAddShortcut = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                
                                Text("Add Custom Shortcut")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .sheet(isPresented: $showingAddShortcut) {
                            AddCustomShortcutView()
                        }
                        
                        // Quick Setup
                        VStack(spacing: 16) {
                            Text("Quick Setup")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                siriManager.donateAllShortcuts()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                    
                                    Text("Add All Shortcuts")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Supporting Views

struct ShortcutCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(number)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.blue)
                .cornerRadius(14)
            
            Text(text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct AddCustomShortcutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var shortcutTitle = ""
    @State private var invocationPhrase = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = Color.blue
    
    let icons = ["star.fill", "heart.fill", "bolt.fill", "flame.fill", "leaf.fill", "moon.fill", "sun.fill", "cloud.fill"]
    let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow, .gray]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Shortcut Details") {
                    TextField("Shortcut Title", text: $shortcutTitle)
                    TextField("Voice Command", text: $invocationPhrase)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedIcon == icon ? .white : .blue)
                                    .frame(width: 50, height: 50)
                                    .background(selectedIcon == icon ? Color.blue : Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Custom Shortcut")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        // Add custom shortcut logic here
                        dismiss()
                    }
                    .disabled(shortcutTitle.isEmpty || invocationPhrase.isEmpty)
                }
            }
        }
    }
}

 