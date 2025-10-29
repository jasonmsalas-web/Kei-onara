import Foundation
import CoreLocation
import WatchKit

class WatchLocationManager: NSObject, ObservableObject {
    @Published var currentSpeed: Double = 0.0
    @Published var currentHeading: Double = 0.0
    @Published var isLocationAuthorized = false
    
    private let locationManager = CLLocationManager()
    private let speedUnit: SpeedUnit = .mph
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1.0 // Update every 1 meter
        locationManager.headingFilter = 1.0 // Update every 1 degree
    }
    
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            isLocationAuthorized = false
        @unknown default:
            isLocationAuthorized = false
        }
    }
    
    private func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        isLocationAuthorized = true
    }
    
    private func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
}

// MARK: - CLLocationManagerDelegate

extension WatchLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update speed (convert from m/s to mph/kmh)
        let speedInMPS = location.speed
        if speedInMPS >= 0 {
            currentSpeed = speedUnit.convert(speedInMPS)
        } else {
            currentSpeed = 0.0
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Update heading (true heading if available, otherwise magnetic)
        if newHeading.headingAccuracy >= 0 {
            currentHeading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.isLocationAuthorized = true
                self.startLocationUpdates()
            case .denied, .restricted:
                self.isLocationAuthorized = false
                self.stopLocationUpdates()
            case .notDetermined:
                self.isLocationAuthorized = false
            @unknown default:
                self.isLocationAuthorized = false
            }
        }
    }
} 