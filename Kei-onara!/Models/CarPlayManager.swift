import Foundation
import CarPlay
import UIKit
import CoreLocation

class CarPlayManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var isConnected = false
    @Published var currentTemplate: CPTemplate?
    
    private var interfaceController: CPInterfaceController?
    private var vehicleManager: VehicleManager?
    private var locationManager: CLLocationManager?
    private var currentSpeed: Double = 0.0
    private var speedometerTemplate: CPListTemplate?
    
    override init() {
        super.init()
        print("🚗 CarPlayManager initialized")
    }
    
    func setup(with vehicleManager: VehicleManager) {
        self.vehicleManager = vehicleManager
        print("🚗 CarPlayManager setup with VehicleManager")
    }
    
    // MARK: - CarPlay Connection
    
    func connect(interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        isConnected = true
        print("🚗 CarPlay connected")
        
        // Show the main template
        showMainTemplate()
    }
    
    func isCarPlayAvailable() -> Bool {
        // Check if CarPlay is available on this device
        #if targetEnvironment(simulator)
        return false
        #else
        // For now, we'll assume CarPlay is available on physical devices
        // The actual connection will be handled by the scene delegate
        return true
        #endif
    }
    
    func isCarPlayConnected() -> Bool {
        return isConnected
    }
    
    func disconnect() {
        interfaceController = nil
        isConnected = false
        print("🚗 CarPlay disconnected")
    }
    
    // MARK: - Templates
    
    private func showMainTemplate() {
        let mainTemplate = createMainTemplate()
        interfaceController?.setRootTemplate(mainTemplate, animated: true) { [weak self] template, error in
            if error == nil {
                self?.currentTemplate = mainTemplate
            }
        }
    }
    
    private func createMainTemplate() -> CPTemplate {
        let fuelItem = CPListItem(text: "Log Fuel", detailText: "Quick fuel entry logging")
        fuelItem.handler = { [weak self] _, completion in
            self?.showFuelLoggingTemplate()
            completion()
        }
        
        let maintenanceItem = CPListItem(text: "Maintenance", detailText: "Log maintenance tasks")
        maintenanceItem.handler = { [weak self] _, completion in
            self?.showMaintenanceTemplate()
            completion()
        }
        
        let odometerItem = CPListItem(text: "Update Odometer", detailText: "Update current mileage")
        odometerItem.handler = { [weak self] _, completion in
            self?.showOdometerTemplate()
            completion()
        }
        
        let quickStatsItem = CPListItem(text: "Quick Stats", detailText: "View fuel efficiency")
        quickStatsItem.handler = { [weak self] _, completion in
            self?.showQuickStatsTemplate()
            completion()
        }
        
        let speedometerItem = CPListItem(text: "GPS Speedometer", detailText: "Real-time speed display")
        speedometerItem.handler = { [weak self] _, completion in
            self?.showSpeedometerTemplate()
            completion()
        }
        
        let template = CPListTemplate(title: "Kei-onara!", sections: [
            CPListSection(items: [
                fuelItem,
                maintenanceItem,
                odometerItem,
                quickStatsItem,
                speedometerItem
            ], header: nil, sectionIndexTitle: nil)
        ])
        
        return template
    }
    
    // MARK: - Fuel Logging
    
    private func showFuelLoggingTemplate() {
        guard let vehicleManager = vehicleManager,
              vehicleManager.currentVehicle != nil else {
            showErrorTemplate(message: "No vehicle selected")
            return
        }
        
        let template = CPAlertTemplate(titleVariants: ["Log Fuel Entry"], actions: [
            CPAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.showMainTemplate()
            },
            CPAlertAction(title: "Quick Log", style: .default) { [weak self] _ in
                self?.quickLogFuel()
            }
        ])
        
        interfaceController?.presentTemplate(template, animated: true) { _, _ in
            // Template presented successfully
        }
    }
    
    private func quickLogFuel() {
        guard let vehicleManager = vehicleManager,
              let currentVehicle = vehicleManager.currentVehicle else { return }
        
        // Get current odometer reading
        let currentOdometer = currentVehicle.currentOdometer
        
        // Add a fuel entry with estimated values (user can adjust later)
        let fuelEntry = FuelEntry(
            id: UUID(),
            vehicleId: currentVehicle.id,
            date: Date(),
            liters: 0.0, // Will be updated when user opens the app
            pricePerLiter: 0.0,
            odometer: currentOdometer,
            isFullTank: true,
            location: nil as String?,
            fuelGrade: FuelGrade.regular
        )
        
        vehicleManager.addFuelEntry(fuelEntry)
        
        // Show confirmation
        let template = CPAlertTemplate(titleVariants: ["Fuel Entry Logged"], actions: [
            CPAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.showMainTemplate()
            }
        ])
        
        interfaceController?.presentTemplate(template, animated: true) { _, _ in
            // Template presented successfully
        }
    }
    
    // MARK: - Maintenance
    
    private func showMaintenanceTemplate() {
        guard let vehicleManager = vehicleManager,
              vehicleManager.currentVehicle != nil else {
            showErrorTemplate(message: "No vehicle selected")
            return
        }
        
        let oilChangeItem = CPListItem(text: "Oil Change Due", detailText: "Log oil change")
        oilChangeItem.handler = { [weak self] _, completion in
            self?.logMaintenance(type: "Oil Change")
            completion()
        }
        
        let tireRotationItem = CPListItem(text: "Tire Rotation", detailText: "Log tire rotation")
        tireRotationItem.handler = { [weak self] _, completion in
            self?.logMaintenance(type: "Tire Rotation")
            completion()
        }
        
        let inspectionItem = CPListItem(text: "Inspection", detailText: "Log inspection")
        inspectionItem.handler = { [weak self] _, completion in
            self?.logMaintenance(type: "Inspection")
            completion()
        }
        
        let backItem = CPListItem(text: "Back", detailText: "Return to main menu")
        backItem.handler = { [weak self] _, completion in
            self?.showMainTemplate()
            completion()
        }
        
        let template = CPListTemplate(title: "Maintenance", sections: [
            CPListSection(items: [
                oilChangeItem,
                tireRotationItem,
                inspectionItem,
                backItem
            ], header: nil, sectionIndexTitle: nil)
        ])
        
        interfaceController?.pushTemplate(template, animated: true) { _, _ in
            // Template pushed successfully
        }
    }
    
    private func logMaintenance(type: String) {
        guard let vehicleManager = vehicleManager,
              let currentVehicle = vehicleManager.currentVehicle else { return }
        
        // Convert string to MaintenanceType
        let maintenanceType: MaintenanceType
        switch type {
        case "Oil Change":
            maintenanceType = .oilChange
        case "Tire Rotation":
            maintenanceType = .tireRotation
        case "Inspection":
            maintenanceType = .other
        default:
            maintenanceType = .other
        }
        
        let maintenanceRecord = MaintenanceRecord(
            vehicleId: currentVehicle.id,
            type: maintenanceType,
            date: Date(),
            odometer: currentVehicle.currentOdometer,
            cost: nil as Double?,
            notes: "Logged via CarPlay",
            locationOfService: nil as String?,
            nextDueOdometer: nil as Double?,
            nextDueDate: nil as Date?,
            reminderEnabled: false,
            reminderType: .odometer,
            reminderValue: 0
        )
        
        vehicleManager.addMaintenanceRecord(maintenanceRecord)
        
        let template = CPAlertTemplate(titleVariants: ["\(type) Logged"], actions: [
            CPAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.showMainTemplate()
            }
        ])
        
        interfaceController?.presentTemplate(template, animated: true) { _, _ in
            // Template presented successfully
        }
    }
    
    // MARK: - Odometer Update
    
    private func showOdometerTemplate() {
        guard let vehicleManager = vehicleManager,
              vehicleManager.currentVehicle != nil else {
            showErrorTemplate(message: "No vehicle selected")
            return
        }
        
        let template = CPAlertTemplate(titleVariants: ["Update Odometer"], actions: [
            CPAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.showMainTemplate()
            },
            CPAlertAction(title: "Update", style: .default) { [weak self] _ in
                self?.updateOdometer()
            }
        ])
        
        interfaceController?.presentTemplate(template, animated: true) { _, _ in
            // Template presented successfully
        }
    }
    
    private func updateOdometer() {
        guard let vehicleManager = vehicleManager,
              vehicleManager.currentVehicle != nil else { return }
        
        // For now, we'll just show a confirmation
        // In a full implementation, you'd want to add voice input or other input methods
        let template = CPAlertTemplate(titleVariants: ["Odometer Updated"], actions: [
            CPAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.showMainTemplate()
            }
        ])
        
        interfaceController?.presentTemplate(template, animated: true) { _, _ in
            // Template presented successfully
        }
    }
    
    // MARK: - Quick Stats
    
    private func showQuickStatsTemplate() {
        guard let vehicleManager = vehicleManager,
              let currentVehicle = vehicleManager.currentVehicle else {
            showErrorTemplate(message: "No vehicle selected")
            return
        }
        
        let currentMPG = vehicleManager.currentMPG()
        let averageMPG = vehicleManager.currentMPG() // Using currentMPG as average
        
        let mpgText = vehicleManager.settings.useMetric ? "km/L" : "MPG"
        let currentMPGFormatted = String(format: "%.1f", currentMPG)
        let averageMPGFormatted = String(format: "%.1f", averageMPG)
        
        let currentMPGItem = CPListItem(text: "Current \(mpgText)", detailText: currentMPGFormatted)
        let averageMPGItem = CPListItem(text: "Average \(mpgText)", detailText: averageMPGFormatted)
        let odometerItem = CPListItem(text: "Odometer", detailText: "\(Int(currentVehicle.currentOdometer)) \(vehicleManager.settings.useMetric ? "km" : "mi")")
        
        let backItem = CPListItem(text: "Back", detailText: "Return to main menu")
        backItem.handler = { [weak self] _, completion in
            self?.showMainTemplate()
            completion()
        }
        
        let template = CPListTemplate(title: "Quick Stats", sections: [
            CPListSection(items: [
                currentMPGItem,
                averageMPGItem,
                odometerItem,
                backItem
            ], header: nil, sectionIndexTitle: nil)
        ])
        
        interfaceController?.pushTemplate(template, animated: true) { _, _ in
            // Template pushed successfully
        }
    }
    
    // MARK: - GPS Speedometer
    
    private func showSpeedometerTemplate() {
        // Initialize location manager if needed
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager?.requestWhenInUseAuthorization()
        }
        
        // Start location updates
        locationManager?.startUpdatingLocation()
        
        // Create speedometer template
        let speedText = formatSpeed(currentSpeed)
        let speedItem = CPListItem(text: "Current Speed", detailText: speedText)
        let unitItem = CPListItem(text: "Units", detailText: vehicleManager?.settings.useMetric == true ? "km/h" : "mph")
        
        let backItem = CPListItem(text: "Back", detailText: "Return to main menu")
        backItem.handler = { [weak self] _, completion in
            self?.locationManager?.stopUpdatingLocation()
            self?.showMainTemplate()
            completion()
        }
        
        // Create a list template for the speedometer
        let template = CPListTemplate(title: "GPS Speedometer", sections: [
            CPListSection(items: [
                speedItem,
                unitItem,
                backItem
            ], header: nil, sectionIndexTitle: nil)
        ])
        
        speedometerTemplate = template
        
        interfaceController?.pushTemplate(speedometerTemplate!, animated: true) { _, _ in
            // Template pushed successfully
        }
    }
    
    private func formatSpeed(_ speed: Double) -> String {
        let useMetric = vehicleManager?.settings.useMetric ?? true
        
        if useMetric {
            // Convert m/s to km/h
            let kmh = speed * 3.6
            return String(format: "%.0f km/h", kmh)
        } else {
            // Convert m/s to mph
            let mph = speed * 2.23694
            return String(format: "%.0f mph", mph)
        }
    }
    
    private func updateSpeedometerDisplay() {
        guard let template = speedometerTemplate else { return }
        
        let speedText = formatSpeed(currentSpeed)
        let speedItem = CPListItem(text: "Current Speed", detailText: speedText)
        let unitItem = CPListItem(text: "Units", detailText: vehicleManager?.settings.useMetric == true ? "km/h" : "mph")
        
        let backItem = CPListItem(text: "Back", detailText: "Return to main menu")
        backItem.handler = { [weak self] _, completion in
            self?.locationManager?.stopUpdatingLocation()
            self?.showMainTemplate()
            completion()
        }
        
        // Update the template with new items
        template.updateSections([
            CPListSection(items: [
                speedItem,
                unitItem,
                backItem
            ], header: nil, sectionIndexTitle: nil)
        ])
    }
    
    // MARK: - Error Handling
    
    private func showErrorTemplate(message: String) {
        let template = CPAlertTemplate(titleVariants: [message], actions: [
            CPAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.showMainTemplate()
            }
        ])
        
        interfaceController?.presentTemplate(template, animated: true) { _, _ in
            // Template presented successfully
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update current speed (location.speed is in m/s)
        currentSpeed = max(0, location.speed)
        
        // Update the speedometer display if it's active
        DispatchQueue.main.async { [weak self] in
            self?.updateSpeedometerDisplay()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("🚗 CarPlay location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("🚗 CarPlay location access denied")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
} 