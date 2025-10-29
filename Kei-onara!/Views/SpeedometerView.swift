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
    @State private var currentDriveLog: DriveLog? = nil
    
    // Add a state to track if GPS is live
    @State private var gpsLive: Bool = false
    
    // Steve Jobs style speedometer color
    private var speedometerColor: Color {
        return .blue
    }
    
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
                        .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                    
                    Text("MPH")
                        .font(.title2)
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                    
                    if let speed = locationManager.currentSpeed {
                        Text("\(Int(speed * 1.60934)) km/h")
                            .font(.title3)
                            .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(vehicleManager.colorSchemeManager.cardBackgroundColor)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Trip Stats
                if tripStartTime != nil {
                    VStack(spacing: 16) {
                        Text("Trip Stats")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                        
                        HStack(spacing: 32) {
                            VStack(spacing: 8) {
                                Text("\(String(format: "%.1f", tripDistance))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                                Text("Miles")
                                    .font(.caption)
                                    .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                            }
                            
                            VStack(spacing: 8) {
                                Text("\(Int(maxSpeed))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                                Text("Max MPH")
                                    .font(.caption)
                                    .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                            }
                            
                            VStack(spacing: 8) {
                                Text("\(String(format: "%.1f", averageSpeed))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                                Text("Avg MPH")
                                    .font(.caption)
                                    .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                            }
                        }
                    }
                    .padding()
                    .background(vehicleManager.colorSchemeManager.cardBackgroundColor)
                    .cornerRadius(16)
                    .padding(.horizontal)
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
                            .background(tripStartTime == nil ? speedometerColor : speedometerColor.opacity(0.5))
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
                            .background(tripStartTime != nil ? speedometerColor : speedometerColor.opacity(0.5))
                            .cornerRadius(16)
                        }
                        .disabled(tripStartTime == nil)
                    }
                    
                    Button(action: { showingMap = true }) {
                        HStack {
                            Image(systemName: "map.fill")
                                .font(.title2)
                            Text("Show Routes")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(speedometerColor)
                        .cornerRadius(16)
                    }
                }
                .padding()
                
                Spacer()
            }
            .background(vehicleManager.colorSchemeManager.backgroundColor)
            .navigationTitle("Speedometer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingMap) {
            RouteMapView(locationManager: locationManager, vehicleManager: vehicleManager)
        }
        .onAppear {
            print("SpeedometerView appeared")
            // Automatically start GPS tracking when speedometer is opened
            locationManager.startTrip()
            
            // Automatically start recording a trip if GPS is available
            if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if tripStartTime == nil {
                        print("Auto-starting trip recording...")
                        startTrip()
                    }
                }
            }
        }
        .onDisappear {
            // Don't stop GPS when leaving, let it continue recording
            // locationManager.endTrip()
            // gpsLive = false
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
        print("Starting trip recording...")
        tripStartTime = Date()
        tripDistance = 0
        maxSpeed = 0
        averageSpeed = 0
        
        // Create a new drive log for this trip
        guard let vehicle = vehicleManager.currentVehicle else { 
            print("No current vehicle found!")
            return 
        }
        
        currentDriveLog = DriveLog(
            vehicleId: vehicle.id,
            startTime: Date(),
            endTime: nil,
            startOdometer: vehicle.currentOdometer,
            endOdometer: nil,
            isActive: true,
            routePoints: []
        )
        
        // Add to vehicle manager
        if let driveLog = currentDriveLog {
            vehicleManager.driveLogs.append(driveLog)
            print("Drive log created with ID: \(driveLog.id)")
        }
        
        locationManager.startTrip()
    }
    
    private func endTrip() {
        print("Ending trip recording...")
        guard let driveLog = currentDriveLog else { 
            print("No current drive log found!")
            return 
        }
        
        // End the current drive log
        if let index = vehicleManager.driveLogs.firstIndex(where: { $0.id == driveLog.id }) {
            vehicleManager.driveLogs[index].endTime = Date()
            vehicleManager.driveLogs[index].endOdometer = vehicleManager.currentVehicle?.currentOdometer ?? 0
            vehicleManager.driveLogs[index].isActive = false
            vehicleManager.driveLogs[index].routePoints = locationManager.routePoints
            
            // Calculate and store the actual GPS distance
            let gpsDistance = locationManager.calculateDistance()
            vehicleManager.driveLogs[index].gpsDistance = gpsDistance
            
            print("Trip ended: \(locationManager.routePoints.count) route points, \(gpsDistance) miles")
        }
        
        // Update vehicle odometer with GPS distance instead of tripDistance
        if let vehicle = vehicleManager.currentVehicle {
            let distanceTraveled = locationManager.calculateDistance()
            if let vehicleIndex = vehicleManager.vehicles.firstIndex(where: { $0.id == vehicle.id }) {
                vehicleManager.vehicles[vehicleIndex].currentOdometer += distanceTraveled
                vehicleManager.currentVehicle = vehicleManager.vehicles[vehicleIndex]
            }
        }
        
        tripStartTime = nil
        currentDriveLog = nil
        locationManager.endTrip()
        
        // Save data
        vehicleManager.saveAllData()
        print("Trip data saved successfully")
    }
    
    private func updateTripStats(speed: Double?) {
        guard let speed = speed, tripStartTime != nil else { return }
        
        // Update max speed
        if speed > maxSpeed {
            maxSpeed = speed
        }
        
        // Update average speed (simplified calculation)
        averageSpeed = (averageSpeed + speed) / 2
        
        // Update distance based on GPS coordinates
        tripDistance = locationManager.calculateDistance()
    }
}

