import Foundation
import UIKit
import CarPlay

class AppDelegate: NSObject, UIApplicationDelegate {
    let vehicleManager = VehicleManager()
    let carPlayManager = CarPlayManager()
    let siriShortcutsManager = SiriShortcutsManager.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🚗 AppDelegate initialized")
        
        // Setup CarPlay manager with vehicle manager
        carPlayManager.setup(with: vehicleManager)
        
        // Initialize Siri Shortcuts
        setupSiriShortcuts()
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("🚗 Configuring scene for CarPlay")
        
        if connectingSceneSession.role == .carTemplateApplication {
            let config = UISceneConfiguration(name: "CarPlay", sessionRole: .carTemplateApplication)
            config.delegateClass = CarPlaySceneDelegate.self
            return config
        }
        
        return UISceneConfiguration(name: "Default", sessionRole: .windowApplication)
    }
    
    // MARK: - Siri Shortcuts
    
    private func setupSiriShortcuts() {
        // Donate shortcuts to Siri
        siriShortcutsManager.donateLogGasShortcut()
        siriShortcutsManager.donateStartRideShortcut()
        siriShortcutsManager.donateLogMaintenanceShortcut()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Handle Siri shortcuts
        siriShortcutsManager.handleShortcut(userActivity)
        return true
    }
} 