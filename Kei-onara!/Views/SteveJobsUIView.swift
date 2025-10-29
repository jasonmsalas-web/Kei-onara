import SwiftUI

struct SteveJobsUIView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingFuelEntry = false
    @State private var showingMaintenance = false
    @State private var showingSpeedometer = false
    @State private var showingSettings = false
    @State private var showingExpenseTracker = false
    @State private var showingMascot = false
    
    // Steve Jobs UI State
    @State private var selectedTab = 0
    @State private var showingDetail = false
    @State private var selectedAction: String?
    @State private var isRideActive = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background - Dynamic color based on dark mode
                vehicleManager.colorSchemeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Content based on selected tab
                    TabView(selection: $selectedTab) {
                        // Dashboard Tab
                        SteveJobsDashboardView(vehicleManager: vehicleManager, showingSpeedometer: $showingSpeedometer, isRideActive: $isRideActive)
                            .tag(0)
                        
                        // Fuel Tab
                        SteveJobsFuelView(vehicleManager: vehicleManager, showingFuelEntry: $showingFuelEntry)
                            .tag(1)
                        
                        // Maintenance Tab
                        SteveJobsMaintenanceView(vehicleManager: vehicleManager, showingMaintenance: $showingMaintenance)
                            .tag(2)
                        
                        // Drive Tab
                        SteveJobsDriveView(vehicleManager: vehicleManager, showingSpeedometer: $showingSpeedometer, isRideActive: $isRideActive)
                            .tag(3)
                        
                        // Expenses Tab
                        SteveJobsExpensesView(vehicleManager: vehicleManager, showingExpenseTracker: $showingExpenseTracker)
                            .tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Custom Tab Bar - Apple-style thin-line icons
                    SteveJobsTabBar(selectedTab: $selectedTab, colorSchemeManager: vehicleManager.colorSchemeManager)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingFuelEntry) {
            FuelEntryView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingMaintenance) {
            MaintenanceView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingSpeedometer) {
            SpeedometerView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingExpenseTracker) {
            ExpenseTrackerView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingMascot) {
            MascotView()
        }

    }
    
    // MARK: - Custom Tab Bar
    private var steveJobsTabBar: some View {
        HStack(spacing: 0) {
            // 🏠 Dashboard
            SteveJobsTabButton(
                icon: "house",
                title: "Dashboard",
                isSelected: selectedTab == 0,
                colorSchemeManager: vehicleManager.colorSchemeManager
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 0
                }
            }
            
            // ⛽ Fuel
            SteveJobsTabButton(
                icon: "fuelpump",
                title: "Fuel",
                isSelected: selectedTab == 1,
                colorSchemeManager: vehicleManager.colorSchemeManager
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 1
                }
            }
            
            // 🚘 Maintenance
            SteveJobsTabButton(
                icon: "wrench.and.screwdriver",
                title: "Maintenance",
                isSelected: selectedTab == 2,
                colorSchemeManager: vehicleManager.colorSchemeManager
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 2
                }
            }
            
            // 🧭 Drive
            SteveJobsTabButton(
                icon: "location",
                title: "Drive",
                isSelected: selectedTab == 3,
                colorSchemeManager: vehicleManager.colorSchemeManager
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 3
                }
            }
            
            // ⚙️ Expenses
            SteveJobsTabButton(
                icon: "chart.bar",
                title: "Expenses",
                isSelected: selectedTab == 4,
                colorSchemeManager: vehicleManager.colorSchemeManager
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 4
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
        )
    }
    

    

    
    // MARK: - Helper Functions
    private func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Supporting Views

struct SteveJobsTabBar: View {
    @Binding var selectedTab: Int
    let colorSchemeManager: ColorSchemeManager
    
    var body: some View {
        HStack(spacing: 0) {
            SteveJobsTabButton(
                icon: "house",
                title: "Dashboard",
                isSelected: selectedTab == 0,
                colorSchemeManager: colorSchemeManager
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 0
                }
            }
            
            SteveJobsTabButton(
                icon: "fuelpump",
                title: "Fuel",
                isSelected: selectedTab == 1,
                colorSchemeManager: colorSchemeManager
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 1
                }
            }
            
