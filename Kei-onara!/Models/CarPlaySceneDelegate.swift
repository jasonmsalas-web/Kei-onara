import Foundation
import CarPlay
import UIKit

class CarPlaySceneDelegate: NSObject, CPTemplateApplicationSceneDelegate {
    private var carPlayManager: CarPlayManager?
    private var vehicleManager: VehicleManager?
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        print("🚗 CarPlay scene connected")
        
        // Get the shared vehicle manager
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.vehicleManager = appDelegate.vehicleManager
            self.carPlayManager = appDelegate.carPlayManager
        }
        
        // Setup CarPlay manager
        carPlayManager?.setup(with: vehicleManager ?? VehicleManager())
        carPlayManager?.connect(interfaceController: interfaceController)
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didSelect navigationAlert: CPNavigationAlert) {
        print("🚗 CarPlay navigation alert selected")
        // Handle navigation alert selection if needed
    }
} 