struct RouteMapView: View {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var vehicleManager: VehicleManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRoute: DriveLog? = nil
    @State private var showingRouteDetail = false
    @State private var routeToDelete: DriveLog? = nil
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Route list - optimized for performance
                List {
                    Section("Recent Routes") {
                        let currentVehicleRoutes = vehicleManager.driveLogs
                            .filter { $0.vehicleId == vehicleManager.currentVehicle?.id }
                            .sorted(by: { $0.startTime > $1.startTime })
                            .prefix(10) // Reduced from 15 to 10 for faster loading
                        
                        if currentVehicleRoutes.isEmpty {
                            Text("No recorded routes yet")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(Array(currentVehicleRoutes.enumerated()), id: \.element.id) { index, route in
                                RouteRow(route: route, index: index + 1)
                                    .onTapGesture {
                                        selectedRoute = route
                                        showingRouteDetail = true
                                    }
                            }
                            .onDelete(perform: deleteRoutes)
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Faster list style
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
        .sheet(isPresented: $showingRouteDetail) {
            if let route = selectedRoute {
                RouteDetailView(route: route, vehicleManager: vehicleManager)
            }
        }
        .alert("Delete Route", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let routeToDelete = routeToDelete {
                    deleteRoute(routeToDelete)
                }
            }
        } message: {
            Text("Are you sure you want to delete this route? This action cannot be undone.")
        }
    }
    
    private func deleteRoutes(offsets: IndexSet) {
        let currentVehicleRoutes = vehicleManager.driveLogs
            .filter { $0.vehicleId == vehicleManager.currentVehicle?.id }
            .sorted(by: { $0.startTime > $1.startTime })
            .prefix(15)
        
        let routesArray = Array(currentVehicleRoutes)
        if let index = offsets.first, index < routesArray.count {
            routeToDelete = routesArray[index]
            showingDeleteConfirmation = true
        }
    }
    
    private func deleteRoute(_ route: DriveLog) {
        if let index = vehicleManager.driveLogs.firstIndex(where: { $0.id == route.id }) {
            vehicleManager.driveLogs.remove(at: index)
            vehicleManager.saveAllData()
        }
        routeToDelete = nil
    }
}

struct RouteDetailView: View {
    let route: DriveLog
    let vehicleManager: VehicleManager
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    
    // Steve Jobs style speedometer color
    private var speedometerColor: Color {
        return .blue
    }
    