            SteveJobsTabButton(
                icon: "wrench.and.screwdriver",
                title: "Maintenance",
                isSelected: selectedTab == 2,
                colorSchemeManager: colorSchemeManager
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 2
                }
            }
            
            SteveJobsTabButton(
                icon: "location",
                title: "Drive",
                isSelected: selectedTab == 3,
                colorSchemeManager: colorSchemeManager
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 3
                }
            }
            
            SteveJobsTabButton(
                icon: "chart.bar",
                title: "Expenses",
                isSelected: selectedTab == 4,
                colorSchemeManager: colorSchemeManager
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 4
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(colorSchemeManager.cardBackgroundColor)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
        )
    }
}

struct SteveJobsTabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let colorSchemeManager: ColorSchemeManager
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .light))
                    .foregroundColor(isSelected ? colorSchemeManager.primaryTextColor : colorSchemeManager.secondaryTextColor)
                
                Text(title)
                    .font(.system(size: 9, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? colorSchemeManager.primaryTextColor : colorSchemeManager.secondaryTextColor)
                    .tracking(0.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(isSelected ? colorSchemeManager.cardBackgroundColor.opacity(0.3) : Color.clear)
                    .cornerRadius(8)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SteveJobsGlassFuelGauge: View {
    let level: Double
    
    var body: some View {
        ZStack {
            // Glass background with more realistic texture
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.95),
                            Color.gray.opacity(0.05),
                            Color.white.opacity(0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.gray.opacity(0.2),
                                    Color.gray.opacity(0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                )
            
            // Fuel level indicator with glass effect
            HStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.blue
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 240 * level)
                
                Spacer()
            }
            .padding(3)
            
            // Gauge markings with glass reflection
            HStack(spacing: 0) {
                ForEach(0..<6) { i in
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 1.5, height: 24)
                    Spacer()
                }
            }
            .padding(.horizontal, 12)
            
            // Glass highlight
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
        }
        .frame(height: 48)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct SteveJobsLeatherCard<Content: View>: View {
    let content: Content
    @ObservedObject var vehicleManager: VehicleManager
    
    init(vehicleManager: VehicleManager, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.vehicleManager = vehicleManager
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                vehicleManager.colorSchemeManager.leatherBackgroundColor,
                                vehicleManager.colorSchemeManager.leatherBackgroundColor.opacity(0.8),
                                vehicleManager.colorSchemeManager.leatherBackgroundColor
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        vehicleManager.colorSchemeManager.leatherBorderColor,
                                        vehicleManager.colorSchemeManager.leatherBorderColor.opacity(0.8)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: vehicleManager.colorSchemeManager.isDarkMode ? .white.opacity(0.03) : .black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

struct MinimalStatusCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.black)
            
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

struct MinimalActivityRow: View {
    let title: String
    let subtitle: String
    let date: Date
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(date, style: .date)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

// MARK: - Steve Jobs Individual Tab Views

struct SteveJobsDashboardView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var showingSpeedometer: Bool
    @Binding var isRideActive: Bool
    @State private var showingSettings = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Settings button in top-right corner
                HStack {
                    Spacer()
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                // Hero Section - Today's mileage with skeuomorphic design
                VStack(spacing: 20) {
                    Text("TODAY'S MILEAGE")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                        .tracking(2)
                    
                    Text("\(Int(vehicleManager.currentVehicle?.currentOdometer ?? 0))")
                        .font(.system(size: 72, weight: .thin))
                        .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                    
                    Text("kilometers")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    vehicleManager.colorSchemeManager.cardBackgroundColor,
                                    vehicleManager.colorSchemeManager.secondaryBackgroundColor
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(vehicleManager.colorSchemeManager.cardBorderColor, lineWidth: 1)
                        )
                )
                
                // Current vehicle indicator
                if let vehicle = vehicleManager.currentVehicle {
                    VStack(spacing: 20) {
                        Text("CURRENT VEHICLE")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .tracking(2)
                        
                        SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                            VStack(spacing: 12) {
                                Image(systemName: "car.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                                
                                Text(vehicle.displayName)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                                
                                Text(vehicle.name)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                            }
                        }
                    }
                }
                
                // Maintenance status with leather texture
                VStack(spacing: 20) {
                    Text("MAINTENANCE STATUS")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .tracking(2)
                    
                    SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                            
                            Text("All Systems Normal")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                            
                            Text("No maintenance required")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                        }
                    }
                }
                
                // Centered "Start Ride" button - Apple-style
                VStack(spacing: 20) {
                    Text("READY TO DRIVE")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .tracking(2)
                    
                    Button(action: {
                        showingSpeedometer = true
                        isRideActive = true
                    }) {
                        VStack(spacing: 16) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                            
                            Text("START RIDE")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .tracking(1)
                        }
                        .frame(width: 140, height: 140)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue,
                                            Color.blue.opacity(0.8)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 40)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(vehicleManager: vehicleManager)
        }
    }
}

