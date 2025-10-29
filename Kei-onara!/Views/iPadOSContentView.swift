import SwiftUI

// MARK: - Dashboard View

struct iPadOSDashboardView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var showingSpeedometer: Bool
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 24) {
            // Today's Mileage
            iPadOSDashboardCard(
                title: "TODAY'S MILEAGE",
                value: "\(Int(vehicleManager.currentVehicle?.currentOdometer ?? 0))",
                unit: vehicleManager.settings.useMetric ? "km" : "mi",
                icon: "speedometer",
                color: .blue,
                vehicleManager: vehicleManager
            )
            
            // Current MPG
            iPadOSDashboardCard(
                title: "CURRENT MPG",
                value: String(format: "%.1f", vehicleManager.currentMPG()),
                unit: vehicleManager.settings.useMetric ? "km/L" : "MPG",
                icon: "chart.line.uptrend.xyaxis",
                color: .green,
                vehicleManager: vehicleManager
            )
            
            // Fuel Level
            iPadOSDashboardCard(
                title: "FUEL LEVEL",
                value: "75%",
                unit: "remaining",
                icon: "fuelpump.fill",
                color: .orange,
                vehicleManager: vehicleManager
            )
            
            // Maintenance Status
            iPadOSDashboardCard(
                title: "MAINTENANCE",
                value: "All Good",
                unit: "no alerts",
                icon: "checkmark.circle.fill",
                color: .green,
                vehicleManager: vehicleManager
            )
        }
        
        // Start Ride Button
        VStack(spacing: 20) {
            Button(action: { showingSpeedometer = true }) {
                HStack(spacing: 16) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                    Text("START RIDE")
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 40)
    }
}

