import SwiftUI
import PhotosUI

struct VehicleManagementView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAddVehicle = false
    @State private var showingEditVehicle = false
    @State private var showingDataTransfer = false
    @State private var selectedVehicle: Vehicle?
    @State private var showingDeleteAlert = false
    @State private var vehicleToDelete: Vehicle?
    @State private var vehicleToTransfer: Vehicle?
    
    var body: some View {
        NavigationView {
            List {
                Section("Current Vehicle") {
                    if let currentVehicle = vehicleManager.currentVehicle {
                        VehicleRow(
                            vehicle: currentVehicle,
                            isCurrent: true,
                            onEdit: { selectedVehicle = currentVehicle; showingEditVehicle = true },
                            onDelete: { vehicleToDelete = currentVehicle; showingDeleteAlert = true },
                            onTransfer: { vehicleToTransfer = currentVehicle; showingDataTransfer = true }
                        )
                    }
                }
                
                Section("Other Vehicles") {
                    ForEach(vehicleManager.vehicles.filter { $0.id != vehicleManager.currentVehicle?.id }) { vehicle in
                        VehicleRow(
                            vehicle: vehicle,
                            isCurrent: false,
                            onEdit: { selectedVehicle = vehicle; showingEditVehicle = true },
                            onDelete: { vehicleToDelete = vehicle; showingDeleteAlert = true },
                            onTransfer: { vehicleToTransfer = vehicle; showingDataTransfer = true }
                        )
                        .onTapGesture {
                            vehicleManager.switchToVehicle(vehicle)
                        }
                    }
                }
                
                Section {
                    Button(action: { showingAddVehicle = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add New Vehicle")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Vehicle Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddVehicle) {
            VehicleFormView(vehicleManager: vehicleManager, mode: .add)
        }
        .sheet(isPresented: $showingEditVehicle) {
            if let vehicle = selectedVehicle {
                VehicleFormView(vehicleManager: vehicleManager, mode: .edit(vehicle))
            }
        }
        .sheet(isPresented: $showingDataTransfer) {
            if let vehicle = vehicleToTransfer {
                DataTransferView(vehicleManager: vehicleManager, sourceVehicle: vehicle)
            }
        }
        .alert("Delete Vehicle", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let vehicle = vehicleToDelete {
                    vehicleManager.deleteVehicle(vehicle)
                }
            }
        } message: {
            Text("Are you sure you want to delete this vehicle? This action cannot be undone.")
        }
    }
    

}

struct VehicleRow: View {
    let vehicle: Vehicle
    let isCurrent: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onTransfer: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(vehicle.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(vehicle.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(vehicle.currentOdometer)) km")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isCurrent {
                    Text("Current")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            HStack {
                Button("Edit") {
                    onEdit()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button("Transfer") {
                    onTransfer()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Spacer()
                
                Button("Delete") {
                    onDelete()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct VehicleFormView: View {
    @ObservedObject var vehicleManager: VehicleManager
    let mode: VehicleFormMode
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var make: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var currentOdometer: String = ""
    @State private var fuelCapacity: String = ""
    @State private var photoData: Data? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    enum VehicleFormMode {
        case add
        case edit(Vehicle)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Vehicle Photo") {
                    HStack {
                        if let photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        } else {
                            Image(systemName: "car.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                                .foregroundColor(.gray)
                        }
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Text(photoData == nil ? "Add Photo" : "Change Photo")
                        }
                        .onChange(of: selectedPhoto) { oldItem, newItem in
                            if let newItem {
                                Task {
                                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                                        photoData = data
                                    }
                                }
                            }
                        }
                    }
                }
                Section("Vehicle Information") {
                    TextField("Vehicle Name", text: $name)
                    TextField("Make", text: $make)
                    TextField("Model", text: $model)
                    TextField("Year", text: $year)
                        .keyboardType(.numberPad)
                }
                Section("Current Status") {
                    TextField("Current Odometer (km)", text: $currentOdometer)
                        .keyboardType(.numberPad)
                    TextField("Fuel Capacity (L)", text: $fuelCapacity)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle({
                switch mode {
                case .add:
                    return "Add Vehicle"
                case .edit:
                    return "Edit Vehicle"
                }
            }())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveVehicle()
                    }
                    .disabled(!canSave)
                }
            }
        }
        .onAppear {
            loadVehicleData()
        }
    }
    
    private var canSave: Bool {
        !name.isEmpty && !make.isEmpty && !model.isEmpty && 
        !year.isEmpty && !currentOdometer.isEmpty && !fuelCapacity.isEmpty
    }
    
    private func loadVehicleData() {
        if case .edit(let vehicle) = mode {
            name = vehicle.name
            make = vehicle.make
            model = vehicle.model
            year = String(vehicle.year)
            currentOdometer = String(Int(vehicle.currentOdometer))
            fuelCapacity = String(vehicle.fuelCapacity)
            photoData = vehicle.photoData
        }
    }
    
    private func saveVehicle() {
        guard let yearValue = Int(year),
              let odometerValue = Double(currentOdometer),
              let fuelCapacityValue = Double(fuelCapacity) else {
            return
        }
        switch mode {
        case .add:
            let newVehicle = Vehicle(
                name: name,
                make: make,
                model: model,
                year: yearValue,
                currentOdometer: odometerValue,
                fuelCapacity: fuelCapacityValue,
                photoData: photoData
            )
            vehicleManager.addVehicle(newVehicle)
        case .edit(let vehicle):
            var updatedVehicle = vehicle
            updatedVehicle.name = name
            updatedVehicle.make = make
            updatedVehicle.model = model
            updatedVehicle.year = yearValue
            updatedVehicle.currentOdometer = odometerValue
            updatedVehicle.fuelCapacity = fuelCapacityValue
            updatedVehicle.photoData = photoData
            vehicleManager.updateVehicle(
                updatedVehicle,
                name: updatedVehicle.name,
                make: updatedVehicle.make,
                model: updatedVehicle.model,
                year: updatedVehicle.year,
                currentOdometer: updatedVehicle.currentOdometer,
                fuelCapacity: updatedVehicle.fuelCapacity,
                photoData: updatedVehicle.photoData
            )
        }
        dismiss()
    }
}

#Preview {
    VehicleManagementView(vehicleManager: VehicleManager())
} 