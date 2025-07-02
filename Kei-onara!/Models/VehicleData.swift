import Foundation
import SwiftUI

// MARK: - Core Data Models

struct Vehicle: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var make: String
    var model: String
    var year: Int
    var currentOdometer: Double
    var fuelCapacity: Double
    var isActive: Bool = true
    var createdAt: Date = Date()
    var photoData: Data? = nil // Optional vehicle photo
    
    var displayName: String {
        "\(year) \(make) \(model)"
    }
}

struct DriveLog: Identifiable, Codable {
    var id: UUID = UUID()
    var vehicleId: UUID
    var startTime: Date
    var endTime: Date?
    var startOdometer: Double
    var endOdometer: Double?
    var distance: Double {
        guard let endOdometer = endOdometer else { return 0 }
        return endOdometer - startOdometer
    }
    var isActive: Bool = false
    
    var duration: TimeInterval {
        guard let endTime = endTime else { return Date().timeIntervalSince(startTime) }
        return endTime.timeIntervalSince(startTime)
    }
}

enum FuelGrade: String, CaseIterable, Codable {
    case regular = "Regular"
    case midGrade = "Mid-grade"
    case premium = "Premium"
    case ethanolFree = "Ethanol Free"
    
    var icon: String {
        switch self {
        case .regular: return "fuelpump"
        case .midGrade: return "fuelpump.fill"
        case .premium: return "fuelpump.circle"
        case .ethanolFree: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .regular: return .green
        case .midGrade: return .orange
        case .premium: return .red
        case .ethanolFree: return .blue
        }
    }
}

struct FuelEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var vehicleId: UUID
    var date: Date
    var liters: Double
    var pricePerLiter: Double
    var odometer: Double
    var isFullTank: Bool = true
    var location: String?
    var fuelGrade: FuelGrade = .regular
    
    var totalCost: Double {
        liters * pricePerLiter
    }
    
    var gallons: Double {
        liters * 0.264172
    }
    
    var pricePerGallon: Double {
        pricePerLiter * 3.78541
    }
}

struct MaintenanceRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var vehicleId: UUID
    var type: MaintenanceType
    var date: Date
    var odometer: Double
    var cost: Double?
    var notes: String?
    var locationOfService: String?
    var nextDueOdometer: Double?
    var nextDueDate: Date?
    var reminderEnabled: Bool = false
    var reminderType: ReminderType = .odometer
    var reminderValue: Double = 0
    
    // Returns true if the current odometer is at or past the next due odometer
    func isOverdue(currentOdometer: Double) -> Bool {
        guard let nextDue = nextDueOdometer else { return false }
        return currentOdometer >= nextDue
    }
}

enum ReminderType: String, CaseIterable, Codable {
    case odometer = "Odometer"
    case date = "Date"
    
    var icon: String {
        switch self {
        case .odometer: return "speedometer"
        case .date: return "calendar"
        }
    }
}

enum MaintenanceType: String, CaseIterable, Codable {
    case oilChange = "Oil Change"
    case tireRotation = "Tire Rotation"
    case brakeCheck = "Brake Check"
    case airFilter = "Air Filter"
    case sparkPlugs = "Spark Plugs"
    case transmission = "Transmission"
    case coolant = "Coolant"
    case battery = "Battery"
    case tires = "Tire Replacement"
    case timingBelt = "Timing Belt"
    case waterPump = "Water Pump"
    case thermostat = "Thermostat"
    case differential = "Differential"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .oilChange: return "drop.fill"
        case .tireRotation: return "arrow.clockwise"
        case .brakeCheck: return "exclamationmark.triangle.fill"
        case .airFilter: return "wind"
        case .sparkPlugs: return "bolt.fill"
        case .transmission: return "gearshape.fill"
        case .coolant: return "thermometer"
        case .battery: return "battery.100"
        case .tires: return "circle.fill"
        case .timingBelt: return "timer"
        case .waterPump: return "drop.circle.fill"
        case .thermostat: return "thermometer.medium"
        case .differential: return "gearshape.2.fill"
        case .other: return "wrench.fill"
        }
    }
    
    var defaultInterval: Double {
        switch self {
        case .oilChange: return 5000 // km
        case .tireRotation: return 10000
        case .brakeCheck: return 15000
        case .airFilter: return 20000
        case .sparkPlugs: return 60000
        case .transmission: return 40000
        case .coolant: return 30000
        case .battery: return 50000
        case .tires: return 80000
        case .timingBelt: return 100000
        case .waterPump: return 80000
        case .thermostat: return 60000
        case .differential: return 50000
        case .other: return 0
        }
    }
}

