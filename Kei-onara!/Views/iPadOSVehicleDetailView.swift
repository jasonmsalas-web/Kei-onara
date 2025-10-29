import SwiftUI

struct iPadOSVehicleDetailView: View {
    let vehicle: Vehicle
    @ObservedObject var vehicleManager: VehicleManager
    @State private var showingEditVehicle = false
    @State private var showingDeleteAlert = false
    @State private var showingDataTransfer = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Vehicle Header
                iPadOSVehicleHeader(vehicle: vehicle, vehicleManager: vehicleManager)
                
                // Vehicle Information Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 24) {
                    // Basic Information
                    iPadOSVehicleInfoCard(
                        title: "BASIC INFORMATION",
                        items: [
                            ("Name", vehicle.name),
                            ("Make", vehicle.make),
                            ("Model", vehicle.model),
                            ("Year", "\(vehicle.year)")
                        ],
                        vehicleManager: vehicleManager
                    )
                    
                    // Current Status
                    iPadOSVehicleInfoCard(
                        title: "CURRENT STATUS",
                        items: [
                            ("Odometer", "\(Int(vehicle.currentOdometer)) \(vehicleManager.settings.useMetric ? "km" : "mi")"),
                            ("Fuel Capacity", String(format: "%.1f %@", vehicle.fuelCapacity, vehicleManager.settings.useMetric ? "L" : "gal")),
                            ("VIN", vehicle.vin ?? "Not specified"),
                            ("Status", "Active")
                        ],
                        vehicleManager: vehicleManager
                    )
                }
                
                // Quick Actions
                iPadOSQuickActionsView(
                    vehicle: vehicle,
                    vehicleManager: vehicleManager
                )
                
                // Recent Activity
                iPadOSRecentActivityView(
                    vehicle: vehicle,
                    vehicleManager: vehicleManager
                )
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
        .background(vehicleManager.colorSchemeManager.backgroundColor)
        .navigationTitle(vehicle.displayName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Edit Vehicle") {
                        showingEditVehicle = true
                    }
                    
                    Button("Transfer Data") {
                        showingDataTransfer = true
                    }
                    
                    Divider()
                    
                    Button("Delete Vehicle", role: .destructive) {
                        showingDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                }
            }
        }
        .sheet(isPresented: $showingEditVehicle) {
            VehicleFormView(vehicleManager: vehicleManager, mode: .edit(vehicle))
        }
        .sheet(isPresented: $showingDataTransfer) {
            DataTransferView(vehicleManager: vehicleManager, sourceVehicle: vehicle)
        }
        .alert("Delete Vehicle", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                vehicleManager.deleteVehicle(vehicle)
            }
        } message: {
            Text("Are you sure you want to delete \(vehicle.displayName)? This action cannot be undone.")
        }
    }
}

struct iPadOSVehicleHeader: View {
    let vehicle: Vehicle
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        VStack(spacing: 24) {
            // Vehicle Photo
            if let photoData = vehicle.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(vehicleManager.colorSchemeManager.cardBorderColor, lineWidth: 2)
                    )
                    .shadow(color: vehicleManager.colorSchemeManager.isDarkMode ? .white.opacity(0.1) : .black.opacity(0.1), radius: 10, x: 0, y: 5)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(vehicleManager.colorSchemeManager.cardBackgroundColor)
                        .frame(width: 200, height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(vehicleManager.colorSchemeManager.cardBorderColor, lineWidth: 2)
                        )
                    
                    VStack(spacing: 12) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 60))
                            .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                        
                        Text("No Photo")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                    }
                }
            }
            
            // Vehicle Details
            VStack(spacing: 8) {
                Text(vehicle.displayName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                
                Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                
                if let vin = vehicle.vin, !vin.isEmpty {
                    Text("VIN: \(vin)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(vehicleManager.colorSchemeManager.cardBackgroundColor)
                        )
                }
            }
        }
    }
}

struct iPadOSVehicleInfoCard: View {
    let title: String
    let items: [(String, String)]
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(items, id: \.0) { item in
                    HStack {
                        Text(item.0)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                        
                        Spacer()
                        
                        Text(item.1)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(vehicleManager.colorSchemeManager.cardBackgroundColor.opacity(0.5))
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(vehicleManager.colorSchemeManager.cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(vehicleManager.colorSchemeManager.cardBorderColor, lineWidth: 1)
                )
        )
    }
}

struct iPadOSQuickActionsView: View {
    let vehicle: Vehicle
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("QUICK ACTIONS")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                iPadOSQuickActionButton(
                    title: "Add Fuel",
                    icon: "fuelpump.fill",
                    color: .blue,
                    vehicleManager: vehicleManager
                )
                
                iPadOSQuickActionButton(
                    title: "Log Maintenance",
                    icon: "wrench.and.screwdriver.fill",
                    color: .orange,
                    vehicleManager: vehicleManager
                )
                
                iPadOSQuickActionButton(
                    title: "Start Ride",
                    icon: "location.fill",
                    color: .green,
                    vehicleManager: vehicleManager
                )
            }
        }
    }
}

struct iPadOSQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        Button(action: {
            // Handle quick action
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(vehicleManager.colorSchemeManager.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(vehicleManager.colorSchemeManager.cardBorderColor, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct iPadOSRecentActivityView: View {
    let vehicle: Vehicle
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("RECENT ACTIVITY")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Recent fuel entries
                ForEach(vehicleManager.fuelEntries.prefix(3), id: \.id) { entry in
                    iPadOSActivityRow(
                        title: "Fuel Entry",
                        subtitle: String(format: "%.1f %@ • $%.2f", entry.liters, vehicleManager.settings.useMetric ? "L" : "gal", entry.totalCost),
                        date: entry.date,
                        icon: "fuelpump.fill",
                        color: .blue,
                        vehicleManager: vehicleManager
                    )
                }
                
                // Recent maintenance records
                ForEach(vehicleManager.maintenanceRecords.prefix(2), id: \.id) { record in
                    iPadOSActivityRow(
                        title: record.type.rawValue,
                        subtitle: record.cost != nil ? String(format: "$%.2f", record.cost!) : "No cost",
                        date: record.date,
                        icon: "wrench.and.screwdriver.fill",
                        color: record.type.color,
                        vehicleManager: vehicleManager
                    )
                }
            }
        }
    }
}

struct iPadOSActivityRow: View {
    let title: String
    let subtitle: String
    let date: Date
    let icon: String
    let color: Color
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
            }
            
            Spacer()
            
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
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

#Preview {
    NavigationView {
        iPadOSVehicleDetailView(
            vehicle: Vehicle(
                name: "My Car",
                make: "Toyota",
                model: "Camry",
                year: 2020,
                currentOdometer: 50000,
                fuelCapacity: 50.0
            ),
            vehicleManager: VehicleManager()
        )
    }
} 