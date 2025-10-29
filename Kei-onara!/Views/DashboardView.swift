import SwiftUI

struct DashboardView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @StateObject private var speechManager = SpeechManager()
    @State private var showingFuelEntry = false
    @State private var showingMaintenance = false
    @State private var showingSettings = false
    @State private var showingSpeedometer = false
    @State private var showingExpenseTracker = false
    @State private var showingMaintenanceDetail = false
    @State private var selectedMaintenanceRecord: MaintenanceRecord? = nil

    
    // Get CarPlay manager from app delegate
    private var carPlayManager: CarPlayManager? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.carPlayManager
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
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
                    
                    // Today's Mileage
                    todaysMileageCard
                    
                    // Maintenance Alerts
                    maintenanceAlerts
                }
                .padding(14)
            }
            .background(vehicleManager.colorSchemeManager.backgroundColor)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Kei-Onara!")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                        
                        // CarPlay indicator
                        if carPlayManager?.isCarPlayConnected() == true {
                            Image(systemName: "car.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 17))
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
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

        .sheet(isPresented: $showingMaintenanceDetail) {
            if let record = selectedMaintenanceRecord {
                NavigationView {
                    MaintenanceDetailView(record: record, vehicleManager: vehicleManager)
                }
            }
        }
    }
    
    private var vehicleHeader: some View {
        VStack(spacing: 5) {
            if let vehicle = vehicleManager.currentVehicle {
                VStack(alignment: .center, spacing: 2) {
                    HStack(spacing: 12) {
                        if let photoData = vehicle.photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 68, height: 68)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        }
                        Text(vehicle.displayName)
                            .font(.system(size: 31, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    Text(vehicle.name)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                
                // Vehicle selector menu
                Group {
                    if vehicleManager.vehicles.count > 1 {
                                                Menu {
                            ForEach(vehicleManager.vehicles) { vehicleItem in
                                Button(vehicleItem.displayName) {
                                    vehicleManager.setCurrentVehicle(vehicleItem)
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.system(size: 19))
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Odometer in km and miles
                let km = vehicle.currentOdometer
                let miles = km * 0.621371
                VStack(spacing: 2) {
                    Text("\(Int(km)) km  |  \(String(format: "%.1f", miles)) mi")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    
                    if let vin = vehicle.vin, !vin.isEmpty {
                        Text("VIN: \(vin)")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .padding(14)
        .background(vehicleManager.colorSchemeManager.cardBackgroundColor)
        .cornerRadius(14)
    }
    
    private var healthStatusCard: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                Text("All Good!")
                    .font(.system(size: 19))
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Spacer()
            }
            
            Text("Your Kei truck is running smoothly")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(14)
        .background(vehicleManager.colorSchemeManager.cardBackgroundColor)
        .cornerRadius(14)
    }
    
    private var mpgDashboard: some View {
        VStack(spacing: 14) {
            Text("Fuel Efficiency")
                .font(.system(size: 19))
                .fontWeight(.semibold)
            let currentMPG = vehicleManager.currentMPG()
            let averageMPG = vehicleManager.currentMPG() // Using currentMPG as average for now
            let currentKPL = currentMPG > 0 ? (currentMPG * 0.425144) : 0 // 1 mpg = 0.425144 km/l
            let averageKPL = averageMPG > 0 ? (averageMPG * 0.425144) : 0
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    if vehicleManager.useMetricUnits {
                        Text("\(String(format: "%.1f", currentKPL)) km/l")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        Text("\(String(format: "%.1f", currentMPG)) mpg")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(String(format: "%.1f", currentMPG)) mpg")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        Text("\(String(format: "%.2f", currentKPL)) km/l")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("Current")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                VStack(spacing: 8) {
                    if vehicleManager.useMetricUnits {
                        Text("\(String(format: "%.1f", averageKPL)) km/l")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                        Text("\(String(format: "%.1f", averageMPG)) mpg")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(String(format: "%.1f", averageMPG)) mpg")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                        Text("\(String(format: "%.2f", averageKPL)) km/l")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("Average")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .background(vehicleManager.colorSchemeManager.cardBackgroundColor)
        .cornerRadius(14)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 14) {
            // Action Buttons
            HStack(spacing: 10) {
                Button(action: { showingFuelEntry = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "fuelpump.fill")
                            .font(.system(size: 31))
                        Text("Add Fuel")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(steveJobsButtonColors[0])
                    .cornerRadius(20)
                }
                
                Button(action: { showingMaintenance = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "wrench.fill")
                            .font(.system(size: 31))
                        Text("Maintenance")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(steveJobsButtonColors[1])
                    .cornerRadius(20)
                }
            }
            
            // Speedometer and Expenses Buttons
            HStack(spacing: 10) {
                Button(action: { showingSpeedometer = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "speedometer")
                            .font(.system(size: 31))
                        Text("Speedometer")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(steveJobsButtonColors[2])
                    .cornerRadius(20)
                }
                
                Button(action: { showingExpenseTracker = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 31))
                        Text("Expenses")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(steveJobsButtonColors[3])
                    .cornerRadius(20)
                }
            }
        }
    }
    
    private var quickStats: some View {
        VStack(spacing: 14) {
            Text("Quick Stats")
                .font(.system(size: 19))
                .fontWeight(.semibold)
            
            HStack(spacing: 14) {
                StatCard(
                    title: "Total Fuel Cost",
                    value: "$\(String(format: "%.2f", vehicleManager.totalFuelCost()))",
                    icon: "dollarsign.circle.fill",
                    color: .orange,
                    colorSchemeManager: vehicleManager.colorSchemeManager
                )
                
                StatCard(
                    title: "Maintenance Cost",
                    value: "$\(String(format: "%.2f", vehicleManager.totalMaintenanceCost()))",
                    icon: "wrench.and.screwdriver.fill",
                    color: .purple,
                    colorSchemeManager: vehicleManager.colorSchemeManager
                )
            }
        }
        .padding(14)
        .background(vehicleManager.colorSchemeManager.cardBackgroundColor)
        .cornerRadius(14)
    }
    
    private var todaysMileageCard: some View {
        VStack(spacing: 14) {
            Text("Today's Mileage")
                .font(.system(size: 19))
                .fontWeight(.semibold)
            
            let todaysMileage = vehicleManager.todaysMileage()
            let todaysMileageKm = todaysMileage
            let todaysMileageMiles = todaysMileage * 0.621371
            
            VStack(spacing: 8) {
                if vehicleManager.useMetricUnits {
                    Text("\(Int(todaysMileageKm)) km")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("\(String(format: "%.1f", todaysMileageMiles)) mi")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                } else {
                    Text("\(String(format: "%.1f", todaysMileageMiles)) mi")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("\(Int(todaysMileageKm)) km")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .background(vehicleManager.colorSchemeManager.cardBackgroundColor)
        .cornerRadius(14)
    }
    
    private var maintenanceAlerts: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Maintenance Alerts")
                .font(.system(size: 19))
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
                        Button(action: {
                            selectedMaintenanceRecord = record
                            showingMaintenanceDetail = true
                        }) {
                            HStack {
                                Image(systemName: record.type.icon)
                                    .foregroundColor(.red)
                                VStack(alignment: .leading) {
                                    Text(record.type.rawValue)
                                        .fontWeight(.medium)
                                    if vehicleManager.useMetricUnits {
                                        Text("Due at \(Int(record.nextDueOdometer ?? 0)) km")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("Due at \(Int((record.nextDueOdometer ?? 0) * 0.621371)) mi")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    if vehicleManager.useMetricUnits {
                                        Text("\(Int(record.odometer)) km")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("\(Int(record.odometer * 0.621371)) mi")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
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
                                if vehicleManager.useMetricUnits {
                                    Text("Due at \(Int(record.nextDueOdometer ?? 0)) km")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Due at \(Int((record.nextDueOdometer ?? 0) * 0.621371)) mi")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            if vehicleManager.useMetricUnits {
                                Text("\(Int(record.odometer)) km")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("\(Int(record.odometer * 0.621371)) mi")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(4)
                    }
                }
            }
        }
        .padding(16)
        .background(vehicleManager.colorSchemeManager.cardBackgroundColor)
        .cornerRadius(16)
    }
    
    // Steve Jobs style button colors
    private var steveJobsButtonColors: [Color] {
        return [
            .blue,      // Add Fuel
            .blue,      // Maintenance
            .blue,      // Speedometer
            .blue       // Expenses
        ]
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let colorSchemeManager: ColorSchemeManager
    
    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 19))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(colorSchemeManager.cardBackgroundColor)
        .cornerRadius(10)
    }
}



#Preview {
    DashboardView(vehicleManager: VehicleManager())
}

struct MaintenanceDetailView: View {
    let record: MaintenanceRecord
    @ObservedObject var vehicleManager: VehicleManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with type and status
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: record.type.icon)
                                .font(.title)
                                .foregroundColor(.red)
                            
                            Text(record.type.rawValue)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("OVERDUE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Text("Maintenance Record Details")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(vehicleManager.colorSchemeManager.cardBackgroundColor)
                    .cornerRadius(12)
                    
                    // Basic Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Basic Information")
                            .font(.headline)
                        
                        DetailRow(title: "Date", value: record.date.formatted(date: .long, time: .omitted))
                        if vehicleManager.useMetricUnits {
                            DetailRow(title: "Odometer", value: "\(Int(record.odometer)) km")
                        } else {
                            DetailRow(title: "Odometer", value: "\(Int(record.odometer * 0.621371)) mi")
                        }
                        
                        if let cost = record.cost {
                            DetailRow(title: "Cost", value: "$\(String(format: "%.2f", cost))")
                        }
                        
                        if let location = record.locationOfService, !location.isEmpty {
                            DetailRow(title: "Service Location", value: location)
                        }
                        
                        if let notes = record.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(vehicleManager.colorSchemeManager.cardBackgroundColor)
                    .cornerRadius(12)
                    
                    // Reminder Information
                    if record.reminderEnabled {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Reminder Settings")
                                .font(.headline)
                            
                            DetailRow(title: "Reminder Type", value: record.reminderType.rawValue)
                            DetailRow(title: "Reminder Value", value: "\(Int(record.reminderValue))")
                            
                            if let nextDue = record.nextDueOdometer {
                                if vehicleManager.useMetricUnits {
                                    DetailRow(title: "Next Due", value: "\(Int(nextDue)) km")
                                } else {
                                    DetailRow(title: "Next Due", value: "\(Int(nextDue * 0.621371)) mi")
                                }
                            }
                            
                            if let nextDueDate = record.nextDueDate {
                                DetailRow(title: "Next Due Date", value: nextDueDate.formatted(date: .long, time: .omitted))
                            }
                        }
                        .padding()
                        .background(vehicleManager.colorSchemeManager.cardBackgroundColor)
                        .cornerRadius(12)
                    }
                    
                    // Current Status
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Current Status")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("This maintenance is overdue and should be performed soon")
                                .font(.body)
                                .foregroundColor(.red)
                        }
                        
                        if let nextDue = record.nextDueOdometer {
                            let currentOdometer = vehicleManager.currentVehicle?.currentOdometer ?? 0
                            let overdueBy = currentOdometer - nextDue
                            if overdueBy > 0 {
                                if vehicleManager.useMetricUnits {
                                    Text("Overdue by \(Int(overdueBy)) km")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                        .fontWeight(.medium)
                                } else {
                                    Text("Overdue by \(Int(overdueBy * 0.621371)) mi")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(vehicleManager.colorSchemeManager.backgroundColor)
            .navigationTitle("Maintenance Details")
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

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
} 