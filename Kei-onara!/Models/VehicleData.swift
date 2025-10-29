import Foundation
import SwiftUI
import Speech
import CloudKit
import CoreLocation

// MARK: - Backup Data Structure

struct BackupData: Codable {
    let vehicles: [Vehicle]
    let driveLogs: [DriveLog]
    let fuelEntries: [FuelEntry]
    let maintenanceRecords: [MaintenanceRecord]
    let settings: AppSettings
    let timestamp: Date
    let version: String
    
    init(vehicles: [Vehicle], driveLogs: [DriveLog], fuelEntries: [FuelEntry], maintenanceRecords: [MaintenanceRecord], settings: AppSettings, timestamp: Date) {
        self.vehicles = vehicles
        self.driveLogs = driveLogs
        self.fuelEntries = fuelEntries
        self.maintenanceRecords = maintenanceRecords
        self.settings = settings
        self.timestamp = timestamp
        self.version = "1.0"
    }
}

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
    var photoAssetRecordName: String? // CloudKit asset reference
    var photoData: Data? // Not included in BackupData for iCloud
    var vin: String? // Vehicle Identification Number
    var insuranceCardData: Data? // Insurance card image/PDF data
    
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
    var gpsDistance: Double = 0 // GPS-calculated distance in miles
    var distance: Double {
        // Use GPS distance if available, otherwise fall back to odometer difference
        if gpsDistance > 0 {
            return gpsDistance
        }
        guard let endOdometer = endOdometer else { return 0 }
        return endOdometer - startOdometer
    }
    var isActive: Bool = false
    var routePoints: [RoutePoint] = [] // GPS coordinates for the route
    
    var duration: TimeInterval {
        guard let endTime = endTime else { return Date().timeIntervalSince(startTime) }
        return endTime.timeIntervalSince(startTime)
    }
}

struct RoutePoint: Identifiable, Codable {
    var id: UUID = UUID()
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var speed: Double? // Speed in mph
    var altitude: Double?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
    
    var color: Color {
        switch self {
        case .oilChange: return .orange
        case .tireRotation: return .blue
        case .brakeCheck: return .red
        case .airFilter: return .green
        case .sparkPlugs: return .yellow
        case .transmission: return .purple
        case .coolant: return .cyan
        case .battery: return .green
        case .tires: return .gray
        case .timingBelt: return .brown
        case .waterPump: return .blue
        case .thermostat: return .orange
        case .differential: return .indigo
        case .other: return .gray
        }
    }
}

enum UIStyle: String, CaseIterable, Codable, Identifiable {
    case steveJobs = "Steve Jobs"
    
    var id: String { rawValue }
}

struct AppSettings: Codable {
    var useMetric: Bool = true
    var enableNotifications: Bool = true
    var isDarkModeEnabled: Bool = false
    var autoBackup: Bool = true
    var mileageGoal: Double = 0
    var goalPeriod: GoalPeriod = .yearly
    var uiStyle: UIStyle = .steveJobs
    var currentVehicleId: UUID? = nil
}

enum GoalPeriod: String, CaseIterable, Codable {
    case monthly = "Monthly"
    case yearly = "Yearly"
}

// MARK: - View Models

