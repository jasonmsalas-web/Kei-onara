import SwiftUI
import CoreLocation
import MapKit

struct SpeedometerView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @StateObject private var locationManager = LocationManager()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingMap = false
    @State private var tripStartTime: Date? = nil
    @State private var tripDistance: Double = 0
    @State private var maxSpeed: Double = 0
    @State private var averageSpeed: Double = 0
    
    // Add a state to track if GPS is live
    @State private var gpsLive: Bool = false
    
    private var gpsStatusText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Requesting GPS..."
        case .denied, .restricted:
            return "GPS Access Denied"
        case .authorizedWhenInUse, .authorizedAlways:
            return gpsLive ? "GPS Live" : "No GPS Signal"
        @unknown default:
            return "GPS Unknown"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Live GPS indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(gpsLive ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    Text(gpsStatusText)
                        .font(.caption)
                        .foregroundColor(gpsLive ? .green : .red)
                    Spacer()
                    if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                        Button("Settings") {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal)
                
                // Speed Display
                VStack(spacing: 16) {
                    Text("\(Int(locationManager.currentSpeed ?? 0))")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("MPH")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    if let speed = locationManager.currentSpeed {
                        Text("\(Int(speed * 1.60934)) km/h")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(.systemBackground))
                
                // Trip Stats
                if tripStartTime != nil {
                    VStack(spacing: 16) {
                        Text("Trip Stats")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 32) {
                            VStack(spacing: 8) {
                                Text("\(String(format: "%.1f", tripDistance))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Miles")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 8) {
                                Text("\(Int(maxSpeed))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Max MPH")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 8) {
                                Text("\(String(format: "%.1f", averageSpeed))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Avg MPH")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Button(action: startTrip) {
                            VStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 48))
                                Text("Start Trip")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(tripStartTime == nil ? Color.green : Color.gray)
                            .cornerRadius(16)
                        }
                        .disabled(tripStartTime != nil)
                        
                        Button(action: endTrip) {
                            VStack(spacing: 8) {
                                Image(systemName: "stop.circle.fill")
                                    .font(.system(size: 48))
                                Text("End Trip")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(tripStartTime != nil ? Color.red : Color.gray)
                            .cornerRadius(16)
                        }
                        .disabled(tripStartTime == nil)
                    }
                    
                    Button(action: { showingMap = true }) {
                        HStack {
                            Image(systemName: "map.fill")
                                .font(.title2)
                            Text("Show Route")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(16)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Speedometer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingMap) {
            RouteMapView(locationManager: locationManager, vehicleManager: vehicleManager)
        }
        .onAppear {
            // Start updating GPS status
            locationManager.startTrip()
        }
        .onDisappear {
            locationManager.endTrip()
            gpsLive = false
        }
        .onReceive(locationManager.$currentSpeed) { speed in
            gpsLive = speed != nil
            updateTripStats(speed: speed)
        }
        .onReceive(locationManager.$authorizationStatus) { status in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationManager.startTrip()
            }
        }
    }
    
    private func startTrip() {
        tripStartTime = Date()
        tripDistance = 0
        maxSpeed = 0
        averageSpeed = 0
        locationManager.startTrip()
    }
    
    private func endTrip() {
        tripStartTime = nil
        locationManager.endTrip()
        
        // Save trip data to drive log
        if let startTime = tripStartTime {
            vehicleManager.addTripLog(
                startTime: startTime,
                endTime: Date(),
                distance: tripDistance,
                maxSpeed: maxSpeed,
                averageSpeed: averageSpeed
            )
        }
    }
    
    private func updateTripStats(speed: Double?) {
        guard let speed = speed, tripStartTime != nil else { return }
        
        // Update max speed
        if speed > maxSpeed {
            maxSpeed = speed
        }
        
        // Update average speed (simplified calculation)
        // In a real app, you'd track all speed readings and calculate properly
        averageSpeed = (averageSpeed + speed) / 2
        
        // Update distance (simplified - in real app you'd use GPS coordinates)
        // This is just a placeholder calculation
        tripDistance += speed * 0.000277778 // Convert mph to miles per second
    }
}

struct RouteMapView: View {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var vehicleManager: VehicleManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Route list
                List {
                    Section("Recent Routes") {
                        let currentVehicleRoutes = vehicleManager.driveLogs
                            .filter { $0.vehicleId == vehicleManager.currentVehicle?.id }
                            .sorted(by: { $0.startTime > $1.startTime })
                            .prefix(15)
                        
                        if currentVehicleRoutes.isEmpty {
                            Text("No recorded routes yet")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(Array(currentVehicleRoutes.enumerated()), id: \.element.id) { index, route in
                                RouteRow(route: route, index: index + 1)
                            }
                        }
                    }
                }
                .navigationTitle("Recent Routes")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct RouteRow: View {
    let route: DriveLog
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Route #\(index)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(route.startTime, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Distance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", route.distance)) miles")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDuration(route.duration))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Odometer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(route.startOdometer)) → \(Int(route.endOdometer ?? route.startOdometer)) km")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            if let endTime = route.endTime {
                Text("\(route.startTime, style: .time) - \(endTime, style: .time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var currentSpeed: Double?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTrip() {
        switch authorizationStatus {
        case .notDetermined:
            requestLocationPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied")
        @unknown default:
            break
        }
    }
    
    func endTrip() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update speed (convert from m/s to mph)
        currentSpeed = location.speed * 2.23694
        
        // Update map region
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}

// Extension to VehicleManager for trip logging
extension VehicleManager {
    func addTripLog(startTime: Date, endTime: Date, distance: Double, maxSpeed: Double, averageSpeed: Double) {
        guard let vehicle = currentVehicle else { return }
        
        let driveLog = DriveLog(
            vehicleId: vehicle.id,
            startTime: startTime,
            endTime: endTime,
            startOdometer: vehicle.currentOdometer,
            endOdometer: vehicle.currentOdometer + distance
        )
        
        driveLogs.append(driveLog)
        
        // Update vehicle odometer
        if let vehicleIndex = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[vehicleIndex].currentOdometer += distance
            currentVehicle = vehicles[vehicleIndex]
        }
    }
}

#Preview {
    SpeedometerView(vehicleManager: VehicleManager())
} 