struct SteveJobsFuelView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var showingFuelEntry: Bool
    
    // Optimized computed properties
    private var recentFuelEntries: [FuelEntry] {
        Array(vehicleManager.fuelEntries.prefix(5))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Fuel efficiency with glass-style design
                VStack(spacing: 20) {
                    Text("FUEL EFFICIENCY")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .tracking(2)
                    
                    SteveJobsGlassEfficiency(mpg: 28.5, vehicleManager: vehicleManager)
                }
                
                // Recent fuel entries with leather texture
                VStack(spacing: 20) {
                    HStack {
                        Text("RECENT FILL-UPS")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .tracking(2)
                        
                        Spacer()
                        
                        Button("+ ADD FILL-UP") {
                            showingFuelEntry = true
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                        .tracking(1)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(recentFuelEntries, id: \.id) { entry in
                            SteveJobsFuelEntryRow(entry: entry, vehicleManager: vehicleManager)
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 40)
        }
    }
}

struct SteveJobsMaintenanceView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var showingMaintenance: Bool
    
    // Optimized computed properties
    private var recentMaintenanceRecords: [MaintenanceRecord] {
        Array(vehicleManager.maintenanceRecords.prefix(3))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Maintenance categories with card stack view
                VStack(spacing: 20) {
                    Text("MAINTENANCE")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .tracking(2)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                        SteveJobsMaintenanceCard(title: "Oil", icon: "drop.fill", color: .orange, status: "Good")
                        SteveJobsMaintenanceCard(title: "Brakes", icon: "exclamationmark.triangle.fill", color: .red, status: "Check")
                        SteveJobsMaintenanceCard(title: "Tires", icon: "circle.fill", color: .blue, status: "Good")
                        SteveJobsMaintenanceCard(title: "Battery", icon: "bolt.fill", color: .yellow, status: "Good")
                    }
                }
                
                // Recent maintenance with leather texture
                VStack(spacing: 20) {
                    HStack {
                        Text("RECENT SERVICES")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .tracking(2)
                        
                        Spacer()
                        
                        Button("+ ADD SERVICE") {
                            showingMaintenance = true
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                        .tracking(1)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(recentMaintenanceRecords, id: \.id) { record in
                            SteveJobsMaintenanceRow(record: record)
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 40)
        }
    }
}

struct SteveJobsDriveView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var showingSpeedometer: Bool
    @Binding var isRideActive: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            // Glass-style speedometer
            VStack(spacing: 20) {
                Text("SPEEDOMETER")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .tracking(2)
                
                SteveJobsGlassSpeedometer(speed: 65)
            }
            
            // Start/Stop button with Apple-style design
            VStack(spacing: 20) {
                Text("GPS TRACKING")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .tracking(2)
                
                Button(action: {
                    showingSpeedometer = true
                    isRideActive.toggle()
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: isRideActive ? "pause.fill" : "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Text(isRideActive ? "PAUSE" : "START TRACKING")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .tracking(1)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue,
                                        Color.blue.opacity(0.8)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
    }
}

struct SteveJobsExpensesView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var showingExpenseTracker: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Cost breakdown with Apple-style design
                VStack(spacing: 20) {
                    Text("EXPENSES")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .tracking(2)
                    
                    let fuelCost = vehicleManager.totalFuelCost()
                    let maintenanceCost = vehicleManager.totalMaintenanceCost()
                    let totalCost = fuelCost + maintenanceCost
                    let fuelPercentage = totalCost > 0 ? (fuelCost / totalCost) * 100 : 0
                    let maintenancePercentage = totalCost > 0 ? (maintenanceCost / totalCost) * 100 : 0
                    
                    SteveJobsGlassCard {
                        VStack(spacing: 16) {
                            SteveJobsExpenseRow(title: "Fuel", amount: fuelCost, percentage: fuelPercentage, color: .green)
                            SteveJobsExpenseRow(title: "Maintenance", amount: maintenanceCost, percentage: maintenancePercentage, color: .blue)
                            SteveJobsExpenseRow(title: "Total", amount: totalCost, percentage: 100, color: .black)
                        }
                        .padding(.vertical, 24)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 40)
        }
    }
}



