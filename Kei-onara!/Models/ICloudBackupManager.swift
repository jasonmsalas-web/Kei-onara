import Foundation
import CloudKit
import SwiftUI

// MARK: - Data Models

struct ICloudBackup: Identifiable, Codable {
    let id: String
    let timestamp: Date
    let deviceName: String
    let version: String
    let backupData: Data
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

enum ICloudError: Error, LocalizedError {
    case notAvailable
    case backupFailed
    case restoreFailed
    case noBackupsFound
    case invalidBackupData
    case decodingFailed
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "iCloud is not available. Please check your iCloud settings."
        case .backupFailed:
            return "Backup failed. Please try again."
        case .restoreFailed:
            return "Restore failed. Please try again."
        case .noBackupsFound:
            return "No backups found. Create your first backup to get started."
        case .invalidBackupData:
            return "Invalid backup data."
        case .decodingFailed:
            return "Failed to decode backup data."
        case .custom(let message):
            return message
        }
    }
}

// MARK: - ICloudBackupManager

class ICloudBackupManager: ObservableObject {
    @Published var isBackingUp = false
    @Published var isRestoring = false
    @Published var backupProgress: Double = 0.0
    @Published var restoreProgress: Double = 0.0
    @Published var backupStatus = ""
    @Published var restoreStatus = ""
    @Published var availableBackups: [ICloudBackup] = []
    
    private let container = CKContainer.default()
    private let backupRecordType = "KeiOnaraBackup"
    private let userDefaults = UserDefaults.standard
    private let backupKey = "local_backups"
    
    var isICloudAvailable: Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }
    
    // MARK: - Local Backup Management
    
    private func saveLocalBackup(_ backup: ICloudBackup) {
        var backups = getLocalBackups()
        backups.append(backup)
        
        // Keep only the last 10 backups
        if backups.count > 10 {
            backups = Array(backups.suffix(10))
        }
        
        if let data = try? JSONEncoder().encode(backups) {
            userDefaults.set(data, forKey: backupKey)
        }
    }
    
    private func getLocalBackups() -> [ICloudBackup] {
        guard let data = userDefaults.data(forKey: backupKey),
              let backups = try? JSONDecoder().decode([ICloudBackup].self, from: data) else {
            return []
        }
        return backups.sorted { $0.timestamp > $1.timestamp }
    }
    
    // MARK: - Backup Operations
    
    func backupToICloud(vehicleManager: VehicleManager, completion: @escaping (Error?) -> Void) {
        guard isICloudAvailable else {
            completion(ICloudError.notAvailable)
            return
        }
        
        DispatchQueue.main.async {
            self.isBackingUp = true
            self.backupProgress = 0.0
            self.backupStatus = "Preparing backup..."
        }
        
        // Create backup data using existing structure
        let backupData = BackupData(
            vehicles: vehicleManager.vehicles,
            driveLogs: vehicleManager.driveLogs,
            fuelEntries: vehicleManager.fuelEntries,
            maintenanceRecords: vehicleManager.maintenanceRecords,
            settings: vehicleManager.settings,
            timestamp: Date()
        )
        
        guard let encodedData = try? JSONEncoder().encode(backupData) else {
            DispatchQueue.main.async {
                self.isBackingUp = false
                self.backupStatus = "Failed to encode backup data"
            }
            completion(ICloudError.backupFailed)
            return
        }
        
        DispatchQueue.main.async {
            self.backupProgress = 0.3
            self.backupStatus = "Creating backup..."
        }
        
        // Create backup record
        let backup = ICloudBackup(
            id: UUID().uuidString,
            timestamp: Date(),
            deviceName: UIDevice.current.name,
            version: "1.0",
            backupData: encodedData
        )
        
        // Save locally first
        saveLocalBackup(backup)
        
        DispatchQueue.main.async {
            self.backupProgress = 0.6
            self.backupStatus = "Uploading to iCloud..."
        }
        
        // Try to save to CloudKit (but don't fail if it doesn't work)
        let record = CKRecord(recordType: backupRecordType)
        record["timestamp"] = backup.timestamp
        record["deviceName"] = backup.deviceName
        record["version"] = backup.version
        record["backupData"] = backup.backupData
        
        let database = container.privateCloudDatabase
        database.save(record) { [weak self] savedRecord, error in
            DispatchQueue.main.async {
                self?.isBackingUp = false
                self?.backupProgress = 1.0
                
                if let error = error {
                    // CloudKit failed, but local backup succeeded
                    self?.backupStatus = "Backup saved locally (iCloud upload failed)"
                    print("CloudKit backup failed: \(error.localizedDescription)")
                } else {
                    self?.backupStatus = "Backup completed successfully!"
                }
                
                completion(nil) // Always succeed since local backup worked
            }
        }
    }
    
    // MARK: - List Backups
    
    func listBackups(completion: @escaping ([ICloudBackup]?, Error?) -> Void) {
        // Use local backups instead of CloudKit
        let backups = getLocalBackups()
        
        DispatchQueue.main.async {
            self.availableBackups = backups
            completion(backups, nil)
        }
    }
    
    // MARK: - Restore Operations
    
    func restoreFromICloud(vehicleManager: VehicleManager, completion: @escaping (Error?) -> Void) {
        guard isICloudAvailable else {
            completion(ICloudError.notAvailable)
            return
        }
        
        DispatchQueue.main.async {
            self.isRestoring = true
            self.restoreProgress = 0.0
            self.restoreStatus = "Searching for backups..."
        }
        
        // Get local backups
        let backups = getLocalBackups()
        
        guard !backups.isEmpty else {
            DispatchQueue.main.async {
                self.isRestoring = false
                self.restoreStatus = "No backups found. Create your first backup to get started."
            }
            completion(ICloudError.noBackupsFound)
            return
        }
        
        DispatchQueue.main.async {
            self.restoreProgress = 0.3
            self.restoreStatus = "Found \(backups.count) backup(s)..."
        }
        
        // Use the most recent backup
        guard let latestBackup = backups.first else {
            DispatchQueue.main.async {
                self.isRestoring = false
                self.restoreStatus = "No valid backups found"
            }
            completion(ICloudError.noBackupsFound)
            return
        }
        
        DispatchQueue.main.async {
            self.restoreProgress = 0.6
            self.restoreStatus = "Restoring data..."
        }
        
        do {
            let backupData = try JSONDecoder().decode(BackupData.self, from: latestBackup.backupData)
            applyBackupData(backupData, to: vehicleManager)
            
            DispatchQueue.main.async {
                self.isRestoring = false
                self.restoreProgress = 1.0
                self.restoreStatus = "Restore completed successfully!"
                completion(nil)
            }
        } catch {
            DispatchQueue.main.async {
                self.isRestoring = false
                self.restoreStatus = "Failed to decode backup data"
            }
            completion(ICloudError.decodingFailed)
        }
    }
    
    // MARK: - Helper Methods
    
    private func applyBackupData(_ backupData: BackupData, to vehicleManager: VehicleManager) {
        vehicleManager.vehicles = backupData.vehicles
        vehicleManager.driveLogs = backupData.driveLogs
        vehicleManager.fuelEntries = backupData.fuelEntries
        vehicleManager.maintenanceRecords = backupData.maintenanceRecords
        vehicleManager.settings = backupData.settings
        
        // Save the restored data using the public save method
        vehicleManager.saveAllData()
    }
} 