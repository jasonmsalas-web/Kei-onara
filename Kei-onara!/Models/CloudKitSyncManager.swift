import Foundation
import CloudKit
import SwiftUI

class CloudKitSyncManager: ObservableObject {
    @Published var isSyncing = false
    @Published var syncProgress: Double = 0.0
    @Published var syncStatus = ""
    
    private let container = CKContainer.default()
    private let database = CKContainer.default().privateCloudDatabase
    
    // Cache for expensive operations
    private var lastSyncDate: Date?
    private var syncCache: [String: Date] = [:]
    
    // MARK: - Optimized Sync Operations
    
    func syncAllData(vehicleManager: VehicleManager) async {
        guard !isSyncing else { return }
        
        await MainActor.run {
            isSyncing = true
            syncProgress = 0.0
            syncStatus = "Starting sync..."
        }
        
        do {
            // Sync vehicles first
            await MainActor.run {
                syncStatus = "Syncing vehicles..."
                syncProgress = 0.2
            }
            try await syncVehicles(vehicleManager)
            
            // Sync fuel entries
            await MainActor.run {
                syncStatus = "Syncing fuel entries..."
                syncProgress = 0.4
            }
            try await syncFuelEntries(vehicleManager)
            
            // Sync maintenance records
            await MainActor.run {
                syncStatus = "Syncing maintenance records..."
                syncProgress = 0.6
            }
            try await syncMaintenanceRecords(vehicleManager)
            
            // Sync drive logs
            await MainActor.run {
                syncStatus = "Syncing drive logs..."
                syncProgress = 0.8
            }
            try await syncDriveLogs(vehicleManager)
            
            // Update last sync date
            lastSyncDate = Date()
            syncCache["lastSync"] = lastSyncDate
            
            await MainActor.run {
                syncStatus = "Sync completed successfully!"
                syncProgress = 1.0
                isSyncing = false
            }
        } catch {
            await MainActor.run {
                syncStatus = "Sync failed: \(error.localizedDescription)"
                isSyncing = false
            }
        }
    }
    
    // MARK: - Optimized Individual Sync Methods
    
    private func syncVehicles(_ vehicleManager: VehicleManager) async throws {
        let records = vehicleManager.vehicles.map { vehicle in
            let record = CKRecord(recordType: "Vehicle")
            record["id"] = vehicle.id.uuidString
            record["name"] = vehicle.name
            record["make"] = vehicle.make
            record["model"] = vehicle.model
            record["year"] = vehicle.year
            record["currentOdometer"] = vehicle.currentOdometer
            record["fuelCapacity"] = vehicle.fuelCapacity
            record["isActive"] = vehicle.isActive
            record["createdAt"] = vehicle.createdAt
            record["vin"] = vehicle.vin ?? ""
            return record
        }
        
        try await saveRecords(records, to: database)
    }
    
    private func syncFuelEntries(_ vehicleManager: VehicleManager) async throws {
        let records = vehicleManager.fuelEntries.map { entry in
            let record = CKRecord(recordType: "FuelEntry")
            record["id"] = entry.id.uuidString
            record["vehicleId"] = entry.vehicleId.uuidString
            record["date"] = entry.date
            record["liters"] = entry.liters
            record["pricePerLiter"] = entry.pricePerLiter
            record["odometer"] = entry.odometer
            record["isFullTank"] = entry.isFullTank
            record["location"] = entry.location ?? ""
            record["fuelGrade"] = entry.fuelGrade.rawValue
            return record
        }
        
        try await saveRecords(records, to: database)
    }
    
