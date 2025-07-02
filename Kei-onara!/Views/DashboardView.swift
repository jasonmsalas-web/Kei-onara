import SwiftUI

struct DashboardView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @State private var showingFuelEntry = false
    @State private var showingMaintenance = false
    @State private var showingSettings = false
    @State private var showingSpeedometer = false
    @State private var showingExpenseTracker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: scale(24, grandmaMode: vehicleManager.settings.grandmaMode)) {
                    // Header with vehicle info
                    vehicleHeader
                    
                    // Health Status
                    healthStatusCard
                    
                    // MPG Dashboard
                    mpgDashboard
                    
                    // Giant Action Buttons
                    actionButtons
                    
                    // Quick Stats
                    quickStats
                    
                    // Maintenance Alerts
                    maintenanceAlerts
                }
                .padding(scale(16, grandmaMode: vehicleManager.settings.grandmaMode))
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Kei-Onara! Home")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: scaledFontSize(28, grandmaMode: vehicleManager.settings.grandmaMode)))
                    }
                }
            }
        }
        .sheet(isPresented: $showingFuelEntry) {
            FuelEntryView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingMaintenance) {
            MaintenanceView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingSpeedometer) {
            SpeedometerView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingExpenseTracker) {
            ExpenseTrackerView(vehicleManager: vehicleManager)
        }
    }
    
    private var vehicleHeader: some View {
        VStack(spacing: scale(6, grandmaMode: vehicleManager.settings.grandmaMode)) {
            if let vehicle = vehicleManager.currentVehicle {
                VStack(alignment: .center, spacing: scale(2, grandmaMode: vehicleManager.settings.grandmaMode)) {
                    HStack(spacing: 12) {
                        if let photoData = vehicle.photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        }
                        Text(vehicle.displayName)
                            .font(.system(size: scaledFontSize(36, grandmaMode: vehicleManager.settings.grandmaMode), weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    Text(vehicle.name)
                        .font(.system(size: scaledFontSize(18, grandmaMode: vehicleManager.settings.grandmaMode)))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                if vehicleManager.vehicles.count > 1 {
                    Menu {
                        ForEach(vehicleManager.vehicles) { vehicle in
                            Button(vehicle.displayName) {
                                vehicleManager.switchToVehicle(vehicle)
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.system(size: scaledFontSize(22, grandmaMode: vehicleManager.settings.grandmaMode)))
                            .foregroundColor(.blue)
                    }
                }
                Text("\(Int(vehicle.currentOdometer)) km")
                    .font(.system(size: scaledFontSize(22, grandmaMode: vehicleManager.settings.grandmaMode)))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(scale(16, grandmaMode: vehicleManager.settings.grandmaMode))
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var healthStatusCard: some View {
        VStack(spacing: scale(12, grandmaMode: vehicleManager.settings.grandmaMode)) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: scaledFontSize(28, grandmaMode: vehicleManager.settings.grandmaMode)))
                    .foregroundColor(.green)
                
                Text("All Good!")
                    .font(.system(size: scaledFontSize(22, grandmaMode: vehicleManager.settings.grandmaMode)))
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Spacer()
            }
            
            Text("Your Kei truck is running smoothly")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(scale(16, grandmaMode: vehicleManager.settings.grandmaMode))
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var mpgDashboard: some View {
        VStack(spacing: scale(16, grandmaMode: vehicleManager.settings.grandmaMode)) {
            Text("Fuel Efficiency")
                .font(.system(size: scaledFontSize(22, grandmaMode: vehicleManager.settings.grandmaMode)))
                .fontWeight(.semibold)
            
            HStack(spacing: scale(24, grandmaMode: vehicleManager.settings.grandmaMode)) {
                VStack(spacing: scale(8, grandmaMode: vehicleManager.settings.grandmaMode)) {
                    Text("\(String(format: "%.1f", vehicleManager.currentMPG()))")
                        .font(.system(size: scaledFontSize(36, grandmaMode: vehicleManager.settings.grandmaMode), weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("Current MPG")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: scale(8, grandmaMode: vehicleManager.settings.grandmaMode)) {
                    Text("\(String(format: "%.1f", vehicleManager.averageMPG()))")
                        .font(.system(size: scaledFontSize(36, grandmaMode: vehicleManager.settings.grandmaMode), weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Text("Average MPG")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(scale(16, grandmaMode: vehicleManager.settings.grandmaMode))
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var actionButtons: some View {
        VStack(spacing: scale(16, grandmaMode: vehicleManager.settings.grandmaMode)) {
            // Action Buttons
            HStack(spacing: scale(12, grandmaMode: vehicleManager.settings.grandmaMode)) {
                Button(action: { showingFuelEntry = true }) {
                    VStack(spacing: scale(8, grandmaMode: vehicleManager.settings.grandmaMode)) {
                        Image(systemName: "fuelpump.fill")
                            .font(.system(size: scaledFontSize(36, grandmaMode: vehicleManager.settings.grandmaMode)))
                        Text("Add Fuel")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(scale(24, grandmaMode: vehicleManager.settings.grandmaMode))
                    .background(buttonColors[0])
                    .cornerRadius(scale(24, grandmaMode: vehicleManager.settings.grandmaMode))
                }
                
                Button(action: { showingMaintenance = true }) {
                    VStack(spacing: scale(8, grandmaMode: vehicleManager.settings.grandmaMode)) {
                        Image(systemName: "wrench.fill")
                            .font(.system(size: scaledFontSize(36, grandmaMode: vehicleManager.settings.grandmaMode)))
                        Text("Maintenance")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(scale(24, grandmaMode: vehicleManager.settings.grandmaMode))
                    .background(buttonColors[1])
                    .cornerRadius(scale(24, grandmaMode: vehicleManager.settings.grandmaMode))
                }
            }
            
            // Speedometer and Expenses Buttons
            HStack(spacing: scale(12, grandmaMode: vehicleManager.settings.grandmaMode)) {
                Button(action: { showingSpeedometer = true }) {
                    VStack(spacing: scale(8, grandmaMode: vehicleManager.settings.grandmaMode)) {
                        Image(systemName: "speedometer")
                            .font(.system(size: scaledFontSize(36, grandmaMode: vehicleManager.settings.grandmaMode)))
                        Text("Speedometer")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(scale(24, grandmaMode: vehicleManager.settings.grandmaMode))
                    .background(buttonColors[2])
                    .cornerRadius(scale(24, grandmaMode: vehicleManager.settings.grandmaMode))
                }
                
                Button(action: { showingExpenseTracker = true }) {
                    VStack(spacing: scale(8, grandmaMode: vehicleManager.settings.grandmaMode)) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: scaledFontSize(36, grandmaMode: vehicleManager.settings.grandmaMode)))
                        Text("Expenses")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(scale(24, grandmaMode: vehicleManager.settings.grandmaMode))
                    .background(buttonColors[3])
                    .cornerRadius(scale(24, grandmaMode: vehicleManager.settings.grandmaMode))
                }
            }
        }
    }
    
    private var quickStats: some View {
        VStack(spacing: scale(16, grandmaMode: vehicleManager.settings.grandmaMode)) {
            Text("Quick Stats")
                .font(.system(size: scaledFontSize(22, grandmaMode: vehicleManager.settings.grandmaMode)))
                .fontWeight(.semibold)
            
            HStack(spacing: scale(16, grandmaMode: vehicleManager.settings.grandmaMode)) {
                StatCard(
                    title: "Total Fuel Cost",
                    value: "$\(String(format: "%.2f", vehicleManager.totalFuelCost()))",
                    icon: "dollarsign.circle.fill",
                    color: .orange,
                    grandmaMode: vehicleManager.settings.grandmaMode
                )
                
                StatCard(
                    title: "Maintenance Cost",
                    value: "$\(String(format: "%.2f", vehicleManager.totalMaintenanceCost()))",
                    icon: "wrench.and.screwdriver.fill",
                    color: .purple,
                    grandmaMode: vehicleManager.settings.grandmaMode
                )
            }
        }
        .padding(scale(16, grandmaMode: vehicleManager.settings.grandmaMode))
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var maintenanceAlerts: some View {
        VStack(alignment: .leading, spacing: scale(12, grandmaMode: vehicleManager.settings.grandmaMode)) {
            Text("Maintenance Alerts")
                .font(.system(size: scaledFontSize(22, grandmaMode: vehicleManager.settings.grandmaMode)))
                .fontWeight(.semibold)
            
            let currentOdometer = vehicleManager.currentVehicle?.currentOdometer ?? 0
            let currentVehicleId = vehicleManager.currentVehicle?.id
            let overdueRecords = vehicleManager.maintenanceRecords.filter { 
                $0.vehicleId == currentVehicleId && 
                $0.reminderEnabled && 
                $0.isOverdue(currentOdometer: currentOdometer) 
            }
            let upcomingRecords = vehicleManager.maintenanceRecords.filter { 
                $0.vehicleId == currentVehicleId && 
                $0.reminderEnabled && 
                !$0.isOverdue(currentOdometer: currentOdometer) 
            }
            
            if overdueRecords.isEmpty && upcomingRecords.isEmpty {
                Text("No maintenance alerts")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                if !overdueRecords.isEmpty {
                    Text("Overdue")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.bottom, 2)
                    ForEach(overdueRecords.prefix(3)) { record in
                        HStack {
                            Image(systemName: record.type.icon)
                                .foregroundColor(.red)
                            VStack(alignment: .leading) {
                                Text(record.type.rawValue)
                                    .fontWeight(.medium)
                                Text("Due at \(Int(record.nextDueOdometer ?? 0)) km")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(Int(record.odometer)) km")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(scale(4, grandmaMode: vehicleManager.settings.grandmaMode))
                    }
                }
                if !upcomingRecords.isEmpty {
                    Text("Upcoming")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.top, 4)
                    ForEach(upcomingRecords.prefix(3)) { record in
                        HStack {
                            Image(systemName: record.type.icon)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(record.type.rawValue)
                                    .fontWeight(.medium)
                                Text("Due at \(Int(record.nextDueOdometer ?? 0)) km")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(Int(record.odometer)) km")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(scale(4, grandmaMode: vehicleManager.settings.grandmaMode))
                    }
                }
            }
        }
        .padding(scale(16, grandmaMode: vehicleManager.settings.grandmaMode))
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // Button color palette based on settings
    private var buttonColors: [Color] {
        switch vehicleManager.settings.buttonPalette {
        case .default:
            return [
                .green,    // Add Fuel
                .purple,   // Maintenance
                .indigo,   // Speedometer
                .teal      // Expenses
            ]
        case .risingSun:
            return [
                Color(red:0.90, green:0.0, blue:0.15), // Add Fuel (Red)
                .black,                                // Maintenance
                Color(red:0.10, green:0.14, blue:0.49),// Speedometer (Navy)
                Color(red:0.90, green:0.0, blue:0.15)  // Expenses (Red)
            ]
        case .blueHue:
            return [
                Color(red:0.31, green:0.76, blue:0.97), // Add Fuel (Light Blue)
                Color(red:0.0, green:0.59, blue:0.65),  // Maintenance (Teal)
                Color(red:0.25, green:0.32, blue:0.71), // Speedometer (Indigo)
                Color(red:0.10, green:0.46, blue:0.82)  // Expenses (Blue)
            ]
        case .greenHue:
            return [
                Color(red:0.55, green:0.77, blue:0.29), // Add Fuel (Olive)
                Color(red:0.0, green:0.59, blue:0.53),  // Maintenance (Teal)
                Color(red:0.18, green:0.49, blue:0.20), // Speedometer (Forest)
                Color(red:0.22, green:0.56, blue:0.24)  // Expenses (Green)
            ]
        case .red:
            return [
                Color(red:0.90, green:0.0, blue:0.15), // Add Fuel (Red)
                Color(red:0.80, green:0.0, blue:0.0),  // Maintenance (Dark Red)
                Color(red:0.70, green:0.0, blue:0.0),  // Speedometer (Darker Red)
                Color(red:0.60, green:0.0, blue:0.0)   // Expenses (Darkest Red)
            ]
        case .orange:
            return [
                Color(red:1.0, green:0.55, blue:0.0),  // Add Fuel (Orange)
                Color(red:1.0, green:0.45, blue:0.0),  // Maintenance (Dark Orange)
                Color(red:1.0, green:0.35, blue:0.0),  // Speedometer (Darker Orange)
                Color(red:1.0, green:0.25, blue:0.0)   // Expenses (Darkest Orange)
            ]
        case .yellow:
            return [
                Color(red:1.0, green:0.95, blue:0.0),  // Add Fuel (Yellow)
                Color(red:1.0, green:0.85, blue:0.0),  // Maintenance (Dark Yellow)
                Color(red:1.0, green:0.75, blue:0.0),  // Speedometer (Darker Yellow)
                Color(red:1.0, green:0.65, blue:0.0)   // Expenses (Darkest Yellow)
            ]
        case .indigo:
            return [
                Color(red:0.25, green:0.32, blue:0.71), // Add Fuel (Indigo)
                Color(red:0.20, green:0.25, blue:0.60), // Maintenance (Dark Indigo)
                Color(red:0.15, green:0.18, blue:0.50), // Speedometer (Darker Indigo)
                Color(red:0.10, green:0.12, blue:0.40)  // Expenses (Darkest Indigo)
            ]
        case .violet:
            return [
                Color(red:0.56, green:0.0, blue:1.0),   // Add Fuel (Violet)
                Color(red:0.50, green:0.0, blue:0.90),  // Maintenance (Dark Violet)
                Color(red:0.44, green:0.0, blue:0.80),  // Speedometer (Darker Violet)
                Color(red:0.38, green:0.0, blue:0.70)   // Expenses (Darkest Violet)
            ]
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let grandmaMode: Bool
    
    var body: some View {
        VStack(spacing: scale(8, grandmaMode: grandmaMode)) {
            Image(systemName: icon)
                .font(.system(size: scaledFontSize(28, grandmaMode: grandmaMode)))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: scaledFontSize(22, grandmaMode: grandmaMode)))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(scale(16, grandmaMode: grandmaMode))
        .background(Color(.systemGray6))
        .cornerRadius(scale(12, grandmaMode: grandmaMode))
    }
}

// Helper to scale values based on grandma mode
fileprivate func scale(_ value: CGFloat, grandmaMode: Bool) -> CGFloat {
    grandmaMode ? value : value * 0.8
}

// Helper to scale font sizes for .system(size:) only
fileprivate func scaledFontSize(_ base: CGFloat, grandmaMode: Bool) -> CGFloat {
    grandmaMode ? base : base * 0.8
}

#Preview {
    DashboardView(vehicleManager: VehicleManager())
} 