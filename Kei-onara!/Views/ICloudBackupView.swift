import SwiftUI

struct ICloudBackupView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @StateObject private var iCloudManager = ICloudBackupManager()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingBackupAlert = false
    @State private var showingRestoreAlert = false
    @State private var showingBackupsList = false
    @State private var alertMessage = ""
    @State private var backups: [ICloudBackup] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background - Pure white with subtle texture
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "icloud.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("ICLOUD BACKUP")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Backup and restore your vehicle data")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        // iCloud Status
                        VStack(spacing: 20) {
                            Text("ICLOUD STATUS")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .tracking(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                                HStack(spacing: 16) {
                                    Image(systemName: iCloudManager.isICloudAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(iCloudManager.isICloudAvailable ? .green : .red)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(iCloudManager.isICloudAvailable ? "iCloud Available" : "iCloud Not Available")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                        
                                        Text(iCloudManager.isICloudAvailable ? "You can backup and restore data" : "Please sign in to iCloud in Settings")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        // Backup Section
                        VStack(spacing: 20) {
                            Text("BACKUP TO ICLOUD")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .tracking(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                                VStack(spacing: 16) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "arrow.up.icloud")
                                            .font(.system(size: 20))
                                            .foregroundColor(.blue)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Backup Data")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.black)
                                            
                                            Text("\(vehicleManager.vehicles.count) vehicles, \(vehicleManager.fuelEntries.count) fuel entries")
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    if iCloudManager.isBackingUp {
                                        VStack(spacing: 8) {
                                            ProgressView(value: iCloudManager.backupProgress)
                                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                            
                                            Text(iCloudManager.backupStatus)
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Button(action: performBackup) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "icloud.and.arrow.up")
                                                .font(.system(size: 16))
                                            Text("BACKUP TO ICLOUD")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(iCloudManager.isICloudAvailable && !iCloudManager.isBackingUp ? Color.blue : Color.gray)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled(!iCloudManager.isICloudAvailable || iCloudManager.isBackingUp)
                                }
                            }
                        }
                        
                        // Restore Section
                        VStack(spacing: 20) {
                            Text("RESTORE FROM ICLOUD")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .tracking(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                                VStack(spacing: 16) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "arrow.down.icloud")
                                            .font(.system(size: 20))
                                            .foregroundColor(.green)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Restore Data")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.black)
                                            
                                            Text("Restore from latest backup")
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    if iCloudManager.isRestoring {
                                        VStack(spacing: 8) {
                                            ProgressView(value: iCloudManager.restoreProgress)
                                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                            
                                            Text(iCloudManager.restoreStatus)
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Button(action: performRestore) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "icloud.and.arrow.down")
                                                .font(.system(size: 16))
                                            Text("RESTORE FROM ICLOUD")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(iCloudManager.isICloudAvailable && !iCloudManager.isRestoring ? Color.green : Color.gray)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled(!iCloudManager.isICloudAvailable || iCloudManager.isRestoring)
                                }
                            }
                        }
                        
                        // View Backups Section
                        VStack(spacing: 20) {
                            Text("VIEW BACKUPS")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .tracking(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: { showingBackupsList = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "list.bullet")
                                        .font(.system(size: 20))
                                        .foregroundColor(.orange)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("View All Backups")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                        
                                        Text("See all available backups")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("DONE") {
                    dismiss()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            }
        }
        .sheet(isPresented: $showingBackupsList) {
            ICloudBackupsListView(iCloudManager: iCloudManager, vehicleManager: vehicleManager)
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
    }
    
    // MARK: - Actions
    
    private func performBackup() {
        self.iCloudManager.backupToICloud(vehicleManager: vehicleManager) { error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = "Backup failed: \(error.localizedDescription)"
                } else {
                    alertMessage = "Backup completed successfully!"
                }
                showingBackupAlert = true
            }
        }
    }
    
    private func performRestore() {
        self.iCloudManager.restoreFromICloud(vehicleManager: vehicleManager) { error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = "Restore failed: \(error.localizedDescription)"
                } else {
                    alertMessage = "Restore completed successfully!"
                }
                showingRestoreAlert = true
            }
        }
    }
}

struct ICloudBackupsListView: View {
    @ObservedObject var iCloudManager: ICloudBackupManager
    @ObservedObject var vehicleManager: VehicleManager
    @Environment(\.dismiss) private var dismiss
    @State private var backups: [ICloudBackup] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading backups...")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.gray)
                    }
                } else if !errorMessage.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                        Text(errorMessage)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(backups) { backup in
                                SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                                    VStack(spacing: 12) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "icloud")
                                                .font(.system(size: 20))
                                                .foregroundColor(.blue)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(backup.deviceName)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.black)
                                                
                                                Text(backup.formattedDate)
                                                    .font(.system(size: 14, weight: .regular))
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Text("v\(backup.version)")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.blue)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(Color.blue.opacity(0.1))
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("iCloud Backups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadBackups()
        }
    }
    
    private func loadBackups() {
        isLoading = true
        errorMessage = ""
        
        let manager = self.iCloudManager
        manager.listBackups { backups, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    self.backups = backups ?? []
                }
            }
        }
    }
}

#Preview {
    ICloudBackupView(vehicleManager: VehicleManager())
} 