    private func syncMaintenanceRecords(_ vehicleManager: VehicleManager) async throws {
        let records = vehicleManager.maintenanceRecords.map { record in
            let ckRecord = CKRecord(recordType: "MaintenanceRecord")
            ckRecord["id"] = record.id.uuidString
            ckRecord["vehicleId"] = record.vehicleId.uuidString
            ckRecord["type"] = record.type.rawValue
            ckRecord["date"] = record.date
            ckRecord["odometer"] = record.odometer
            ckRecord["cost"] = record.cost ?? 0
            ckRecord["notes"] = record.notes ?? ""
            ckRecord["locationOfService"] = record.locationOfService ?? ""
            ckRecord["nextDueOdometer"] = record.nextDueOdometer ?? 0
            ckRecord["nextDueDate"] = record.nextDueDate
            ckRecord["reminderEnabled"] = record.reminderEnabled
            ckRecord["reminderType"] = record.reminderType.rawValue
            ckRecord["reminderValue"] = record.reminderValue
            return ckRecord
        }
        
        try await saveRecords(records, to: database)
    }
    
    private func syncDriveLogs(_ vehicleManager: VehicleManager) async throws {
        let records = vehicleManager.driveLogs.map { log in
            let record = CKRecord(recordType: "DriveLog")
            record["id"] = log.id.uuidString
            record["vehicleId"] = log.vehicleId.uuidString
            record["startTime"] = log.startTime
            record["endTime"] = log.endTime
            record["startOdometer"] = log.startOdometer
            record["endOdometer"] = log.endOdometer ?? 0
            record["gpsDistance"] = log.gpsDistance
            record["isActive"] = log.isActive
            // Store route points as empty array for now (simplified)
            record["routePoints"] = "[]"
            return record
        }
        
        try await saveRecords(records, to: database)
    }
    
    // MARK: - Optimized Helper Methods
    
    private func saveRecords(_ records: [CKRecord], to database: CKDatabase) async throws {
        guard !records.isEmpty else { return }
        
        return try await withCheckedThrowingContinuation { continuation in
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    print("✅ Successfully saved \(records.count) records to CloudKit")
                    continuation.resume()
                case .failure(let error):
                    print("❌ Failed to save records to CloudKit: \(error)")
                    continuation.resume(throwing: error)
                }
            }
            
            database.add(operation)
        }
    }
    
    // MARK: - Upload Operations
    
    func uploadVehicle(_ vehicle: Vehicle) async throws {
        let record = vehicle.toCKRecord()
        try await database.save(record)
    }
    
    func uploadFuelEntry(_ fuelEntry: FuelEntry) async throws {
        let record = fuelEntry.toCKRecord()
        try await database.save(record)
    }
    
    func uploadMaintenanceRecord(_ maintenanceRecord: MaintenanceRecord) async throws {
        let record = maintenanceRecord.toCKRecord()
        try await database.save(record)
    }
    
    func uploadDriveLog(_ driveLog: DriveLog) async throws {
        let record = driveLog.toCKRecord()
        try await database.save(record)
    }
    
    // MARK: - Utility Methods
    
    func shouldSync() -> Bool {
        guard let lastSync = lastSyncDate else { return true }
        return Date().timeIntervalSince(lastSync) > 300 // 5 minutes
    }
    
    func clearCache() {
        syncCache.removeAll()
        lastSyncDate = nil
    }
}

// MARK: - CKRecord Extensions

extension Vehicle {
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Vehicle")
        record["name"] = name
        record["make"] = make
        record["model"] = model
        record["year"] = year
        record["currentOdometer"] = currentOdometer
        record["fuelCapacity"] = fuelCapacity
        record["isActive"] = isActive
        record["createdAt"] = createdAt
        record["vin"] = vin
        return record
    }
    
    init?(from record: CKRecord) {
        guard let name = record["name"] as? String,
              let make = record["make"] as? String,
              let model = record["model"] as? String,
              let year = record["year"] as? Int,
              let currentOdometer = record["currentOdometer"] as? Double,
              let fuelCapacity = record["fuelCapacity"] as? Double,
              let isActive = record["isActive"] as? Bool,
              let createdAt = record["createdAt"] as? Date else {
            return nil
        }
        
        self.id = UUID() // Generate new UUID instead of using record name
        self.name = name
        self.make = make
        self.model = model
        self.year = year
        self.currentOdometer = currentOdometer
        self.fuelCapacity = fuelCapacity
        self.isActive = isActive
        self.createdAt = createdAt
        self.vin = record["vin"] as? String
    }
}