    init(route: DriveLog, vehicleManager: VehicleManager) {
        self.route = route
        self.vehicleManager = vehicleManager
        // Calculate region from route points - optimized for speed
        if !route.routePoints.isEmpty {
            let coordinates = route.routePoints.map { $0.coordinate }
            // Use a simpler region calculation for faster loading
            let center = coordinates[coordinates.count / 2]
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            self._region = State(initialValue: MKCoordinateRegion(center: center, span: span))
        } else {
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    

    
    var body: some View {
        NavigationView {
            VStack {
                // Always show the map view for debugging
                RouteMapViewRepresentable(route: route, region: $region)
                    .frame(height: 300)
                
                if route.routePoints.isEmpty {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 32))
                            .foregroundColor(.orange)
                        Text("No GPS route points recorded")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text("This route has no GPS tracking data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Route info
                VStack(spacing: 16) {
                    Text("Route Details")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 32) {
                        VStack(spacing: 8) {
                            Text("\(String(format: "%.1f", route.distance))")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Miles")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 8) {
                            Text(formatDuration(route.duration))
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Duration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 8) {
                            Text("\(route.routePoints.count)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("GPS Points")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let endTime = route.endTime {
                        Text("\(route.startTime, style: .date) • \(route.startTime, style: .time) - \(endTime, style: .time)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Route summary (simplified for performance)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Route Summary:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Points: \(route.routePoints.count) • Distance: \(String(format: "%.1f", route.distance)) mi")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Open in Apple Maps button
                    if !route.routePoints.isEmpty {
                        Button(action: {
                            openInAppleMaps()
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Open in Apple Maps")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(speedometerColor)
                            .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationTitle("Route Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Simplified region calculation for faster loading
            if !route.routePoints.isEmpty {
                let coordinates = route.routePoints.map { $0.coordinate }
                let center = coordinates[coordinates.count / 2]
                region = MKCoordinateRegion(
                    center: center,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
    

    
    private func openInAppleMaps() {
        guard !route.routePoints.isEmpty else { return }
        
        // Create a map item for the route
        let mapItem = MKMapItem()
        mapItem.name = "Recorded Route"
        
        // Open in Apple Maps with the polyline
        let options: [String: Any] = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
            MKLaunchOptionsShowsTrafficKey: true
        ]
        
        // Try to open with the polyline first
        if let firstPoint = route.routePoints.first,
           let lastPoint = route.routePoints.last {
            let startPlacemark = MKPlacemark(coordinate: firstPoint.coordinate)
            let endPlacemark = MKPlacemark(coordinate: lastPoint.coordinate)
            
            let startItem = MKMapItem(placemark: startPlacemark)
            let endItem = MKMapItem(placemark: endPlacemark)
            
            MKMapItem.openMaps(with: [startItem, endItem], launchOptions: options)
        }
    }
    
    private func createPolylineFromRoute() -> MKPolyline {
        let coordinates = route.routePoints.map { $0.coordinate }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
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





struct RouteRow: View {
    let route: DriveLog
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatRouteDate(route.startTime))
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
                    Text("GPS Points")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(route.routePoints.count)")
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
    
    private func formatRouteDate(_ date: Date) -> String {
        // Use a cached formatter for better performance
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d h:mm"
        return formatter.string(from: date)
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
    @Published var routePoints: [RoutePoint] = []
    @Published var isTracking: Bool = false
    
    private var lastLocation: CLLocation?
    private var totalDistance: Double = 0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1 // Update every 1 meter for street-level accuracy
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation // Optimize for driving
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTrip() {
        print("Starting GPS trip tracking...")
        
        // Reset route tracking
        routePoints.removeAll()
        totalDistance = 0
        lastLocation = nil
        isTracking = true
        
        switch authorizationStatus {
        case .notDetermined:
            print("Requesting location permission...")
            requestLocationPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            print("Starting location updates...")
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied")
        @unknown default:
            break
        }
    }
    
    func endTrip() {
        print("Ending GPS trip tracking. Total points: \(routePoints.count), Total distance: \(calculateDistance()) miles")
        locationManager.stopUpdatingLocation()
        isTracking = false
        // Don't clear route points here, they should be saved to the drive log
    }
    
    func calculateDistance() -> Double {
        return totalDistance * 0.000621371 // Convert meters to miles
    }
    
    // Function to get interpolated route points for smoother display
    func getInterpolatedRoutePoints() -> [RoutePoint] {
        guard routePoints.count >= 2 else { return routePoints }
        
        var interpolatedPoints: [RoutePoint] = []
        
        for i in 0..<routePoints.count {
            interpolatedPoints.append(routePoints[i])
            
            // Add interpolated points between consecutive GPS readings
            if i < routePoints.count - 1 {
                let currentPoint = routePoints[i]
                let nextPoint = routePoints[i + 1]
                
                let distance = CLLocation(latitude: currentPoint.latitude, longitude: currentPoint.longitude)
                    .distance(from: CLLocation(latitude: nextPoint.latitude, longitude: nextPoint.longitude))
                
                // If points are far apart, add interpolated points
                if distance > 20 { // 20 meters threshold
                    let interpolationCount = Int(distance / 10) // Add point every 10 meters
                    
                    for j in 1..<interpolationCount {
                        let ratio = Double(j) / Double(interpolationCount)
                        
                        let interpolatedLat = currentPoint.latitude + (nextPoint.latitude - currentPoint.latitude) * ratio
                        let interpolatedLon = currentPoint.longitude + (nextPoint.longitude - currentPoint.longitude) * ratio
                        
                        let interpolatedPoint = RoutePoint(
                            latitude: interpolatedLat,
                            longitude: interpolatedLon,
                            timestamp: currentPoint.timestamp.addingTimeInterval(ratio * nextPoint.timestamp.timeIntervalSince(currentPoint.timestamp)),
                            speed: currentPoint.speed,
                            altitude: currentPoint.altitude
                        )
                        
                        interpolatedPoints.append(interpolatedPoint)
                    }
                }
            }
        }
        
        return interpolatedPoints
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update speed (convert from m/s to mph)
        currentSpeed = location.speed * 2.23694
        
        // Filter out low-quality GPS points
        guard location.horizontalAccuracy <= 10 else { 
            print("Skipping low accuracy GPS point: \(location.horizontalAccuracy)m")
            return 
        }
        
        // Calculate distance from last location
        if let previousLocation = lastLocation {
            let distance = location.distance(from: previousLocation)
            
            // Only add point if we've moved significantly or if it's been a while
            let timeSinceLastPoint = location.timestamp.timeIntervalSince(previousLocation.timestamp)
            let minDistance: Double = 5 // Minimum 5 meters between points
            let minTime: TimeInterval = 2 // Minimum 2 seconds between points
            
            if distance >= minDistance || timeSinceLastPoint >= minTime {
                totalDistance += distance
                addRoutePoint(location: location)
                self.lastLocation = location
            }
        } else {
            // First point - always add it
            addRoutePoint(location: location)
            self.lastLocation = location
        }
        
        // Update map region
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        // Debug print to verify route points are being recorded
        print("GPS Update: Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude), Speed: \(currentSpeed ?? 0) mph, Points: \(routePoints.count), Distance: \(calculateDistance()) miles, Accuracy: \(location.horizontalAccuracy)m")
    }
    
    private func addRoutePoint(location: CLLocation) {
        // Try to snap the point to the nearest road for better accuracy
        let routePoint = RoutePoint(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: location.timestamp,
            speed: currentSpeed,
            altitude: location.altitude
        )
        routePoints.append(routePoint)
        print("Added route point: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // If we have enough points, try to improve the route by snapping to roads
        if routePoints.count >= 3 {
            improveRouteAccuracy()
        }
    }
    
    private func improveRouteAccuracy() {
        // This function could be enhanced with MapKit's road matching
        // For now, we'll use basic filtering and smoothing
        guard routePoints.count >= 3 else { return }
        
        // Remove outliers (points that are too far from the expected path)
        var filteredPoints: [RoutePoint] = []
        
        for i in 0..<routePoints.count {
            if i == 0 || i == routePoints.count - 1 {
                // Keep first and last points
                filteredPoints.append(routePoints[i])
            } else {
                let prevPoint = routePoints[i - 1]
                let currentPoint = routePoints[i]
                let nextPoint = routePoints[i + 1]
                
                // Calculate expected position based on previous and next points
                let expectedLat = (prevPoint.latitude + nextPoint.latitude) / 2
                let expectedLon = (prevPoint.longitude + nextPoint.longitude) / 2
                
                let distance = CLLocation(latitude: currentPoint.latitude, longitude: currentPoint.longitude)
                    .distance(from: CLLocation(latitude: expectedLat, longitude: expectedLon))
                
                // If point is within reasonable distance of expected path, keep it
                if distance < 50 { // 50 meters threshold
                    filteredPoints.append(currentPoint)
                } else {
                    print("Removed outlier point: distance \(distance)m from expected path")
                }
            }
        }
        
        // Only replace if we didn't lose too many points
        if filteredPoints.count >= Int(Double(routePoints.count) * 0.8) {
            routePoints = filteredPoints
            print("Improved route accuracy: \(routePoints.count) points after filtering")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Location authorization changed to: \(status.rawValue)")
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if isTracking {
                print("Starting location updates after authorization change...")
                locationManager.startUpdatingLocation()
            }
        }
    }
}

// Extension to MKCoordinateRegion for creating region from coordinates
extension MKCoordinateRegion {
    init(coordinates: [CLLocationCoordinate2D]) {
        guard !coordinates.isEmpty else {
            self.init(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            return
        }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? 0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 0
        let minLon = coordinates.map { $0.longitude }.min() ?? 0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let latDelta = max(maxLat - minLat, 0.001) // Minimum 0.001 degree span
        let lonDelta = max(maxLon - minLon, 0.001) // Minimum 0.001 degree span
        
        let span = MKCoordinateSpan(
            latitudeDelta: latDelta * 1.2, // Add 20% padding
            longitudeDelta: lonDelta * 1.2
        )
        
        self.init(center: center, span: span)
    }
}



struct RouteMapViewRepresentable: UIViewRepresentable {
    let route: DriveLog
    @Binding var region: MKCoordinateRegion
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.showsCompass = true
        mapView.showsScale = true
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Clear existing overlays and annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        // Use original route points for faster loading, only interpolate if needed
        let coordinates: [CLLocationCoordinate2D]
        
        if route.routePoints.count > 50 {
            // For routes with many points, use every other point for faster rendering
            coordinates = stride(from: 0, to: route.routePoints.count, by: 2).map { route.routePoints[$0].coordinate }
        } else {
            // For shorter routes, use all points
            coordinates = route.routePoints.map { $0.coordinate }
        }
        
        if coordinates.count > 1 {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polyline)
        }
        
        // Add start and end markers
        if let firstPoint = route.routePoints.first {
            let startAnnotation = MKPointAnnotation()
            startAnnotation.coordinate = firstPoint.coordinate
            startAnnotation.title = "Start"
            mapView.addAnnotation(startAnnotation)
        }
        
        if let lastPoint = route.routePoints.last, route.routePoints.count > 1 {
            let endAnnotation = MKPointAnnotation()
            endAnnotation.coordinate = lastPoint.coordinate
            endAnnotation.title = "End"
            mapView.addAnnotation(endAnnotation)
        }
        
        // Set region
        mapView.setRegion(region, animated: false)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteMapViewRepresentable
        
        init(_ parent: RouteMapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                
                // Color the route based on speed (like Rever)
                // For now, use a consistent blue color
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 6
                renderer.lineCap = .round
                renderer.lineJoin = .round
                renderer.alpha = 0.8
                
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let identifier = "RouteAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            if annotation.title == "Start" {
                annotationView?.annotation = annotation
                (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .green
            } else if annotation.title == "End" {
                annotationView?.annotation = annotation
                (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .red
            }
            
            return annotationView
        }
    }
}

#Preview {
    SpeedometerView(vehicleManager: VehicleManager())
} 