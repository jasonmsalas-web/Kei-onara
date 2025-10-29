import SwiftUI

struct VoiceEntryView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @ObservedObject var speechManager: SpeechManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingSuccessAlert = false
    @State private var successMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: speechManager.isListening ? "mic.fill" : "mic")
                        .font(.system(size: 80))
                        .foregroundColor(speechManager.isListening ? .red : .blue)
                        .scaleEffect(speechManager.isListening ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: speechManager.isListening)
                    
                    Text(speechManager.isListening ? "Listening..." : "Tap to Start Voice Entry")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                
                // Transcribed Text
                if !speechManager.transcribedText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You said:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(speechManager.transcribedText)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                
                // Voice Commands Guide
                VStack(alignment: .leading, spacing: 16) {
                    Text("Voice Commands:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        CommandExample(command: "Log my fuel: 30 liters at 100,000 km", description: "Add fuel entry")
                        CommandExample(command: "Oil change at 50,000 km", description: "Add maintenance record")
                        CommandExample(command: "Start drive", description: "Begin trip tracking")
                        CommandExample(command: "End drive", description: "End trip tracking")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
                
                // Control Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        if speechManager.isListening {
                            speechManager.stopListening()
                        } else {
                            speechManager.startListening()
                        }
                    }) {
                        HStack {
                            Image(systemName: speechManager.isListening ? "stop.fill" : "mic.fill")
                            Text(speechManager.isListening ? "Stop" : "Start")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(speechManager.isListening ? Color.red : Color.blue)
                        .cornerRadius(12)
                    }
                    
                    if !speechManager.transcribedText.isEmpty {
                        Button(action: {
                            processVoiceCommand()
                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Process")
                            }
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Voice Entry")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Done") {
                dismiss()
            })
        }
        .alert("Success!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(successMessage)
        }
        .onReceive(speechManager.$transcribedText) { text in
            // Auto-process when user stops talking
            if !text.isEmpty && !speechManager.isListening {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if !speechManager.isListening {
                        processVoiceCommand()
                    }
                }
            }
        }
    }
    
    private func processVoiceCommand() {
        let success = speechManager.parseVoiceCommand(speechManager.transcribedText, vehicleManager: vehicleManager)
        
        if success {
            successMessage = "Voice command processed successfully!"
            showingSuccessAlert = true
            speechManager.transcribedText = ""
        } else {
            successMessage = "Could not understand command. Please try again."
            showingSuccessAlert = true
        }
    }
}

struct CommandExample: View {
    let command: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(command)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    VoiceEntryView(vehicleManager: VehicleManager(), speechManager: SpeechManager())
} 