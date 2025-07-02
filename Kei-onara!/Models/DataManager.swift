import Foundation

class DataManager {
    static let shared = DataManager()
    
    private let vehiclesFile = "vehicles.json"
    private let driveLogsFile = "driveLogs.json"
    private let fuelEntriesFile = "fuelEntries.json"
    private let maintenanceRecordsFile = "maintenanceRecords.json"
    private let settingsFile = "settings.json"
    
    private init() {
        print("🚀 DataManager initialized")
        #if targetEnvironment(simulator)
        print("📱 Running in iOS Simulator")
        #else
        print("📱 Running on physical device")
        #endif
    }
    
    private func fileURL(for fileName: String) -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls[0].appendingPathComponent(fileName)
        print("📂 File path for \(fileName): \(url.path)")
        return url
    }
    
    // MARK: - Vehicles
    func saveVehicles(_ vehicles: [Vehicle]) {
        let url = fileURL(for: vehiclesFile)
        do {
            let data = try JSONEncoder().encode(vehicles)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            print("✅ Saved \(vehicles.count) vehicles to \(url.path)")
        } catch {
            print("❌ Error saving vehicles: \(error)")
        }
    }
    
    func loadVehicles() -> [Vehicle] {
        let url = fileURL(for: vehiclesFile)
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([Vehicle].self, from: data)) ?? []
    }
    
    // MARK: - Drive Logs
    func saveDriveLogs(_ driveLogs: [DriveLog]) {
        let url = fileURL(for: driveLogsFile)
        do {
            let data = try JSONEncoder().encode(driveLogs)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            print("✅ Saved \(driveLogs.count) drive logs to \(url.path)")
        } catch {
            print("❌ Error saving drive logs: \(error)")
        }
    }
    
    func loadDriveLogs() -> [DriveLog] {
        let url = fileURL(for: driveLogsFile)
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([DriveLog].self, from: data)) ?? []
    }
    
    // MARK: - Fuel Entries
    func saveFuelEntries(_ fuelEntries: [FuelEntry]) {
        let url = fileURL(for: fuelEntriesFile)
        do {
            let data = try JSONEncoder().encode(fuelEntries)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            
            print("✅ Saved \(fuelEntries.count) fuel entries to \(url.path)")
            
            // Verify the file was actually written
            if FileManager.default.fileExists(atPath: url.path) {
                let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 ?? 0
                print("📊 File size: \(fileSize) bytes")
            } else {
                print("⚠️ File does not exist after saving!")
            }
        } catch {
            print("❌ Error saving fuel entries: \(error)")
        }
    }
    
    func loadFuelEntries() -> [FuelEntry] {
        let url = fileURL(for: fuelEntriesFile)
        guard let data = try? Data(contentsOf: url) else { 
            print("📁 No fuel entries file found at \(url.path)")
            return [] 
        }
        let entries = (try? JSONDecoder().decode([FuelEntry].self, from: data)) ?? []
        print("📖 Loaded \(entries.count) fuel entries from \(url.path)")
        return entries
    }
    
    // MARK: - Maintenance Records
    func saveMaintenanceRecords(_ maintenanceRecords: [MaintenanceRecord]) {
        let url = fileURL(for: maintenanceRecordsFile)
        do {
            let data = try JSONEncoder().encode(maintenanceRecords)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            
            print("✅ Saved \(maintenanceRecords.count) maintenance records to \(url.path)")
            
            // Verify the file was actually written
            if FileManager.default.fileExists(atPath: url.path) {
                let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 ?? 0
                print("📊 File size: \(fileSize) bytes")
            } else {
                print("⚠️ File does not exist after saving!")
            }
        } catch {
            print("❌ Error saving maintenance records: \(error)")
        }
    }
    
    func loadMaintenanceRecords() -> [MaintenanceRecord] {
        let url = fileURL(for: maintenanceRecordsFile)
        guard let data = try? Data(contentsOf: url) else { 
            print("📁 No maintenance records file found at \(url.path)")
            return [] 
        }
        let records = (try? JSONDecoder().decode([MaintenanceRecord].self, from: data)) ?? []
        print("📖 Loaded \(records.count) maintenance records from \(url.path)")
        return records
    }
    
    // MARK: - Settings
    func saveSettings(_ settings: AppSettings) {
        let url = fileURL(for: settingsFile)
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            print("✅ Saved settings to \(url.path)")
        } catch {
            print("❌ Error saving settings: \(error)")
        }
    }
    
    func loadSettings() -> AppSettings {
        let url = fileURL(for: settingsFile)
        guard let data = try? Data(contentsOf: url) else { 
            print("📁 No settings file found, using defaults")
            return AppSettings() 
        }
        let settings = (try? JSONDecoder().decode(AppSettings.self, from: data)) ?? AppSettings()
        print("📖 Loaded settings - useMetric: \(settings.useMetric)")
        return settings
    }
    
    // MARK: - Clear All Data
    func clearAllData() {
        let files = [vehiclesFile, driveLogsFile, fuelEntriesFile, maintenanceRecordsFile, settingsFile]
        for file in files {
            let url = fileURL(for: file)
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    // MARK: - Export Data
    func exportData() -> String {
        let exportData = ExportData(
            vehicles: loadVehicles(),
            driveLogs: loadDriveLogs(),
            fuelEntries: loadFuelEntries(),
            maintenanceRecords: loadMaintenanceRecords(),
            settings: loadSettings(),
            exportDate: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(exportData) {
            return String(data: encoded, encoding: .utf8) ?? ""
        }
        
        return ""
    }
    
    // MARK: - Import Data
    func importData(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8),
              let exportData = try? JSONDecoder().decode(ExportData.self, from: data) else {
            return false
        }
        
        saveVehicles(exportData.vehicles)
        saveDriveLogs(exportData.driveLogs)
        saveFuelEntries(exportData.fuelEntries)
        saveMaintenanceRecords(exportData.maintenanceRecords)
        saveSettings(exportData.settings)
        
        return true
    }
}

// MARK: - Export Data Structure
struct ExportData: Codable {
    let vehicles: [Vehicle]
    let driveLogs: [DriveLog]
    let fuelEntries: [FuelEntry]
    let maintenanceRecords: [MaintenanceRecord]
    let settings: AppSettings
    let exportDate: Date
} 