extension FuelEntry {
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "FuelEntry")
        record["vehicleId"] = vehicleId.uuidString
        record["date"] = date
        record["liters"] = liters
        record["pricePerLiter"] = pricePerLiter
        record["odometer"] = odometer
        record["location"] = location
        record["fuelGrade"] = fuelGrade.rawValue
        return record
    }
    
    init?(from record: CKRecord) {
        guard let vehicleIdString = record["vehicleId"] as? String,
              let vehicleId = UUID(uuidString: vehicleIdString),
              let date = record["date"] as? Date,
              let liters = record["liters"] as? Double,
              let pricePerLiter = record["pricePerLiter"] as? Double,
              let odometer = record["odometer"] as? Double,
              let fuelGradeString = record["fuelGrade"] as? String,
              let fuelGrade = FuelGrade(rawValue: fuelGradeString) else {
            return nil
        }
        
        self.id = UUID() // Generate new UUID instead of using record name
        self.vehicleId = vehicleId
        self.date = date
        self.liters = liters
        self.pricePerLiter = pricePerLiter
        self.odometer = odometer
        self.location = record["location"] as? String
        self.fuelGrade = fuelGrade
    }
}

extension MaintenanceRecord {
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "MaintenanceRecord")
        record["vehicleId"] = vehicleId.uuidString
        record["type"] = type.rawValue
        record["date"] = date
        record["odometer"] = odometer
        record["cost"] = cost
        record["notes"] = notes
        record["locationOfService"] = locationOfService
        record["reminderEnabled"] = reminderEnabled
        record["reminderType"] = reminderType.rawValue
        record["reminderValue"] = reminderValue
        return record
    }
    
    init?(from record: CKRecord) {
        guard let vehicleIdString = record["vehicleId"] as? String,
              let vehicleId = UUID(uuidString: vehicleIdString),
              let typeString = record["type"] as? String,
              let type = MaintenanceType(rawValue: typeString),
              let date = record["date"] as? Date,
              let odometer = record["odometer"] as? Double,
              let reminderTypeString = record["reminderType"] as? String,
              let reminderType = ReminderType(rawValue: reminderTypeString),
              let reminderValue = record["reminderValue"] as? Double else {
            return nil
        }
        
        self.id = UUID() // Generate new UUID instead of using record name
        self.vehicleId = vehicleId
        self.type = type
        self.date = date
        self.odometer = odometer
        self.cost = record["cost"] as? Double
        self.notes = record["notes"] as? String
        self.locationOfService = record["locationOfService"] as? String
        self.reminderEnabled = record["reminderEnabled"] as? Bool ?? false
        self.reminderType = reminderType
        self.reminderValue = reminderValue
    }
}

extension DriveLog {
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "DriveLog")
        record["vehicleId"] = vehicleId.uuidString
        record["startTime"] = startTime
        record["endTime"] = endTime
        record["startOdometer"] = startOdometer
        record["endOdometer"] = endOdometer
        record["gpsDistance"] = gpsDistance
        record["isActive"] = isActive
        // Store route points as empty array for now (simplified)
        record["routePoints"] = "[]"
        return record
    }
    
    init?(from record: CKRecord) {
        guard let vehicleIdString = record["vehicleId"] as? String,
              let vehicleId = UUID(uuidString: vehicleIdString),
              let startTime = record["startTime"] as? Date,
              let startOdometer = record["startOdometer"] as? Double,
              let gpsDistance = record["gpsDistance"] as? Double,
              let isActive = record["isActive"] as? Bool else {
            return nil
        }
        
        self.id = UUID() // Generate new UUID instead of using record name
        self.vehicleId = vehicleId
        self.startTime = startTime
        self.endTime = record["endTime"] as? Date
        self.startOdometer = startOdometer
        self.endOdometer = record["endOdometer"] as? Double
        self.gpsDistance = gpsDistance
        self.isActive = isActive
        
        // Initialize route points as empty array for now (simplified)
        self.routePoints = []
    }
} 