class VehicleManager: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var fuelEntries: [FuelEntry] = []
    @Published var maintenanceRecords: [MaintenanceRecord] = []
    @Published var driveLogs: [DriveLog] = []
    @Published var settings = AppSettings() {
        didSet {
            updateColorScheme()
            // Force UI updates when settings change
            objectWillChange.send()
            // Save settings immediately
            saveSettings()
            // Increment build number when settings are changed
            versionManager.incrementBuildNumber()
        }
    }
    @Published var colorSchemeManager = ColorSchemeManager()
    @Published var versionManager = VersionManager()
    
    // Separate published property for unit setting to ensure SwiftUI detects changes
    @Published var useMetricUnits: Bool = true
    
    // Optimized computed properties for better performance
    private var _currentVehicle: Vehicle?
    var currentVehicle: Vehicle? {
        get {
            if _currentVehicle == nil {
                _currentVehicle = vehicles.first { $0.isActive }
            }
            return _currentVehicle
        }
        set {
            _currentVehicle = newValue
        }
    }
    
    // Enhanced caching for expensive calculations
    private var _fuelEfficiencyCache: [UUID: Double] = [:]
    private var _maintenanceCostCache: [UUID: Double] = [:]
    private var _fuelCostCache: [UUID: Double] = [:]
    private var _totalExpenseCache: [UUID: Double] = [:]
    
    // File management
    private let vehiclesFile = "vehicles.json"
    private let driveLogsFile = "driveLogs.json"
    private let fuelEntriesFile = "fuelEntries.json"
    private let maintenanceRecordsFile = "maintenanceRecords.json"
    private let settingsFile = "settings.json"
    
    // MARK: - Initialization
    
    init() {
        loadAllData()
        // Sync useMetricUnits with settings
        useMetricUnits = settings.useMetric
        updateColorScheme()
    }
    
    // MARK: - Color Scheme Management
    
    func updateColorScheme() {
        colorSchemeManager.updateDarkMode(settings.isDarkModeEnabled)
        
        // Update global UI appearance
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = self.settings.isDarkModeEnabled ? .dark : .light
                }
            }
        }
    }
    
    // MARK: - Settings Sync
    
    func syncUnitSetting() {
        // Update settings when useMetricUnits changes
        if settings.useMetric != useMetricUnits {
            settings.useMetric = useMetricUnits
            objectWillChange.send()
            saveSettings()
            // Increment build number when unit setting changes
            versionManager.incrementBuildNumber()
        }
    }
    
    // MARK: - Fuel Efficiency Calculations
    
    func currentMPG() -> Double {
        guard let currentVehicle = currentVehicle else { return 0 }
        
        // Get the most recent fuel entries for the current vehicle
        let recentEntries = fuelEntries
            .filter { $0.vehicleId == currentVehicle.id }
            .sorted { $0.date > $1.date }
            .prefix(2)
        
        guard recentEntries.count >= 2 else { return 0 }
        
        let currentEntry = recentEntries.first!
        let previousEntry = recentEntries.dropFirst().first!
        
        let distance = currentEntry.odometer - previousEntry.odometer
        let gallons = currentEntry.gallons
        
        // Prevent division by zero and ensure valid values
        guard distance > 0, gallons > 0, !distance.isNaN, !gallons.isNaN else { return 0 }
        
        let mpg = distance / gallons
        return mpg.isNaN || mpg.isInfinite ? 0 : mpg
    }
    
    func todaysMileage(for vehicleId: UUID? = nil) -> Double {
        let targetVehicleId = vehicleId ?? currentVehicle?.id
        guard let vehicleId = targetVehicleId else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todaysDriveLogs = driveLogs.filter { driveLog in
            driveLog.vehicleId == vehicleId &&
            calendar.isDate(driveLog.startTime, inSameDayAs: today)
        }
        
        let totalDistance = todaysDriveLogs.reduce(0) { total, driveLog in
            let distance = driveLog.distance
            // Prevent NaN values
            guard !distance.isNaN && !distance.isInfinite else { return total }
            return total + distance
        }
        
        return totalDistance.isNaN || totalDistance.isInfinite ? 0 : totalDistance
    }
    
    func totalFuelCost() -> Double {
        guard let currentVehicle = currentVehicle else { return 0 }
        
        let vehicleFuelEntries = fuelEntries.filter { $0.vehicleId == currentVehicle.id }
        let totalCost = vehicleFuelEntries.reduce(0) { total, entry in
            let cost = entry.totalCost
            // Prevent NaN values
            guard !cost.isNaN && !cost.isInfinite else { return total }
            return total + cost
        }
        
        return totalCost.isNaN || totalCost.isInfinite ? 0 : totalCost
    }
    
    func totalMaintenanceCost() -> Double {
        guard let currentVehicle = currentVehicle else { return 0 }
        
        let vehicleMaintenanceRecords = maintenanceRecords.filter { $0.vehicleId == currentVehicle.id }
        let totalCost = vehicleMaintenanceRecords.reduce(0) { total, record in
            let cost = record.cost ?? 0
            // Prevent NaN values
            guard !cost.isNaN && !cost.isInfinite else { return total }
            return total + cost
        }
        
        return totalCost.isNaN || totalCost.isInfinite ? 0 : totalCost
    }
    
    // MARK: - Optimized Data Management
    
    func loadAllData() {
        loadVehicles()
        loadFuelEntries()
        loadMaintenanceRecords()
        loadDriveLogs()
        loadSettings()
        clearAllCaches() // Clear caches on fresh load
    }
    
    func saveAllData() {
        saveVehicles()
        saveFuelEntries()
        saveMaintenanceRecords()
        saveDriveLogs()
        saveSettings()
    }
    
    // MARK: - Optimized Vehicle Management
    
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
        saveVehicles()
        _currentVehicle = nil // Reset cache
    }
    
    func updateVehicle(_ vehicle: Vehicle) {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index] = vehicle
            saveVehicles()
            _currentVehicle = nil // Reset cache
        }
    }
    
    func deleteVehicle(_ vehicle: Vehicle) {
        vehicles.removeAll { $0.id == vehicle.id }
        // Clean up related data
        fuelEntries.removeAll { $0.vehicleId == vehicle.id }
        maintenanceRecords.removeAll { $0.vehicleId == vehicle.id }
        driveLogs.removeAll { $0.vehicleId == vehicle.id }
        
        saveAllData()
        clearAllCaches()
    }
    
    func setCurrentVehicle(_ vehicle: Vehicle) {
        // Deactivate all vehicles
        for i in vehicles.indices {
            vehicles[i].isActive = false
        }
        
        // Activate selected vehicle
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index].isActive = true
            _currentVehicle = vehicles[index]
        }
        
        saveVehicles()
    }
    
    // MARK: - Optimized Fuel Management
    
    func addFuelEntry(_ fuelEntry: FuelEntry) {
        fuelEntries.append(fuelEntry)
        saveFuelEntries()
        _fuelEfficiencyCache.removeValue(forKey: fuelEntry.vehicleId) // Clear cache
        _fuelCostCache.removeValue(forKey: fuelEntry.vehicleId) // Clear fuel cost cache
        _totalExpenseCache.removeValue(forKey: fuelEntry.vehicleId) // Clear total expense cache
    }
    
    func updateFuelEntry(_ fuelEntry: FuelEntry) {
        if let index = fuelEntries.firstIndex(where: { $0.id == fuelEntry.id }) {
            fuelEntries[index] = fuelEntry
            saveFuelEntries()
            _fuelEfficiencyCache.removeValue(forKey: fuelEntry.vehicleId) // Clear cache
            _fuelCostCache.removeValue(forKey: fuelEntry.vehicleId) // Clear fuel cost cache
            _totalExpenseCache.removeValue(forKey: fuelEntry.vehicleId) // Clear total expense cache
        }
    }
    
    func deleteFuelEntry(_ fuelEntry: FuelEntry) {
        fuelEntries.removeAll { $0.id == fuelEntry.id }
        saveFuelEntries()
        _fuelEfficiencyCache.removeValue(forKey: fuelEntry.vehicleId) // Clear cache
        _fuelCostCache.removeValue(forKey: fuelEntry.vehicleId) // Clear fuel cost cache
        _totalExpenseCache.removeValue(forKey: fuelEntry.vehicleId) // Clear total expense cache
    }
    
    // MARK: - Optimized Maintenance Management
    
    func addMaintenanceRecord(_ record: MaintenanceRecord) {
        maintenanceRecords.append(record)
        saveMaintenanceRecords()
        _maintenanceCostCache.removeValue(forKey: record.vehicleId) // Clear cache
        _totalExpenseCache.removeValue(forKey: record.vehicleId) // Clear total expense cache
    }
    
    func updateMaintenanceRecord(_ record: MaintenanceRecord) {
        if let index = maintenanceRecords.firstIndex(where: { $0.id == record.id }) {
            maintenanceRecords[index] = record
            saveMaintenanceRecords()
            _maintenanceCostCache.removeValue(forKey: record.vehicleId) // Clear cache
            _totalExpenseCache.removeValue(forKey: record.vehicleId) // Clear total expense cache
        }
    }
    
    func deleteMaintenanceRecord(_ record: MaintenanceRecord) {
        maintenanceRecords.removeAll { $0.id == record.id }
        saveMaintenanceRecords()
        _maintenanceCostCache.removeValue(forKey: record.vehicleId) // Clear cache
        _totalExpenseCache.removeValue(forKey: record.vehicleId) // Clear total expense cache
    }
    
    // MARK: - Optimized Drive Log Management
    
    func addDriveLog(_ driveLog: DriveLog) {
        driveLogs.append(driveLog)
        saveDriveLogs()
    }
    
    func updateDriveLog(_ driveLog: DriveLog) {
        if let index = driveLogs.firstIndex(where: { $0.id == driveLog.id }) {
            driveLogs[index] = driveLog
            saveDriveLogs()
        }
    }
    
    func deleteDriveLog(_ driveLog: DriveLog) {
        driveLogs.removeAll { $0.id == driveLog.id }
        saveDriveLogs()
    }
    
    func startDrive() {
        // End any existing active drive first
        endDrive()
        
        // Create a new drive log
        guard let currentVehicle = currentVehicle else { return }
        
        let driveLog = DriveLog(
            vehicleId: currentVehicle.id,
            startTime: Date(),
            endTime: nil,
            startOdometer: currentVehicle.currentOdometer,
            endOdometer: nil,
            gpsDistance: 0,
            isActive: true,
            routePoints: []
        )
        
        addDriveLog(driveLog)
    }
    
    func endDrive() {
        // Find the active drive log and end it
        if let activeIndex = driveLogs.firstIndex(where: { $0.isActive }) {
            driveLogs[activeIndex].endTime = Date()
            driveLogs[activeIndex].endOdometer = currentVehicle?.currentOdometer ?? 0
            driveLogs[activeIndex].isActive = false
            saveDriveLogs()
        }
    }
    
    // MARK: - Optimized Calculations with Caching
    
    func currentMPG(for vehicleId: UUID? = nil) -> Double {
        let targetVehicleId = vehicleId ?? currentVehicle?.id
        guard let vehicleId = targetVehicleId else { return 0 }
        
        // Check cache first
        if let cachedMPG = _fuelEfficiencyCache[vehicleId] {
            return cachedMPG
        }
        
        let vehicleFuelEntries = fuelEntries.filter { $0.vehicleId == vehicleId }
        guard vehicleFuelEntries.count >= 2 else { return 0 }
        
        // Calculate MPG based on last two entries
        let sortedEntries = vehicleFuelEntries.sorted { $0.date < $1.date }
        let lastTwoEntries = Array(sortedEntries.suffix(2))
        
        guard lastTwoEntries.count == 2 else { return 0 }
        
        let distance = lastTwoEntries[1].odometer - lastTwoEntries[0].odometer
        let gallons = lastTwoEntries[1].gallons
        
        let mpg = distance > 0 && gallons > 0 ? distance / gallons : 0
        
        _fuelEfficiencyCache[vehicleId] = mpg // Cache the result
        
        return mpg
    }
    
    func totalMaintenanceCost(for vehicleId: UUID? = nil) -> Double {
        let targetVehicleId = vehicleId ?? currentVehicle?.id
        guard let vehicleId = targetVehicleId else { return 0 }
        
        // Check cache first
        if let cachedCost = _maintenanceCostCache[vehicleId] {
            return cachedCost
        }
        
        let totalCost = maintenanceRecords
            .filter { $0.vehicleId == vehicleId }
            .reduce(0) { $0 + ($1.cost ?? 0) }
        
        _maintenanceCostCache[vehicleId] = totalCost // Cache the result
        
        return totalCost
    }
    
    // Optimized fuel cost calculation with caching
    func totalFuelCost(for vehicleId: UUID? = nil) -> Double {
        let targetVehicleId = vehicleId ?? currentVehicle?.id
        guard let vehicleId = targetVehicleId else { return 0 }
        
        // Check cache first
        if let cachedCost = _fuelCostCache[vehicleId] {
            return cachedCost
        }
        
        let totalCost = fuelEntries
            .filter { $0.vehicleId == vehicleId }
            .reduce(0) { $0 + $1.totalCost }
        
        _fuelCostCache[vehicleId] = totalCost // Cache the result
        
        return totalCost
    }
    
    // New optimized total expense calculation
    func totalExpenses(for vehicleId: UUID? = nil) -> Double {
        let targetVehicleId = vehicleId ?? currentVehicle?.id
        guard let vehicleId = targetVehicleId else { return 0 }
        
        // Check cache first
        if let cachedTotal = _totalExpenseCache[vehicleId] {
            return cachedTotal
        }
        
        let total = totalFuelCost(for: vehicleId) + totalMaintenanceCost(for: vehicleId)
        _totalExpenseCache[vehicleId] = total // Cache the result
        
        return total
    }
    
    // MARK: - Cache Management
    
    private func clearAllCaches() {
        _fuelEfficiencyCache.removeAll()
        _maintenanceCostCache.removeAll()
        _fuelCostCache.removeAll()
        _totalExpenseCache.removeAll()
    }
    
    // MARK: - Optimized File Operations
    
    private func fileURL(for fileName: String) -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent(fileName)
    }
    
    private func saveVehicles() {
        let url = fileURL(for: vehiclesFile)
        do {
            let data = try JSONEncoder().encode(vehicles)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("❌ Error saving vehicles: \(error)")
        }
    }
    
    private func loadVehicles() {
        let url = fileURL(for: vehiclesFile)
        guard let data = try? Data(contentsOf: url) else { return }
        vehicles = (try? JSONDecoder().decode([Vehicle].self, from: data)) ?? []
    }
    
    private func saveFuelEntries() {
        let url = fileURL(for: fuelEntriesFile)
        do {
            let data = try JSONEncoder().encode(fuelEntries)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("❌ Error saving fuel entries: \(error)")
        }
    }
    
    private func loadFuelEntries() {
        let url = fileURL(for: fuelEntriesFile)
        guard let data = try? Data(contentsOf: url) else { return }
        fuelEntries = (try? JSONDecoder().decode([FuelEntry].self, from: data)) ?? []
    }
    
    private func saveMaintenanceRecords() {
        let url = fileURL(for: maintenanceRecordsFile)
        do {
            let data = try JSONEncoder().encode(maintenanceRecords)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("❌ Error saving maintenance records: \(error)")
        }
    }
    
    private func loadMaintenanceRecords() {
        let url = fileURL(for: maintenanceRecordsFile)
        guard let data = try? Data(contentsOf: url) else { return }
        maintenanceRecords = (try? JSONDecoder().decode([MaintenanceRecord].self, from: data)) ?? []
    }
    
    private func saveDriveLogs() {
        let url = fileURL(for: driveLogsFile)
        do {
            let data = try JSONEncoder().encode(driveLogs)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("❌ Error saving drive logs: \(error)")
        }
    }
    
    private func loadDriveLogs() {
        let url = fileURL(for: driveLogsFile)
        guard let data = try? Data(contentsOf: url) else { return }
        driveLogs = (try? JSONDecoder().decode([DriveLog].self, from: data)) ?? []
    }
    
    private func saveSettings() {
        let url = fileURL(for: settingsFile)
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("❌ Error saving settings: \(error)")
        }
    }
    
    private func loadSettings() {
        let url = fileURL(for: settingsFile)
        guard let data = try? Data(contentsOf: url) else { return }
        settings = (try? JSONDecoder().decode(AppSettings.self, from: data)) ?? AppSettings()
    }
    
    // MARK: - Optimized Backup Operations
    
    func restoreFromBackup(_ backupData: BackupData) {
        vehicles = backupData.vehicles
        fuelEntries = backupData.fuelEntries
        maintenanceRecords = backupData.maintenanceRecords
        driveLogs = backupData.driveLogs
        settings = backupData.settings
        
        // Clear all caches after restore
        clearAllCaches()
        
        saveAllData()
    }
    
    func exportData() -> String {
        let backupData = BackupData(
            vehicles: vehicles,
            driveLogs: driveLogs,
            fuelEntries: fuelEntries,
            maintenanceRecords: maintenanceRecords,
            settings: settings,
            timestamp: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(backupData) {
            return String(data: encoded, encoding: .utf8) ?? ""
        }
        
        return ""
    }
    
    func importData(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8),
              let backupData = try? JSONDecoder().decode(BackupData.self, from: data) else {
            return false
        }
        
        restoreFromBackup(backupData)
        return true
    }
    
    func clearAllData() {
        vehicles.removeAll()
        fuelEntries.removeAll()
        maintenanceRecords.removeAll()
        driveLogs.removeAll()
        settings = AppSettings()
        
        clearAllCaches()
        saveAllData()
    }
}