enum ButtonColorPalette: String, CaseIterable, Codable, Identifiable {
    case `default` = "Default"
    case risingSun = "Japanese Rising Sun"
    case blueHue = "Blue Hue"
    case greenHue = "Green Hue"
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case indigo = "Indigo"
    case violet = "Violet"
    
    var id: String { rawValue }
}

struct AppSettings: Codable {
    var useMetric: Bool = true
    var enableNotifications: Bool = true
    var grandmaMode: Bool = false
    var darkMode: Bool = false
    var autoBackup: Bool = true
    var voiceEntryEnabled: Bool = false
    var mileageGoal: Double = 0
    var goalPeriod: GoalPeriod = .yearly
    var buttonPalette: ButtonColorPalette = .default
    var currentVehicleId: UUID? = nil
}

enum GoalPeriod: String, CaseIterable, Codable {
    case monthly = "Monthly"
    case yearly = "Yearly"
}

// MARK: - View Models

class VehicleManager: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var currentVehicle: Vehicle? {
        didSet {
            if !isInitializing {
                settings.currentVehicleId = currentVehicle?.id
                saveSettings()
            }
        }
    }
    @Published var driveLogs: [DriveLog] = []
    @Published var fuelEntries: [FuelEntry] = []
    @Published var maintenanceRecords: [MaintenanceRecord] = []
    private var isInitializing = true
    @Published var settings = AppSettings() {
        didSet {
            if !isInitializing {
                saveSettings()
            }
        }
    }
    
    init() {
        print("🚗 VehicleManager initializing...")
        loadData()
        isInitializing = false
        print("📊 Loaded data: \(vehicles.count) vehicles, \(fuelEntries.count) fuel entries, \(maintenanceRecords.count) maintenance records")
        
        if vehicles.isEmpty {
            print("🆕 Creating default vehicle")
            createDefaultVehicle()
        }
        // Restore the previously selected vehicle or default to the first active vehicle
        if let savedVehicleId = settings.currentVehicleId,
           let savedVehicle = vehicles.first(where: { $0.id == savedVehicleId }) {
            currentVehicle = savedVehicle
            print("🎯 Restored previously selected vehicle: \(currentVehicle?.displayName ?? "None")")
        } else {
            currentVehicle = vehicles.first { $0.isActive }
            print("🎯 Using default active vehicle: \(currentVehicle?.displayName ?? "None")")
        }
        print("🎯 Current vehicle: \(currentVehicle?.displayName ?? "None")")
        
        // Debug: Print fuel entries for current vehicle after it's set
        if let currentVehicle = currentVehicle {
            print("🔍 Current vehicle ID: \(currentVehicle.id)")
            print("🔍 All fuel entries:")
            for (index, entry) in fuelEntries.enumerated() {
                print("   Entry \(index + 1): Vehicle ID \(entry.vehicleId), \(entry.liters)L at \(entry.odometer)km")
            }
            
            let vehicleFuelEntries = fuelEntries.filter { $0.vehicleId == currentVehicle.id }
            print("🔍 Fuel entries for current vehicle:")
            for (index, entry) in vehicleFuelEntries.enumerated() {
                print("   Entry \(index + 1): \(entry.liters)L at \(entry.odometer)km - \(entry.gallons) gallons")
            }
            
            // If we have fuel entries but none match the current vehicle, migrate them
            if !fuelEntries.isEmpty && vehicleFuelEntries.isEmpty {
                print("🔄 Migrating fuel entries to current vehicle...")
                for i in fuelEntries.indices {
                    fuelEntries[i].vehicleId = currentVehicle.id
                }
                saveData()
                print("✅ Fuel entries migrated")
            }
            
            // If we have maintenance records but none match the current vehicle, migrate them
            let vehicleMaintenanceRecords = maintenanceRecords.filter { $0.vehicleId == currentVehicle.id }
            if !maintenanceRecords.isEmpty && vehicleMaintenanceRecords.isEmpty {
                print("🔄 Migrating maintenance records to current vehicle...")
                for i in maintenanceRecords.indices {
                    maintenanceRecords[i].vehicleId = currentVehicle.id
                }
                saveData()
                print("✅ Maintenance records migrated")
            }
        }
    }
    
    private func createDefaultVehicle() {
        let defaultVehicle = Vehicle(
            name: "Test Kei Truck",
            make: "Honda",
            model: "Acty",
            year: 1992,
            currentOdometer: 123456,
            fuelCapacity: 30,
            isActive: true,
            createdAt: Date(),
            photoData: nil
        )
        vehicles.append(defaultVehicle)
        currentVehicle = defaultVehicle
        // Add bogus fuel entries
        let now = Date()
        for i in 0..<5 {
            let entry = FuelEntry(
                vehicleId: defaultVehicle.id,
                date: Calendar.current.date(byAdding: .day, value: -i*7, to: now)!,
                liters: Double.random(in: 20...30),
                pricePerLiter: Double.random(in: 1.2...1.8),
                odometer: 123456 - Double(i * 300),
                isFullTank: true
            )
            fuelEntries.append(entry)
        }
        // Add bogus maintenance records
        for i in 0..<3 {
            let record = MaintenanceRecord(
                vehicleId: defaultVehicle.id,
                type: MaintenanceType.allCases.randomElement()!,
                date: Calendar.current.date(byAdding: .month, value: -i*3, to: now)!,
                odometer: 123456 - Double(i * 1000),
                cost: Double.random(in: 50...200),
                notes: "Test maintenance note #\(i+1)",
                nextDueOdometer: 123456 - Double(i * 1000) + 5000,
                nextDueDate: nil
            )
            maintenanceRecords.append(record)
        }
    }
    
    func startDrive() {
        guard let vehicle = currentVehicle else { return }
        
        // End any active drives first
        endActiveDrives()
        
        let newDrive = DriveLog(
            vehicleId: vehicle.id,
            startTime: Date(),
            startOdometer: vehicle.currentOdometer,
            isActive: true
        )
        driveLogs.append(newDrive)
        saveData()
    }
    
    func endDrive() {
        guard let vehicle = currentVehicle else { return }
        
        if let activeDriveIndex = driveLogs.firstIndex(where: { $0.isActive }) {
            driveLogs[activeDriveIndex].endTime = Date()
            driveLogs[activeDriveIndex].endOdometer = vehicle.currentOdometer
            driveLogs[activeDriveIndex].isActive = false
            saveData()
        }
    }
    
    private func endActiveDrives() {
        for i in driveLogs.indices {
            if driveLogs[i].isActive {
                driveLogs[i].endTime = Date()
                driveLogs[i].isActive = false
            }
        }
    }
    
    func addFuelEntry(liters: Double, pricePerLiter: Double, odometer: Double, date: Date = Date(), location: String? = nil, fuelGrade: FuelGrade = .regular) {
        guard let vehicle = currentVehicle else { return }
        
        let fuelEntry = FuelEntry(
            vehicleId: vehicle.id,
            date: date,
            liters: liters,
            pricePerLiter: pricePerLiter,
            odometer: odometer,
            location: location,
            fuelGrade: fuelGrade
        )
        fuelEntries.append(fuelEntry)
        
        // Update vehicle odometer
        if let vehicleIndex = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[vehicleIndex].currentOdometer = odometer
            currentVehicle = vehicles[vehicleIndex]
        }
        
        saveData()
    }
    
    func updateFuelEntry(_ fuelEntry: FuelEntry, date: Date, liters: Double, pricePerLiter: Double, odometer: Double, location: String?, fuelGrade: FuelGrade) {
        guard let index = fuelEntries.firstIndex(where: { $0.id == fuelEntry.id }) else { return }
        
        fuelEntries[index].date = date
        fuelEntries[index].liters = liters
        fuelEntries[index].pricePerLiter = pricePerLiter
        fuelEntries[index].odometer = odometer
        fuelEntries[index].location = location
        fuelEntries[index].fuelGrade = fuelGrade
        
        saveData()
    }
    
    func addMaintenanceRecord(type: MaintenanceType, date: Date = Date(), odometer: Double, cost: Double?, notes: String?, locationOfService: String? = nil, reminderEnabled: Bool = false, reminderType: ReminderType = .odometer, reminderValue: Double = 0) {
        guard let vehicle = currentVehicle else { return }
        
        let nextDueOdometer = odometer + type.defaultInterval
        
        let maintenanceRecord = MaintenanceRecord(
            vehicleId: vehicle.id,
            type: type,
            date: date,
            odometer: odometer,
            cost: cost,
            notes: notes,
            locationOfService: locationOfService,
            nextDueOdometer: nextDueOdometer,
            reminderEnabled: reminderEnabled,
            reminderType: reminderType,
            reminderValue: reminderValue
        )
        maintenanceRecords.append(maintenanceRecord)
        saveData()
        
        // Schedule reminder if enabled
        if reminderEnabled {
            scheduleMaintenanceReminder(for: maintenanceRecord, vehicle: vehicle)
        }
    }
    
    func updateMaintenanceRecord(_ record: MaintenanceRecord, type: MaintenanceType, date: Date, odometer: Double, cost: Double?, notes: String?, locationOfService: String? = nil, reminderEnabled: Bool = false, reminderType: ReminderType = .odometer, reminderValue: Double = 0) {
        guard let index = maintenanceRecords.firstIndex(where: { $0.id == record.id }) else { return }
        
        let nextDueOdometer = odometer + type.defaultInterval
        
        maintenanceRecords[index].type = type
        maintenanceRecords[index].date = date
        maintenanceRecords[index].odometer = odometer
        maintenanceRecords[index].cost = cost
        maintenanceRecords[index].notes = notes
        maintenanceRecords[index].locationOfService = locationOfService
        maintenanceRecords[index].nextDueOdometer = nextDueOdometer
        maintenanceRecords[index].reminderEnabled = reminderEnabled
        maintenanceRecords[index].reminderType = reminderType
        maintenanceRecords[index].reminderValue = reminderValue
        
        saveData()
        
        // Update reminder if enabled
        if reminderEnabled {
            scheduleMaintenanceReminder(for: maintenanceRecords[index], vehicle: currentVehicle!)
        }
    }
    
    func deleteMaintenanceRecord(_ record: MaintenanceRecord) {
        maintenanceRecords.removeAll { $0.id == record.id }
        saveData()
    }
    
    private func scheduleMaintenanceReminder(for record: MaintenanceRecord, vehicle: Vehicle) {
        let notificationManager = NotificationManager.shared
        
        if record.reminderType == .odometer {
            let targetOdometer = record.odometer + record.reminderValue
            notificationManager.scheduleMileageReminder(
                currentMileage: vehicle.currentOdometer,
                targetMileage: targetOdometer,
                vehicleName: vehicle.displayName
            )
        } else {
            let targetDate = Date().addingTimeInterval(record.reminderValue * 24 * 60 * 60) // Convert days to seconds
            notificationManager.scheduleMaintenanceReminder(
                type: record.type,
                dueDate: targetDate,
                vehicleName: vehicle.displayName
            )
        }
    }
    
    // MARK: - Calculations
    
    func currentMPG() -> Double {
        let vehicleFuelEntries = fuelEntries.filter { $0.vehicleId == currentVehicle?.id }
        let recentFuelEntries = Array(vehicleFuelEntries.suffix(2)) // Last 2 fill-ups
        
        print("🔍 Current MPG calculation (last 2 fill-ups):")
        print("   Vehicle ID: \(currentVehicle?.id ?? UUID())")
        print("   Total fuel entries: \(vehicleFuelEntries.count)")
        print("   Recent fuel entries: \(recentFuelEntries.count)")
        
        guard recentFuelEntries.count >= 2 else { 
            print("   ❌ Not enough fuel entries for MPG calculation")
            return 0 
        }
        
        let sortedEntries = recentFuelEntries.sorted { $0.odometer < $1.odometer }
        
        // Calculate distance and fuel consumption for last 2 fill-ups
        let distance = sortedEntries[1].odometer - sortedEntries[0].odometer
        let gallons = sortedEntries[1].gallons
        
        let mpg = gallons > 0 ? distance / gallons : 0
        print("   📊 Distance: \(distance)km / \(gallons) gallons")
        print("   🚗 Current MPG: \(mpg)")
        
        return mpg
    }
    
    func averageMPG() -> Double {
        let vehicleFuelEntries = fuelEntries.filter { $0.vehicleId == currentVehicle?.id }
        
        print("🔍 Average MPG calculation (all fill-ups):")
        print("   Vehicle ID: \(currentVehicle?.id ?? UUID())")
        print("   Total fuel entries: \(vehicleFuelEntries.count)")
        
        guard vehicleFuelEntries.count >= 2 else { 
            print("   ❌ Not enough fuel entries for MPG calculation")
            return 0 
        }
        
        let sortedEntries = vehicleFuelEntries.sorted { $0.odometer < $1.odometer }
        
        // Calculate total distance and fuel consumption across all fill-ups
        var totalDistance = 0.0
        var totalGallons = 0.0
        
        for i in 1..<sortedEntries.count {
            let distance = sortedEntries[i].odometer - sortedEntries[i-1].odometer
            let gallons = sortedEntries[i].gallons
            totalDistance += distance
            totalGallons += gallons
            print("   📊 Entry \(i): \(distance)km / \(gallons) gallons")
        }
        
        let mpg = totalGallons > 0 ? totalDistance / totalGallons : 0
        print("   📏 Total distance: \(totalDistance) km")
        print("   ⛽ Total gallons: \(totalGallons)")
        print("   🚗 Average MPG: \(mpg)")
        
        return mpg
    }
    
    func totalFuelCost() -> Double {
        fuelEntries
            .filter { $0.vehicleId == currentVehicle?.id }
            .reduce(0) { $0 + $1.totalCost }
    }
    
    func totalMaintenanceCost() -> Double {
        maintenanceRecords
            .filter { $0.vehicleId == currentVehicle?.id }
            .compactMap { $0.cost }
            .reduce(0, +)
    }
    
    // MARK: - Multi-Vehicle Management
    
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
        if currentVehicle == nil {
            currentVehicle = vehicle
        }
        saveData()
    }
    
    func updateVehicle(_ vehicle: Vehicle, name: String, make: String, model: String, year: Int, currentOdometer: Double, fuelCapacity: Double, photoData: Data? = nil) {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index].name = name
            vehicles[index].make = make
            vehicles[index].model = model
            vehicles[index].year = year
            vehicles[index].currentOdometer = currentOdometer
            vehicles[index].fuelCapacity = fuelCapacity
            vehicles[index].photoData = photoData
            
            // Update current vehicle if it's the one being edited
            if currentVehicle?.id == vehicle.id {
                currentVehicle = vehicles[index]
            }
            saveData()
        }
    }
    
    func deleteVehicle(_ vehicle: Vehicle) {
        // Remove all data associated with this vehicle
        driveLogs.removeAll { $0.vehicleId == vehicle.id }
        fuelEntries.removeAll { $0.vehicleId == vehicle.id }
        maintenanceRecords.removeAll { $0.vehicleId == vehicle.id }
        
        // Remove the vehicle
        vehicles.removeAll { $0.id == vehicle.id }
        
        // If we deleted the current vehicle, switch to another one
        if currentVehicle?.id == vehicle.id {
            currentVehicle = vehicles.first
        }
        
        saveData()
    }
    
    func switchToVehicle(_ vehicle: Vehicle) {
        print("🔄 Switching to vehicle: \(vehicle.displayName)")
        currentVehicle = vehicle
        saveData()
        print("✅ Vehicle switched and saved")
    }
    
    func transferData(from sourceVehicle: Vehicle, to destinationVehicle: Vehicle) {
        // Transfer drive logs
        for i in driveLogs.indices {
            if driveLogs[i].vehicleId == sourceVehicle.id {
                driveLogs[i].vehicleId = destinationVehicle.id
            }
        }
        
        // Transfer fuel entries
        for i in fuelEntries.indices {
            if fuelEntries[i].vehicleId == sourceVehicle.id {
                fuelEntries[i].vehicleId = destinationVehicle.id
            }
        }
        
        // Transfer maintenance records
        for i in maintenanceRecords.indices {
            if maintenanceRecords[i].vehicleId == sourceVehicle.id {
                maintenanceRecords[i].vehicleId = destinationVehicle.id
            }
        }
        
        // Delete the source vehicle
        deleteVehicle(sourceVehicle)
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        vehicles = DataManager.shared.loadVehicles()
        driveLogs = DataManager.shared.loadDriveLogs()
        fuelEntries = DataManager.shared.loadFuelEntries()
        maintenanceRecords = DataManager.shared.loadMaintenanceRecords()
        settings = DataManager.shared.loadSettings()
    }
    
    private func saveData() {
        print("💾 Saving all data...")
        DataManager.shared.saveVehicles(vehicles)
        DataManager.shared.saveDriveLogs(driveLogs)
        DataManager.shared.saveFuelEntries(fuelEntries)
        DataManager.shared.saveMaintenanceRecords(maintenanceRecords)
        DataManager.shared.saveSettings(settings)
        print("✅ All data saved")
    }
    
    private func saveSettings() {
        print("💾 Saving settings - useMetric: \(settings.useMetric)")
        DataManager.shared.saveSettings(settings)
        print("✅ Settings saved")
    }
} 