// MARK: - Additional Supporting Views

struct SteveJobsFuelEntryRow: View {
    let entry: FuelEntry
    let vehicleManager: VehicleManager
    
    var body: some View {
        HStack(spacing: 20) {
            // Fuel icon with glass effect
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "fuelpump.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if vehicleManager.useMetricUnits {
                    Text("\(String(format: "%.1f", entry.liters))L")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                } else {
                    Text("\(String(format: "%.1f", entry.gallons))gal")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
                
                if vehicleManager.useMetricUnits {
                    Text("\(String(format: "%.0f", entry.odometer))km")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                } else {
                    Text("\(String(format: "%.0f", entry.odometer * 0.621371))mi")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", entry.totalCost))")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                Text(entry.date, style: .date)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                )
        )
    }
}

struct SteveJobsGlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.9),
                                Color.gray.opacity(0.02),
                                Color.white.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.gray.opacity(0.15),
                                        Color.gray.opacity(0.05)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.02), radius: 8, x: 0, y: 2)
    }
}

struct MaintenanceCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

struct SteveJobsGlassEfficiency: View {
    let mpg: Double
    let vehicleManager: VehicleManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Glass effect background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.7),
                            Color.white.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.gray.opacity(0.3),
                                    Color.gray.opacity(0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 12) {
                // Efficiency icon
                Image(systemName: "leaf.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                // Efficiency value
                if vehicleManager.useMetricUnits {
                    let kml = mpg * 0.425144 // Convert MPG to km/l
                    Text("\(String(format: "%.1f", kml))")
                        .font(.system(size: 32, weight: .thin))
                        .foregroundColor(.black)
                } else {
                    Text("\(Int(mpg))")
                        .font(.system(size: 32, weight: .thin))
                        .foregroundColor(.black)
                }
                
                // Efficiency label
                if vehicleManager.useMetricUnits {
                    Text("KM/L")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .tracking(2)
                } else {
                    Text("MPG")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .tracking(2)
                }
            }
            .padding(.vertical, 20)
        }
    }
}

struct SteveJobsGlassSpeedometer: View {
    let speed: Int
    
    var body: some View {
        ZStack {
            // Glass background with realistic texture
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.95),
                            Color.gray.opacity(0.02),
                            Color.white.opacity(0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.gray.opacity(0.2),
                                    Color.gray.opacity(0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2.5
                        )
                )
            
            // Speed display with glass effect
            VStack(spacing: 12) {
                Text("\(speed)")
                    .font(.system(size: 64, weight: .thin))
                    .foregroundColor(.black)
                
                Text("MPH")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(.gray)
                    .tracking(1)
            }
            
            // Glass highlight
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.4),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
        }
        .frame(width: 240, height: 240)
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
}

struct SteveJobsMaintenanceCard: View {
    let title: String
    let icon: String
    let color: Color
    let status: String
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Text(status)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                )
        )
    }
}

struct SteveJobsMaintenanceRow: View {
    let record: MaintenanceRecord
    
    var body: some View {
        HStack(spacing: 20) {
            // Maintenance icon with glass effect
            ZStack {
                Circle()
                    .fill(record.type.color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: record.type.icon)
                    .font(.system(size: 16))
                    .foregroundColor(record.type.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.type.rawValue)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                Text("\(String(format: "%.0f", record.odometer))km")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let cost = record.cost {
                    Text("$\(String(format: "%.2f", cost))")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                } else {
                    Text("No cost")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Text(record.date, style: .date)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                )
        )
    }
}

struct SteveJobsExpenseRow: View {
    let title: String
    let amount: Double
    let percentage: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(String(format: "%.2f", amount))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Text("\(String(format: "%.1f", percentage))%")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}



#Preview {
    SteveJobsUIView(vehicleManager: VehicleManager())
} 