import Foundation
import CarPlay
import UIKit

class CarPlaySceneDelegate: NSObject, CPTemplateApplicationSceneDelegate {
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        print("🚗 CarPlay scene connected")
        
        // Get the CarPlay manager from AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("❌ Failed to get AppDelegate")
            return
        }
        
        // Connect to CarPlay with the shared manager
        appDelegate.carPlayManager.connect(interfaceController: interfaceController)
        print("✅ CarPlay connected successfully")
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didSelect navigationAlert: CPNavigationAlert) {
        print("🚗 CarPlay navigation alert selected")
        // Handle navigation alert selection if needed
    }
} 