struct iPadOSDashboardCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                    .tracking(1)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 36, weight: .thin))
                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                
                Text(unit)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(vehicleManager.colorSchemeManager.cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(vehicleManager.colorSchemeManager.cardBorderColor, lineWidth: 1)
                )
        )
        .shadow(color: vehicleManager.colorSchemeManager.isDarkMode ? .white.opacity(0.05) : .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Fuel View

struct iPadOSFuelView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var showingFuelEntry: Bool
    
    // Optimized computed properties
    private var recentFuelEntries: [FuelEntry] {
        Array(vehicleManager.fuelEntries.prefix(5))
    }
    
    private var fuelStats: (totalEntries: Int, averageMPG: Double, lastFillUp: Date?) {
        let entries = vehicleManager.fuelEntries
        let totalEntries = entries.count
        let averageMPG = entries.isEmpty ? 0 : entries.map { calculateMPG(for: $0) }.reduce(0, +) / Double(entries.count)
        let lastFillUp = entries.max(by: { $0.date < $1.date })?.date
        return (totalEntries, averageMPG, lastFillUp)
    }
    
    private func calculateMPG(for entry: FuelEntry) -> Double {
        // Find the previous fuel entry to calculate MPG
        let previousEntries = vehicleManager.fuelEntries
            .filter { $0.vehicleId == entry.vehicleId && $0.date < entry.date }
            .sorted { $0.date > $1.date }
        
        guard let previousEntry = previousEntries.first else { return 0 }
        
        let distance = entry.odometer - previousEntry.odometer
        let gallons = entry.gallons
        
        return distance > 0 && gallons > 0 ? distance / gallons : 0
    }
    
    private func calculateKPL(for entry: FuelEntry) -> Double {
        // Find the previous fuel entry to calculate km/L
        let previousEntries = vehicleManager.fuelEntries
            .filter { $0.vehicleId == entry.vehicleId && $0.date < entry.date }
            .sorted { $0.date > $1.date }
        
        guard let previousEntry = previousEntries.first else { return 0 }
        
        let distance = entry.odometer - previousEntry.odometer
        let liters = entry.liters
        
        return distance > 0 && liters > 0 ? distance / liters : 0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Statistics Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 24) {
                    iPadOSStatCard(
                        title: "Total Entries",
                        value: "\(fuelStats.totalEntries)",
                        icon: "fuelpump.fill",
                        color: .green,
                        vehicleManager: vehicleManager
                    )
                    
                    iPadOSStatCard(
                        title: "Average MPG",
                        value: String(format: "%.1f", fuelStats.averageMPG),
                        icon: "speedometer",
                        color: .blue,
                        vehicleManager: vehicleManager
                    )
                    
                    iPadOSStatCard(
                        title: "Last Fill-up",
                        value: fuelStats.lastFillUp?.formatted(date: .abbreviated, time: .omitted) ?? "None",
                        icon: "calendar",
                        color: .orange,
                        vehicleManager: vehicleManager
                    )
                }
                
                // Recent Fuel Entries
                VStack(spacing: 16) {
                    HStack {
                        Text("RECENT FUEL ENTRIES")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                        
                        Spacer()
                    }
                    
                    LazyVStack(spacing: 12) {
                        ForEach(recentFuelEntries, id: \.id) { entry in
                            iPadOSFuelEntryRow(entry: entry, vehicleManager: vehicleManager)
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
    }
}

struct iPadOSFuelEntryRow: View {
    let entry: FuelEntry
    @ObservedObject var vehicleManager: VehicleManager
    
    private func calculateMPG(for entry: FuelEntry) -> Double {
        // Find the previous fuel entry to calculate MPG
        let previousEntries = vehicleManager.fuelEntries
            .filter { $0.vehicleId == entry.vehicleId && $0.date < entry.date }
            .sorted { $0.date > $1.date }
        
        guard let previousEntry = previousEntries.first else { return 0 }
        
        let distance = entry.odometer - previousEntry.odometer
        let gallons = entry.gallons
        
        return distance > 0 && gallons > 0 ? distance / gallons : 0
    }
    
    private func calculateKPL(for entry: FuelEntry) -> Double {
        // Find the previous fuel entry to calculate km/L
        let previousEntries = vehicleManager.fuelEntries
            .filter { $0.vehicleId == entry.vehicleId && $0.date < entry.date }
            .sorted { $0.date > $1.date }
        
        guard let previousEntry = previousEntries.first else { return 0 }
        
        let distance = entry.odometer - previousEntry.odometer
        let liters = entry.liters
        
        return distance > 0 && liters > 0 ? distance / liters : 0
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "fuelpump.fill")
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                
                if vehicleManager.useMetricUnits {
                    Text(String(format: "%.1f L • %.0f km", entry.liters, entry.odometer))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                } else {
                    Text(String(format: "%.1f gal • %.0f mi", entry.gallons, entry.odometer * 0.621371))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", entry.totalCost))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                
                if vehicleManager.useMetricUnits {
                    let kpl = calculateKPL(for: entry)
                    Text(String(format: "%.1f km/L", kpl))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                } else {
                    let mpg = calculateMPG(for: entry)
                    Text(String(format: "%.1f MPG", mpg))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(vehicleManager.colorSchemeManager.cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(vehicleManager.colorSchemeManager.cardBorderColor, lineWidth: 1)
                )
        )
    }
}

// MARK: - Maintenance View

struct iPadOSMaintenanceView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var showingMaintenance: Bool
    
    // Optimized computed properties
    private var recentMaintenanceRecords: [MaintenanceRecord] {
        Array(vehicleManager.maintenanceRecords.prefix(5))
    }
    
    private var maintenanceStats: (totalRecords: Int, lastService: Date?, totalSpent: Double) {
        let records = vehicleManager.maintenanceRecords
        let totalRecords = records.count
        let lastService = records.max(by: { $0.date < $1.date })?.date
        let totalSpent = records.reduce(0) { $0 + ($1.cost ?? 0) }
        return (totalRecords, lastService, totalSpent)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Statistics Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 24) {
                    iPadOSStatCard(
                        title: "Total Records",
                        value: "\(maintenanceStats.totalRecords)",
                        icon: "wrench.and.screwdriver.fill",
                        color: .orange,
                        vehicleManager: vehicleManager
                    )
                    
                    iPadOSStatCard(
                        title: "Last Service",
                        value: maintenanceStats.lastService?.formatted(date: .abbreviated, time: .omitted) ?? "None",
                        icon: "calendar",
                        color: .blue,
                        vehicleManager: vehicleManager
                    )
                    
                    iPadOSStatCard(
                        title: "Total Spent",
                        value: String(format: "$%.0f", maintenanceStats.totalSpent),
                        icon: "dollarsign.circle.fill",
                        color: .red,
                        vehicleManager: vehicleManager
                    )
                }
                
                // Recent Maintenance Records
                VStack(spacing: 16) {
                    HStack {
                        Text("RECENT MAINTENANCE")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                        
                        Spacer()
                    }
                    
                    LazyVStack(spacing: 12) {
                        ForEach(recentMaintenanceRecords, id: \.id) { record in
                            iPadOSMaintenanceRow(record: record, vehicleManager: vehicleManager)
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
    }
}

struct iPadOSMaintenanceRow: View {
    let record: MaintenanceRecord
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 20))
                .foregroundColor(record.type.color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.type.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let cost = record.cost {
                    Text(String(format: "$%.2f", cost))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                } else {
                    Text("No cost")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                }
                
                Text(String(format: "%.0f %@", record.odometer, vehicleManager.settings.useMetric ? "km" : "mi"))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(vehicleManager.colorSchemeManager.cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(vehicleManager.colorSchemeManager.cardBorderColor, lineWidth: 1)
                )
        )
    }
}