// MARK: - Speech Manager for Voice Entry

class SpeechManager: ObservableObject {
    @Published var isListening = false
    @Published var transcribedText = ""
    @Published var isAuthorized = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.isAuthorized = status == .authorized
            }
        }
    }
    
    func startListening() {
        guard !isListening else { return }
        
        // Reset
        transcribedText = ""
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error)")
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
            
            if error != nil {
                self.stopListening()
            }
        }
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isListening = true
            }
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        DispatchQueue.main.async {
            self.isListening = false
        }
    }
    
    func parseVoiceCommand(_ text: String, vehicleManager: VehicleManager) -> Bool {
        let lowercased = text.lowercased()
        
        // Fuel entry patterns
        if lowercased.contains("log my fuel") || lowercased.contains("add fuel") {
            return parseFuelCommand(text, vehicleManager: vehicleManager)
        }
        
        // Maintenance patterns
        if lowercased.contains("maintenance") || lowercased.contains("service") {
            return parseMaintenanceCommand(text, vehicleManager: vehicleManager)
        }
        
        // Drive logging patterns
        if lowercased.contains("start drive") || lowercased.contains("begin drive") {
            vehicleManager.startDrive()
            return true
        }
        
        if lowercased.contains("end drive") || lowercased.contains("stop drive") {
            vehicleManager.endDrive()
            return true
        }
        
        return false
    }
    
    private func parseFuelCommand(_ text: String, vehicleManager: VehicleManager) -> Bool {
        // Extract numbers from text like "30 liters at 100,000 km"
        let words = text.components(separatedBy: " ")
        
        var liters: Double?
        var odometer: Double?
        
        for (index, word) in words.enumerated() {
            if let number = Double(word.replacingOccurrences(of: ",", with: "")) {
                // Check if next word indicates what this number represents
                if index + 1 < words.count {
                    let nextWord = words[index + 1].lowercased()
                    if nextWord.contains("liter") || nextWord.contains("gallon") {
                        liters = number
                    } else if nextWord.contains("km") || nextWord.contains("mile") {
                        odometer = number
                    }
                }
            }
        }
        
        if let liters = liters, let odometer = odometer {
            // Use current vehicle's odometer if not specified
            let finalOdometer = odometer > 0 ? odometer : (vehicleManager.currentVehicle?.currentOdometer ?? 0)
            
            let fuelEntry = FuelEntry(
                vehicleId: vehicleManager.currentVehicle?.id ?? UUID(),
                date: Date(),
                liters: liters,
                pricePerLiter: 0, // Default price, user can edit later
                odometer: finalOdometer
            )
            
            vehicleManager.addFuelEntry(fuelEntry)
            return true
        }
        
        return false
    }
    
    private func parseMaintenanceCommand(_ text: String, vehicleManager: VehicleManager) -> Bool {
        let lowercased = text.lowercased()
        
        // Determine maintenance type
        var maintenanceType: MaintenanceType = .oilChange
        
        if lowercased.contains("oil") {
            maintenanceType = .oilChange
        } else if lowercased.contains("tire") || lowercased.contains("tyre") {
            maintenanceType = .tireRotation
        } else if lowercased.contains("brake") {
            maintenanceType = .brakeCheck
        } else if lowercased.contains("filter") {
            maintenanceType = .airFilter
        }
        
        // Extract odometer if mentioned
        var odometer: Double = vehicleManager.currentVehicle?.currentOdometer ?? 0
        
        let words = text.components(separatedBy: " ")
        for word in words {
            if let number = Double(word.replacingOccurrences(of: ",", with: "")) {
                odometer = number
                break
            }
        }
        
        let maintenanceRecord = MaintenanceRecord(
            vehicleId: vehicleManager.currentVehicle?.id ?? UUID(),
            type: maintenanceType,
            date: Date(),
            odometer: odometer,
            cost: nil as Double?,
            notes: "Added via voice command",
            locationOfService: nil as String?,
            nextDueOdometer: nil as Double?,
            nextDueDate: nil as Date?,
            reminderEnabled: false,
            reminderType: ReminderType.odometer,
            reminderValue: 0
        )
        
        vehicleManager.addMaintenanceRecord(maintenanceRecord)
        
        return true
    }
}

