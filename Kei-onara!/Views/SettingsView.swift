import SwiftUI

struct SettingsView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @StateObject private var googleDriveBackupManager = GoogleDriveBackupManager()
    @Environment(\.dismiss) private var dismiss
    @State private var showingVehicleManagement = false
    @State private var showingExpenseExport = false
    @State private var showingBackupAlert = false
    @State private var showingRestoreAlert = false
    @State private var alertMessage = ""
    @State private var isSyncing = false
    @State private var syncProgress: Double = 0.0
    @State private var syncStatus: String = ""
    @State private var showingSiriShortcuts = false
    @State private var showingICloudBackup = false
    
    var body: some View {
        NavigationView {
            Form {
                vehicleManagementSection
                displaySection
                notificationsSection
                voiceAccessibilitySection
                carPlaySection
                backupSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .overlay(
                Group {
                    if googleDriveBackupManager.isBackingUp || googleDriveBackupManager.isRestoring {
                        ZStack {
                            Color.black.opacity(0.3).ignoresSafeArea()
                            VStack(spacing: 16) {
                                ProgressView(googleDriveBackupManager.backupStatus)
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding()
                                Text("Please wait...")
                                    .foregroundColor(.secondary)
                            }
                            .padding(32)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(radius: 10)
                        }
                    }
                }
            )
        }
        .sheet(isPresented: $showingVehicleManagement) {
            VehicleManagementView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingExpenseExport) {
            ExpenseExportView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingSiriShortcuts) {
            SiriShortcutsView()
        }
        .sheet(isPresented: $showingICloudBackup) {
            ICloudBackupView(vehicleManager: vehicleManager)
        }
        .alert("Backup Status", isPresented: $showingBackupAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .alert("Restore Status", isPresented: $showingRestoreAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .preferredColorScheme(vehicleManager.settings.isDarkModeEnabled ? .dark : .light)
    }
    
    // MARK: - Form Sections
    
    private var vehicleManagementSection: some View {
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
    }
    
    private var displaySection: some View {
        Section("Display") {
            Toggle("Dark Mode", isOn: $vehicleManager.settings.isDarkModeEnabled)
            
            Picker("Units", selection: $vehicleManager.useMetricUnits) {
                Text("Metric (km/L)").tag(true)
                Text("Imperial (mi/gal)").tag(false)
            }
            .pickerStyle(.segmented)
            .onChange(of: vehicleManager.useMetricUnits) { oldValue, newValue in
                vehicleManager.syncUnitSetting()
            }
        }
    }
    
    private var notificationsSection: some View {
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
    }
    
    private var voiceAccessibilitySection: some View {
        Section("Voice & Accessibility") {
            Button(action: {
                showingSiriShortcuts = true
            }) {
                HStack {
                    Image(systemName: "mic.circle.fill")
                        .foregroundColor(.blue)
                    Text("Siri Shortcuts")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .foregroundColor(.blue)
            
            Text("Create voice commands like \"Log my gas\" or \"Start my ride\"")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var carPlaySection: some View {
        Section("CarPlay") {
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(.blue)
                Text("CarPlay Integration")
                Spacer()
                Text("Available")
                    .foregroundColor(.green)
            }
            
            Text("Use the app in your car with CarPlay")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var backupSection: some View {
        Section("Data & Backup") {
            Toggle("Auto Backup", isOn: $vehicleManager.settings.autoBackup)
            
            Button(action: {
                showingICloudBackup = true
            }) {
                HStack {
                    Image(systemName: "icloud.fill")
                        .foregroundColor(.blue)
                    Text("iCloud Backup")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .foregroundColor(.blue)
            
            Text("Backup and restore your vehicle data")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Version")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(getAppVersion())
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(vehicleManager.versionManager.getBuildString())
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                Text("Made in Florida by Jason M. Salas 2025")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func createLocalBackup() {
        let backupData = BackupData(
            vehicles: vehicleManager.vehicles,
            driveLogs: vehicleManager.driveLogs,
            fuelEntries: vehicleManager.fuelEntries,
            maintenanceRecords: vehicleManager.maintenanceRecords,
            settings: vehicleManager.settings,
            timestamp: Date()
        )
        
        guard let jsonData = try? JSONEncoder().encode(backupData) else {
            alertMessage = "Failed to create backup data"
            showingBackupAlert = true
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupURL = documentsPath.appendingPathComponent("kei-onara-local-backup-\(Date().formatted(date: .abbreviated, time: .omitted)).json")
        
        do {
            try jsonData.write(to: backupURL)
            alertMessage = "Local backup created successfully at: \(backupURL.lastPathComponent)"
            showingBackupAlert = true
        } catch {
            alertMessage = "Failed to create local backup: \(error.localizedDescription)"
            showingBackupAlert = true
        }
    }
    
    private func restoreFromLocalBackup() {
        // Use the optimized Google Drive restore method for local backup
        googleDriveBackupManager.restoreFromGoogleDrive(vehicleManager: vehicleManager) { error in
            if let error = error {
                alertMessage = "Restore failed: \(error.localizedDescription)"
                showingRestoreAlert = true
            } else {
                alertMessage = "Restore completed successfully!"
                showingRestoreAlert = true
            }
        }
    }
    
    private func exportData() {
        let jsonString = vehicleManager.exportData()
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exportURL = documentsPath.appendingPathComponent("kei-onara-export-\(Date().formatted(date: .abbreviated, time: .omitted)).json")
        
        do {
            try jsonString.write(to: exportURL, atomically: true, encoding: .utf8)
            alertMessage = "Data exported successfully to: \(exportURL.lastPathComponent)"
            showingBackupAlert = true
        } catch {
            alertMessage = "Failed to export data: \(error.localizedDescription)"
            showingBackupAlert = true
        }
    }
    
    private func importData() {
        // Implementation for data import - would need document picker
        alertMessage = "Import functionality coming soon"
        showingBackupAlert = true
    }
    
    private func resetData() {
        vehicleManager.clearAllData()
        alertMessage = "All data has been reset"
        showingBackupAlert = true
    }
    
    private func rateApp() {
        // Implementation for app rating
        print("Rate app")
    }
    
    private func sendFeedback() {
        let email = "jasonmsalas@mac.com"
        let subject = "Kei-onara! Feedback"
        let body = ""
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            #if os(iOS)
            UIApplication.shared.open(url)
            #endif
        }
    }
    
    private func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    SettingsView(vehicleManager: VehicleManager())
} 