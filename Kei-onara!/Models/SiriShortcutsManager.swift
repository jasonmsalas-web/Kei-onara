import Foundation
import Intents
import IntentsUI

// MARK: - Notification Names
extension Notification.Name {
    static let showFuelEntry = Notification.Name("showFuelEntry")
    static let showSpeedometer = Notification.Name("showSpeedometer")
    static let showMaintenance = Notification.Name("showMaintenance")
}

class SiriShortcutsManager: ObservableObject {
    static let shared = SiriShortcutsManager()
    
    @Published var availableShortcuts: [NSUserActivity] = []
    
    private init() {
        setupShortcuts()
    }
    
    func setupShortcuts() {
        // Create shortcuts for the app using NSUserActivity
        createLogGasShortcut()
        createStartRideShortcut()
        createLogMaintenanceShortcut()
    }
    
    private func createLogGasShortcut() {
        let activity = NSUserActivity(activityType: "LogGasActivity")
        activity.title = "Log Gas"
        activity.suggestedInvocationPhrase = "Log my gas"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        availableShortcuts.append(activity)
    }
    
    private func createStartRideShortcut() {
        let activity = NSUserActivity(activityType: "StartRideActivity")
        activity.title = "Start Ride"
        activity.suggestedInvocationPhrase = "Start my ride"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        availableShortcuts.append(activity)
    }
    
    private func createLogMaintenanceShortcut() {
        let activity = NSUserActivity(activityType: "LogMaintenanceActivity")
        activity.title = "Log Maintenance"
        activity.suggestedInvocationPhrase = "Log maintenance"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        availableShortcuts.append(activity)
    }
    
    func donateLogGasShortcut() {
        let activity = NSUserActivity(activityType: "LogGasActivity")
        activity.title = "Log Gas"
        activity.suggestedInvocationPhrase = "Log my gas"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        
        // Donate the activity directly
        activity.becomeCurrent()
    }
    
    func donateStartRideShortcut() {
        let activity = NSUserActivity(activityType: "StartRideActivity")
        activity.title = "Start Ride"
        activity.suggestedInvocationPhrase = "Start my ride"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        
        // Donate the activity directly
        activity.becomeCurrent()
    }
    
    func donateLogMaintenanceShortcut() {
        let activity = NSUserActivity(activityType: "LogMaintenanceActivity")
        activity.title = "Log Maintenance"
        activity.suggestedInvocationPhrase = "Log maintenance"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        
        // Donate the activity directly
        activity.becomeCurrent()
    }
    
    func handleShortcut(_ activity: NSUserActivity) {
        // Handle shortcuts based on activity type
        if activity.activityType == "LogGasActivity" {
            NotificationCenter.default.post(name: .showFuelEntry, object: nil)
        } else if activity.activityType == "StartRideActivity" {
            NotificationCenter.default.post(name: .showSpeedometer, object: nil)
        } else if activity.activityType == "LogMaintenanceActivity" {
            NotificationCenter.default.post(name: .showMaintenance, object: nil)
        }
    }
    
    func donateAllShortcuts() {
        donateLogGasShortcut()
        donateStartRideShortcut()
        donateLogMaintenanceShortcut()
    }
} 