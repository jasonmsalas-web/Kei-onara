import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleMaintenanceReminder(type: MaintenanceType, dueDate: Date, vehicleName: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔧 Maintenance Reminder"
        content.body = "Time for \(type.rawValue) on your \(vehicleName)! 🚛"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day], from: dueDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "maintenance-\(type.rawValue)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleMileageReminder(currentMileage: Double, targetMileage: Double, vehicleName: String) {
        let content = UNMutableNotificationContent()
        content.title = "📊 Mileage Alert"
        content.body = "You're approaching \(Int(targetMileage)) km on your \(vehicleName)! 🚛"
        content.sound = .default
        
        // Schedule for when we're 500km away from target
        let estimatedDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // 1 week from now
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day], from: estimatedDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "mileage-reminder-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleFuelReminder(daysSinceLastFuel: Int) {
        let content = UNMutableNotificationContent()
        content.title = "⛽ Fuel Reminder"
        content.body = "It's been \(daysSinceLastFuel) days since your last fuel entry! 🚛"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: false) // 24 hours
        
        let request = UNNotificationRequest(
            identifier: "fuel-reminder-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleAchievementNotification(achievement: String) {
        let content = UNMutableNotificationContent()
        content.title = "🏆 Achievement Unlocked!"
        content.body = "\(achievement) 🎉"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // Immediate
        
        let request = UNNotificationRequest(
            identifier: "achievement-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Achievement Tracking
    
    func checkForAchievements(vehicleManager: VehicleManager) {
        // Fuel efficiency achievement
        let mpg = vehicleManager.averageMPG()
        if mpg > 50 {
            scheduleAchievementNotification(achievement: "Fuel Saver! You're getting over 50 MPG! ⛽")
        }
        
        // Maintenance achievement
        let maintenanceCount = vehicleManager.maintenanceRecords.count
        if maintenanceCount >= 10 {
            scheduleAchievementNotification(achievement: "Maintenance Master! You've logged 10+ maintenance records! 🔧")
        }
        
        // Mileage achievement
        if let vehicle = vehicleManager.currentVehicle {
            if vehicle.currentOdometer >= 100000 {
                scheduleAchievementNotification(achievement: "Century Club! Your Kei has reached 100,000 km! 🚛")
            }
        }
    }
} 