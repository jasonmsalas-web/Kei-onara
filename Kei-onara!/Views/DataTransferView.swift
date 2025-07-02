import SwiftUI

struct DataTransferView: View {
    @ObservedObject var vehicleManager: VehicleManager
    let sourceVehicle: Vehicle
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDestinationVehicle: Vehicle?
    @State private var transferDriveLogs = true
    @State private var transferFuelEntries = true
    @State private var transferMaintenanceRecords = true
    @State private var showingConfirmation = false
    
    var availableDestinationVehicles: [Vehicle] {
        vehicleManager.vehicles.filter { $0.id != sourceVehicle.id }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Source Vehicle") {
                    HStack {
                        Text("From:")
                        Spacer()
                        Text(sourceVehicle.displayName)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Destination Vehicle") {
                    if availableDestinationVehicles.isEmpty {
                        Text("No other vehicles available")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(availableDestinationVehicles) { vehicle in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(vehicle.displayName)
                                        .font(.headline)
                                    Text(vehicle.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedDestinationVehicle?.id == vehicle.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedDestinationVehicle = vehicle
                            }
                        }
                    }
                }
                
                Section("Data to Transfer") {
                    Toggle("Drive Logs", isOn: $transferDriveLogs)
                    Toggle("Fuel Entries", isOn: $transferFuelEntries)
                    Toggle("Maintenance Records", isOn: $transferMaintenanceRecords)
                }
                
                Section("Summary") {
                    if let destination = selectedDestinationVehicle {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Transfer Summary:")
                                .font(.headline)
                            
                            Text("From: \(sourceVehicle.displayName)")
                            Text("To: \(destination.displayName)")
                            
                            if transferDriveLogs {
                                let driveLogCount = vehicleManager.driveLogs.filter { $0.vehicleId == sourceVehicle.id }.count
                                Text("Drive Logs: \(driveLogCount)")
                            }
                            
                            if transferFuelEntries {
                                let fuelEntryCount = vehicleManager.fuelEntries.filter { $0.vehicleId == sourceVehicle.id }.count
                                Text("Fuel Entries: \(fuelEntryCount)")
                            }
                            
                            if transferMaintenanceRecords {
                                let maintenanceCount = vehicleManager.maintenanceRecords.filter { $0.vehicleId == sourceVehicle.id }.count
                                Text("Maintenance Records: \(maintenanceCount)")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Transfer Data") {
                        showingConfirmation = true
                    }
                    .disabled(selectedDestinationVehicle == nil)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Transfer Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Confirm Transfer", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Transfer", role: .destructive) {
                performTransfer()
            }
        } message: {
            Text("This will transfer all selected data from '\(sourceVehicle.displayName)' to '\(selectedDestinationVehicle?.displayName ?? "")' and delete the source vehicle. This action cannot be undone.")
        }
    }
    
    private func performTransfer() {
        guard let destinationVehicle = selectedDestinationVehicle else { return }
        
        // Transfer selected data types
        if transferDriveLogs {
            for i in vehicleManager.driveLogs.indices {
                if vehicleManager.driveLogs[i].vehicleId == sourceVehicle.id {
                    vehicleManager.driveLogs[i].vehicleId = destinationVehicle.id
                }
            }
        }
        
        if transferFuelEntries {
            for i in vehicleManager.fuelEntries.indices {
                if vehicleManager.fuelEntries[i].vehicleId == sourceVehicle.id {
                    vehicleManager.fuelEntries[i].vehicleId = destinationVehicle.id
                }
            }
        }
        
        if transferMaintenanceRecords {
            for i in vehicleManager.maintenanceRecords.indices {
                if vehicleManager.maintenanceRecords[i].vehicleId == sourceVehicle.id {
                    vehicleManager.maintenanceRecords[i].vehicleId = destinationVehicle.id
                }
            }
        }
        
        // Delete the source vehicle
        vehicleManager.deleteVehicle(sourceVehicle)
        
        dismiss()
    }
}

#Preview {
    DataTransferView(
        vehicleManager: VehicleManager(),
        sourceVehicle: Vehicle(
            name: "Test Vehicle",
            make: "Suzuki",
            model: "Every",
            year: 2020,
            currentOdometer: 50000,
            fuelCapacity: 30
        )
    )
} 