// MARK: - Drive View

struct iPadOSDriveView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var showingSpeedometer: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Drive Statistics
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                iPadOSStatCard(
                    title: "TOTAL TRIPS",
                    value: "\(vehicleManager.driveLogs.count)",
                    icon: "location.fill",
                    color: .blue,
                    vehicleManager: vehicleManager
                )
                
                iPadOSStatCard(
                    title: "TOTAL MILES",
                    value: "\(Int(vehicleManager.driveLogs.reduce(0) { $0 + $1.distance }))",
                    unit: vehicleManager.settings.useMetric ? "km" : "mi",
                    icon: "speedometer",
                    color: .green,
                    vehicleManager: vehicleManager
                )
                
                iPadOSStatCard(
                    title: "AVERAGE SPEED",
                    value: String(format: "%.0f", vehicleManager.driveLogs.isEmpty ? 0 : vehicleManager.driveLogs.reduce(0) { $0 + ($1.distance / $1.duration * 3600) } / Double(vehicleManager.driveLogs.count)),
                    unit: vehicleManager.settings.useMetric ? "km/h" : "mph",
                    icon: "gauge",
                    color: .orange,
                    vehicleManager: vehicleManager
                )
            }
            
            // Start Ride Button
            Button(action: { showingSpeedometer = true }) {
                HStack(spacing: 16) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                    Text("START NEW RIDE")
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Expenses View

struct iPadOSExpensesView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var showingExpenseTracker: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Expense Statistics
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                iPadOSStatCard(
                    title: "TOTAL EXPENSES",
                    value: "$\(Int(totalExpenses))",
                    icon: "dollarsign.circle.fill",
                    color: .red,
                    vehicleManager: vehicleManager
                )
                
                iPadOSStatCard(
                    title: "FUEL COSTS",
                    value: "$\(Int(fuelCosts))",
                    icon: "fuelpump.fill",
                    color: .orange,
                    vehicleManager: vehicleManager
                )
                
                iPadOSStatCard(
                    title: "MAINTENANCE COSTS",
                    value: "$\(Int(maintenanceCosts))",
                    icon: "wrench.and.screwdriver.fill",
                    color: .blue,
                    vehicleManager: vehicleManager
                )
            }
            
            // Expense Breakdown Chart
            VStack(spacing: 16) {
                HStack {
                    Text("EXPENSE BREAKDOWN")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                    
                    Spacer()
                }
                
                // Simple expense breakdown
                VStack(spacing: 12) {
                    iPadOSExpenseRow(
                        title: "Fuel",
                        amount: fuelCosts,
                        percentage: totalExpenses > 0 ? (fuelCosts / totalExpenses) * 100 : 0,
                        color: .orange,
                        vehicleManager: vehicleManager
                    )
                    
                    iPadOSExpenseRow(
                        title: "Maintenance",
                        amount: maintenanceCosts,
                        percentage: totalExpenses > 0 ? (maintenanceCosts / totalExpenses) * 100 : 0,
                        color: .blue,
                        vehicleManager: vehicleManager
                    )
                }
            }
        }
    }
    
    private var totalExpenses: Double {
        fuelCosts + maintenanceCosts
    }
    
    private var fuelCosts: Double {
        vehicleManager.fuelEntries.reduce(0) { $0 + $1.totalCost }
    }
    
    private var maintenanceCosts: Double {
        vehicleManager.maintenanceRecords.compactMap { $0.cost }.reduce(0, +)
    }
}

struct iPadOSExpenseRow: View {
    let title: String
    let amount: Double
    let percentage: Double
    let color: Color
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                                    Text(String(format: "$%.2f", amount))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                
                                    Text(String(format: "%.1f%%", percentage))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(vehicleManager.colorSchemeManager.cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(vehicleManager.colorSchemeManager.cardBorderColor, lineWidth: 1)
                )
        )
    }
}

// MARK: - Stat Card

struct iPadOSStatCard: View {
    let title: String
    let value: String
    let unit: String?
    let icon: String
    let color: Color
    @ObservedObject var vehicleManager: VehicleManager
    
    init(title: String, value: String, unit: String? = nil, icon: String, color: Color, vehicleManager: VehicleManager) {
        self.title = title
        self.value = value
        self.unit = unit
        self.icon = icon
        self.color = color
        self.vehicleManager = vehicleManager
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                
                if let unit = unit {
                    Text(unit)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                }
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(vehicleManager.colorSchemeManager.cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(vehicleManager.colorSchemeManager.cardBorderColor, lineWidth: 1)
                )
        )
    }
}

#Preview {
    iPadOSDashboardView(vehicleManager: VehicleManager(), showingSpeedometer: .constant(false))
} 