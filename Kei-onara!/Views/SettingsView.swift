import SwiftUI

struct SettingsView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingVehicleManagement = false
    @State private var showingExpenseExport = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Vehicle Management") {
                    Button("Manage Vehicles") {
                        showingVehicleManagement = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("Export Expenses") {
                        showingExpenseExport = true
                    }
                    .foregroundColor(.blue)
                    
                    if let currentVehicle = vehicleManager.currentVehicle {
                        HStack {
                            Text("Current Vehicle")
                            Spacer()
                            Text(currentVehicle.displayName)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Display") {
                    Toggle("Grandma Mode", isOn: $vehicleManager.settings.grandmaMode)
                    
                    Toggle("Dark Mode", isOn: $vehicleManager.settings.darkMode)
                    
                    Picker("Units", selection: $vehicleManager.settings.useMetric) {
                        Text("Metric (km/L)").tag(true)
                        Text("Imperial (mi/gal)").tag(false)
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Button Color Palette", selection: $vehicleManager.settings.buttonPalette) {
                        ForEach(ButtonColorPalette.allCases) { palette in
                            Text(palette.rawValue).tag(palette)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $vehicleManager.settings.enableNotifications)
                    
                    if vehicleManager.settings.enableNotifications {
                        Text("You'll get reminders for:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Oil change due")
                            Text("• Tire rotation needed")
                            Text("• Maintenance alerts")
                            Text("• Mileage goals")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                
                Section("Voice & Accessibility") {
                    Toggle("Voice Entry", isOn: $vehicleManager.settings.voiceEntryEnabled)
                    
                    if vehicleManager.settings.voiceEntryEnabled {
                        Text("Say \"Hey app, log my fuel: 30 liters at 100,000 km\"")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Goals & Tracking") {
                    HStack {
                        Text("Mileage Goal")
                        Spacer()
                        TextField("0", value: $vehicleManager.settings.mileageGoal, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    Picker("Goal Period", selection: $vehicleManager.settings.goalPeriod) {
                        ForEach(GoalPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Data & Backup") {
                    Toggle("Auto Backup", isOn: $vehicleManager.settings.autoBackup)
                    
                    Button("Export Data") {
                        exportData()
                    }
                    
                    Button("Import Data") {
                        importData()
                    }
                    
                    Button("Reset All Data") {
                        resetData()
                    }
                    .foregroundColor(.red)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Rate App") {
                        rateApp()
                    }
                    
                    Button("Send Feedback") {
                        sendFeedback()
                    }
                    
                    Text("Designed & Developed in Florida by Jason M. Salas")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingVehicleManagement) {
            VehicleManagementView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingExpenseExport) {
            ExpenseExportView(vehicleManager: vehicleManager)
        }
        .preferredColorScheme(vehicleManager.settings.darkMode ? .dark : .light)
    }
    
    private func exportData() {
        // Implementation for data export
        print("Export data")
    }
    
    private func importData() {
        // Implementation for data import
        print("Import data")
    }
    
    private func resetData() {
        // Implementation for data reset
        print("Reset data")
    }
    
    private func rateApp() {
        // Implementation for app rating
        print("Rate app")
    }
    
    private func sendFeedback() {
        // Implementation for feedback
        print("Send feedback")
    }
}

#Preview {
    SettingsView(vehicleManager: VehicleManager())
} 