// MARK: - iCloud Backup Manager

class CloudBackupManager: ObservableObject {
    @Published var isBackingUp = false
    @Published var isRestoring = false
    @Published var lastBackupDate: Date?
    @Published var backupStatus: String = ""
    
    private let container = CKContainer.default()
    private let backupRecordType = "KeiOnaraBackup"
    
    init() {
        loadLastBackupDate()
    }
    
    func checkCloudStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.backupStatus = "iCloud available"
                case .noAccount:
                    self?.backupStatus = "No iCloud account"
                case .restricted:
                    self?.backupStatus = "iCloud restricted"
                case .couldNotDetermine:
                    self?.backupStatus = "iCloud status unknown"
                case .temporarilyUnavailable:
                    self?.backupStatus = "iCloud temporarily unavailable"
                @unknown default:
                    self?.backupStatus = "iCloud status unknown"
                }
            }
        }
    }
    
    func backupToCloud(vehicleManager: VehicleManager) {
        // Safety check for CloudKit entitlements
        guard isCloudKitAvailable() else {
            backupStatus = "CloudKit not available - check entitlements"
            return
        }
        
        isBackingUp = true
        backupStatus = "Preparing backup..."
        
        // 1. Save vehicle images as CKAsset records
        let group = DispatchGroup()
        var updatedVehicles: [Vehicle] = []
        var assetSaveError: Error? = nil
        
        for var vehicle in vehicleManager.vehicles {
            if let photoData = vehicle.photoData {
                group.enter()
                // Save photoData to a temporary file
                let tempDir = FileManager.default.temporaryDirectory
                let fileURL = tempDir.appendingPathComponent("\(vehicle.id).jpg")
                do {
                    try photoData.write(to: fileURL)
                    let asset = CKAsset(fileURL: fileURL)
                    let assetRecord = CKRecord(recordType: "VehiclePhoto")
                    assetRecord["photo"] = asset
                    assetRecord["vehicleId"] = vehicle.id.uuidString
                    
                    container.privateCloudDatabase.save(assetRecord) { savedRecord, error in
                        if let error = error {
                            assetSaveError = error
                            print("❌ Error saving photo asset: \(error)")
                        } else if let savedRecord = savedRecord {
                            vehicle.photoAssetRecordName = savedRecord.recordID.recordName
                            print("✅ Saved photo asset: \(savedRecord.recordID.recordName)")
                        }
                        // Clean up temp file
                        try? FileManager.default.removeItem(at: fileURL)
                        updatedVehicles.append(vehicle)
                        group.leave()
                    }
                } catch {
                    print("❌ Error writing temp photo file: \(error)")
                    group.leave()
                }
            } else {
                updatedVehicles.append(vehicle)
            }
        }
        
        group.notify(queue: .main) {
            if let error = assetSaveError {
                self.backupStatus = "Backup failed: \(error.localizedDescription)"
                self.isBackingUp = false
                return
            }
            
            // 2. Create backup data (excluding photoData)
            let backupData = BackupData(
                vehicles: updatedVehicles,
                driveLogs: vehicleManager.driveLogs,
                fuelEntries: vehicleManager.fuelEntries,
                maintenanceRecords: vehicleManager.maintenanceRecords,
                settings: vehicleManager.settings,
                timestamp: Date()
            )
            
            // Encode to JSON
            guard let jsonData = try? JSONEncoder().encode(backupData) else {
                self.backupStatus = "Failed to encode backup data"
                self.isBackingUp = false
                return
            }
            
            self.backupStatus = "Uploading to iCloud..."
            
            // Create CloudKit record
            let record = CKRecord(recordType: self.backupRecordType)
            record["backupData"] = jsonData
            record["timestamp"] = Date()
            record["version"] = "1.0"
            
            // Save to CloudKit
            self.container.privateCloudDatabase.save(record) { [weak self] record, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.backupStatus = "Backup failed: \(error.localizedDescription)"
                        print("❌ Cloud backup error: \(error)")
                    } else {
                        self?.backupStatus = "Backup completed successfully!"
                        self?.lastBackupDate = Date()
                        self?.saveLastBackupDate()
                        print("✅ Cloud backup successful")
                    }
                    self?.isBackingUp = false
                }
            }
        }
    }
    
    func restoreFromCloud(vehicleManager: VehicleManager) {
        // Safety check for CloudKit entitlements
        guard isCloudKitAvailable() else {
            backupStatus = "CloudKit not available - check entitlements"
            return
        }
        
        isRestoring = true
        backupStatus = "Searching for backup..."
        
        // Query for latest backup
        let query = CKQuery(recordType: backupRecordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        container.privateCloudDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { [weak self] result in
            switch result {
            case .success(let queryResult):
                let records = queryResult.matchResults.compactMap { try? $0.1.get() }
                DispatchQueue.main.async {
                    if let record = records.first,
                       let backupData = record["backupData"] as? Data {
                        self?.backupStatus = "Restoring data..."
                        
                        // Decode backup data
                        guard let backup = try? JSONDecoder().decode(BackupData.self, from: backupData) else {
                            self?.backupStatus = "Failed to decode backup data"
                            self?.isRestoring = false
                            return
                        }
                        
                        // Restore data (text, numbers, etc.)
                        vehicleManager.restoreFromBackup(backup)
                        self?.backupStatus = "Restoring images..."
                        
                        // Fetch vehicle images from CloudKit
                        let group = DispatchGroup()
                        var updatedVehicles = vehicleManager.vehicles
                        for (i, vehicle) in updatedVehicles.enumerated() {
                            if let assetRecordName = vehicle.photoAssetRecordName {
                                group.enter()
                                let recordID = CKRecord.ID(recordName: assetRecordName)
                                self?.container.privateCloudDatabase.fetch(withRecordID: recordID) { assetRecord, error in
                                    if let assetRecord = assetRecord,
                                       let asset = assetRecord["photo"] as? CKAsset,
                                       let fileURL = asset.fileURL,
                                       let data = try? Data(contentsOf: fileURL) {
                                        updatedVehicles[i].photoData = data
                                    } else {
                                        print("❌ Failed to fetch photo asset for vehicle: \(vehicle.id)")
                                    }
                                    group.leave()
                                }
                            }
                        }
                        group.notify(queue: .main) {
                            vehicleManager.vehicles = updatedVehicles
                            self?.backupStatus = "Restore completed successfully!"
                            print("✅ Cloud restore successful (with images)")
                            self?.isRestoring = false
                        }
                    } else {
                        self?.backupStatus = "No backup found"
                        self?.isRestoring = false
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.backupStatus = "Restore failed: \(error.localizedDescription)"
                    self?.isRestoring = false
                }
            }
        }
    }
    
    private func isCloudKitAvailable() -> Bool {
        // Check if CloudKit entitlements are properly configured
        #if targetEnvironment(simulator)
        // In simulator, CloudKit might not work properly
        return false
        #else
        // On device, we'll try to use CloudKit
        return true
        #endif
    }
    
    private func loadLastBackupDate() {
        if let date = UserDefaults.standard.object(forKey: "LastCloudBackupDate") as? Date {
            lastBackupDate = date
        }
    }
    
    private func saveLastBackupDate() {
        UserDefaults.standard.set(lastBackupDate, forKey: "LastCloudBackupDate")
    }
}

// MARK: - Version Management

class VersionManager: ObservableObject {
    @Published var currentBuildNumber: Int = 222
    @Published var currentVersion: String = "1.0"
    @Published var buildName: String = "Freeway"
    
    private let buildNumberKey = "CurrentBuildNumber"
    private let versionKey = "CurrentVersion"
    private let buildNameKey = "BuildName"
    
    init() {
        loadVersionInfo()
    }
    
    func incrementBuildNumber() {
        currentBuildNumber += 1
        saveVersionInfo()
    }
    
    func getFullVersionString() -> String {
        return "\(currentVersion).\(currentBuildNumber) (\(buildName))"
    }
    
    func getBuildString() -> String {
        return "\(currentVersion).\(currentBuildNumber) (\(buildName))"
    }
    
    private func loadVersionInfo() {
        let defaults = UserDefaults.standard
        currentBuildNumber = defaults.integer(forKey: buildNumberKey)
        if currentBuildNumber == 0 {
            currentBuildNumber = 222 // Default starting build number
        }
        currentVersion = defaults.string(forKey: versionKey) ?? "1.0"
        buildName = defaults.string(forKey: buildNameKey) ?? "Freeway"
    }
    
    private func saveVersionInfo() {
        let defaults = UserDefaults.standard
        defaults.set(currentBuildNumber, forKey: buildNumberKey)
        defaults.set(currentVersion, forKey: versionKey)
        defaults.set(buildName, forKey: buildNameKey)
    }
}