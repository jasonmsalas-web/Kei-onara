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
            ZStack {
                // Background - Pure white with subtle texture
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Text("VEHICLE MANAGEMENT")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Manage your vehicle fleet")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        // Current Vehicle Section
                        VStack(spacing: 20) {
                            Text("CURRENT VEHICLE")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .tracking(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if let currentVehicle = vehicleManager.currentVehicle {
                                let onEditAction: () -> Void = {
                                    selectedVehicle = currentVehicle
                                    showingEditVehicle = true
                                }
                                let onDeleteAction: () -> Void = {
                                    vehicleToDelete = currentVehicle
                                    showingDeleteAlert = true
                                }
                                let onTransferAction: () -> Void = {
                                    vehicleToTransfer = currentVehicle
                                    showingDataTransfer = true
                                }
                                
                                SteveJobsVehicleCard(
                                    vehicle: currentVehicle,
                                    isCurrent: true,
                                    onEdit: onEditAction,
                                    onDelete: onDeleteAction,
                                    onTransfer: onTransferAction,
                                    vehicleManager: vehicleManager
                                )
                            }
                        }
                        
                        // Other Vehicles Section
                        let otherVehicles = vehicleManager.vehicles.filter { $0.id != vehicleManager.currentVehicle?.id }
                        if !otherVehicles.isEmpty {
                            VStack(spacing: 20) {
                                Text("OTHER VEHICLES")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                    .tracking(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 12) {
                                    ForEach(otherVehicles) { vehicle in
                                        let onEditAction: () -> Void = {
                                            selectedVehicle = vehicle
                                            showingEditVehicle = true
                                        }
                                        let onDeleteAction: () -> Void = {
                                            vehicleToDelete = vehicle
                                            showingDeleteAlert = true
                                        }
                                        let onTransferAction: () -> Void = {
                                            vehicleToTransfer = vehicle
                                            showingDataTransfer = true
                                        }
                                        
                                        SteveJobsVehicleCard(
                                            vehicle: vehicle,
                                            isCurrent: false,
                                            onEdit: onEditAction,
                                            onDelete: onDeleteAction,
                                            onTransfer: onTransferAction,
                                            vehicleManager: vehicleManager
                                        )
                                        .onTapGesture {
                                            vehicleManager.setCurrentVehicle(vehicle)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Add Vehicle Button
                        VStack(spacing: 20) {
                            Text("ADD NEW VEHICLE")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .tracking(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: { showingAddVehicle = true }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.blue)
                                    
                                    Text("ADD VEHICLE")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.blue)
                                        .tracking(1)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("DONE") {
                    dismiss()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
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

struct SteveJobsVehicleCard: View {
    let vehicle: Vehicle
    let isCurrent: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onTransfer: () -> Void
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
                                SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                            VStack(spacing: 16) {
                                // Vehicle info with icon
                                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "car.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vehicle.displayName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                        
                        Text(vehicle.name)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                        
                        Text("\(Int(vehicle.currentOdometer)) km")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                        
                        if let vin = vehicle.vin, !vin.isEmpty {
                            Text("VIN: \(vin)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    if isCurrent {
                        Text("CURRENT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(6)
                    }
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil")
                                .font(.system(size: 12))
                            Text("EDIT")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onTransfer) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 12))
                            Text("TRANSFER")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: onDelete) {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                            Text("DELETE")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct SteveJobsFormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    @ObservedObject var vehicleManager: VehicleManager
    
    init(title: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default, vehicleManager: VehicleManager) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.vehicleManager = vehicleManager
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                .tracking(1)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(vehicleManager.colorSchemeManager.textFieldBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(vehicleManager.colorSchemeManager.textFieldBorderColor, lineWidth: 1)
                        )
                )
                .keyboardType(keyboardType)
        }
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
    @State private var vin: String = ""
    @State private var insuranceCardData: Data? = nil
    @State private var selectedInsuranceCard: PhotosPickerItem? = nil
    
    enum VehicleFormMode {
        case add
        case edit(Vehicle)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background - Pure white with subtle texture
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Text(navigationTitle.uppercased())
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Vehicle information")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        // Form sections
                        VStack(spacing: 24) {
                            steveJobsVehiclePhotoSection
                            steveJobsVehicleInformationSection
                            steveJobsCurrentStatusSection
                            steveJobsInsuranceCardSection
                        }
                        
                        // Save button
                        VStack(spacing: 20) {
                            Text("SAVE VEHICLE")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .tracking(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: saveVehicle) {
                                HStack(spacing: 16) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                    
                                    Text("SAVE VEHICLE")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .tracking(1)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(canSave ? Color.blue : Color.gray)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(!canSave)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("CANCEL") {
                    dismiss()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            }
        }
        .onAppear {
            loadVehicleData()
        }
    }
    
    private var canSave: Bool {
        let hasMake = !make.isEmpty
        let hasModel = !model.isEmpty
        let hasYear = !year.isEmpty
        
        return hasMake && hasModel && hasYear
    }
    
    private var navigationTitle: String {
        switch mode {
        case .add:
            return "Add Vehicle"
        case .edit:
            return "Edit Vehicle"
        }
    }
    
    // MARK: - Steve Jobs Style Form Sections
    
    private var steveJobsVehiclePhotoSection: some View {
        VStack(spacing: 20) {
            Text("VEHICLE PHOTO")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                VStack(spacing: 16) {
                    if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 14))
                            Text("SELECT PHOTO")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var steveJobsVehicleInformationSection: some View {
        VStack(spacing: 20) {
            Text("VEHICLE INFORMATION")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
                                        SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                                VStack(spacing: 16) {
                                                                        SteveJobsFormField(title: "NAME", text: $name, placeholder: "Vehicle name", vehicleManager: vehicleManager)
                                    SteveJobsFormField(title: "MAKE", text: $make, placeholder: "Manufacturer", vehicleManager: vehicleManager)
                                    SteveJobsFormField(title: "MODEL", text: $model, placeholder: "Model name", vehicleManager: vehicleManager)
                                    SteveJobsFormField(title: "YEAR", text: $year, placeholder: "Year", keyboardType: .numberPad, vehicleManager: vehicleManager)
                }
            }
        }
    }
    
    private var steveJobsCurrentStatusSection: some View {
        VStack(spacing: 20) {
            Text("CURRENT STATUS")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                VStack(spacing: 16) {
                    SteveJobsFormField(
                        title: "ODOMETER",
                        text: $currentOdometer,
                        placeholder: vehicleManager.settings.useMetric ? "Current mileage (km)" : "Current mileage (mi)",
                        keyboardType: .numberPad,
                        vehicleManager: vehicleManager
                    )
                    SteveJobsFormField(
                        title: "FUEL CAPACITY",
                        text: $fuelCapacity,
                        placeholder: vehicleManager.settings.useMetric ? "Tank capacity (L)" : "Tank capacity (gal)",
                        keyboardType: .decimalPad,
                        vehicleManager: vehicleManager
                    )
                    SteveJobsFormField(title: "VIN", text: $vin, placeholder: "Vehicle identification number", vehicleManager: vehicleManager)
                }
            }
        }
    }
    
    private var steveJobsInsuranceCardSection: some View {
        VStack(spacing: 20) {
            Text("INSURANCE CARD")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                VStack(spacing: 16) {
                    if let insuranceCardData = insuranceCardData, let uiImage = UIImage(data: insuranceCardData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 120)
                            
                            VStack(spacing: 8) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                                Text("No insurance card")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    PhotosPicker(selection: $selectedInsuranceCard, matching: .images) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 14))
                            Text("SELECT INSURANCE CARD")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Original Form Sections (for reference)
    
    private var vehiclePhotoPreview: some View {
        VehiclePhotoView(photoData: photoData)
    }
    
    private var insuranceCardPreview: some View {
        InsuranceCardView(insuranceCardData: insuranceCardData)
    }
    
    private var vehiclePhotoSection: some View {
        Section("Vehicle Photo") {
            HStack {
                vehiclePhotoPreview
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Text(photoData == nil ? "Add Photo" : "Change Photo")
                }
                .onChange(of: selectedPhoto) { oldItem, newItem in
                    handlePhotoSelection(newItem)
                }
            }
        }
    }
    
    private var vehicleInformationSection: some View {
        Section("Vehicle Information") {
            TextField("Vehicle Name", text: $name)
            TextField("Make", text: $make)
            TextField("Model", text: $model)
            TextField("Year", text: $year)
                .keyboardType(.numberPad)
            TextField("VIN (Optional)", text: $vin)
                .textInputAutocapitalization(.characters)
        }
    }
    
    private var currentStatusSection: some View {
        Section("Current Status") {
            TextField("Current Odometer (km)", text: $currentOdometer)
                .keyboardType(.numberPad)
            TextField("Fuel Capacity (L)", text: $fuelCapacity)
                .keyboardType(.decimalPad)
        }
    }
    
    private var insuranceCardSection: some View {
        Section("Insurance Card (Optional)") {
            HStack {
                insuranceCardPreview
                PhotosPicker(selection: $selectedInsuranceCard, matching: .images) {
                    Text(insuranceCardData == nil ? "Add Insurance Card" : "Change Insurance Card")
                }
                .onChange(of: selectedInsuranceCard) { oldItem, newItem in
                    handleInsuranceCardSelection(newItem)
                }
            }
            
            if insuranceCardData != nil {
                Button("Remove Insurance Card") {
                    insuranceCardData = nil
                }
                .foregroundColor(.red)
            }
        }
    }
    
    private func loadVehicleData() {
        if case .edit(let vehicle) = mode {
            name = vehicle.name
            make = vehicle.make
            model = vehicle.model
            year = String(vehicle.year)
            
            // Convert odometer to user's preferred units
            let odometerInUserUnits = vehicleManager.settings.useMetric ? 
                vehicle.currentOdometer : 
                vehicle.currentOdometer * 0.621371 // km to miles
            currentOdometer = String(Int(odometerInUserUnits))
            
            // Convert fuel capacity to user's preferred units
            let fuelCapacityInUserUnits = vehicleManager.settings.useMetric ? 
                vehicle.fuelCapacity : 
                vehicle.fuelCapacity * 0.264172 // liters to gallons
            fuelCapacity = String(format: "%.1f", fuelCapacityInUserUnits)
            
            photoData = vehicle.photoData
            vin = vehicle.vin ?? ""
            insuranceCardData = vehicle.insuranceCardData
        }
    }
    
    private func handlePhotoSelection(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                photoData = data
            }
        }
    }
    
    private func handleInsuranceCardSelection(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                insuranceCardData = data
            }
        }
    }
    
    private func saveVehicle() {
        // Parse input values
        guard let yearValue = Int(year) else { return }
        let odometerValue = Double(currentOdometer) ?? 0.0
        let fuelCapacityValue = Double(fuelCapacity) ?? 0.0
        
        // Use default name if empty
        let vehicleName = name.isEmpty ? "\(yearValue) \(make) \(model)" : name
        
        // Convert odometer to metric (km) for storage
        let odometerInMetric = vehicleManager.settings.useMetric ? 
            odometerValue : 
            odometerValue * 1.60934 // miles to km
        
        // Convert fuel capacity to metric (liters) for storage
        let fuelCapacityInMetric = vehicleManager.settings.useMetric ? 
            fuelCapacityValue : 
            fuelCapacityValue * 3.78541 // gallons to liters
        
        // Prepare VIN value
        let vinValue = vin.isEmpty ? nil : vin
        
        switch mode {
        case .add:
            let newVehicle = Vehicle(
                name: vehicleName,
                make: make,
                model: model,
                year: yearValue,
                currentOdometer: odometerInMetric,
                fuelCapacity: fuelCapacityInMetric,
                photoData: photoData,
                vin: vinValue,
                insuranceCardData: insuranceCardData
            )
            vehicleManager.addVehicle(newVehicle)
            
        case .edit(let vehicle):
            var updatedVehicle = vehicle
            updatedVehicle.name = vehicleName
            updatedVehicle.make = make
            updatedVehicle.model = model
            updatedVehicle.year = yearValue
            updatedVehicle.currentOdometer = odometerInMetric
            updatedVehicle.fuelCapacity = fuelCapacityInMetric
            updatedVehicle.photoData = photoData
            updatedVehicle.vin = vinValue
            updatedVehicle.insuranceCardData = insuranceCardData
            
            vehicleManager.updateVehicle(updatedVehicle)
        }
        dismiss()
    }
}

#Preview {
    VehicleManagementView(vehicleManager: VehicleManager())
}

struct VehiclePhotoView: View {
    let photoData: Data?
    
    var body: some View {
        Group {
            if let photoData = photoData {
                if let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                } else {
                    placeholderView
                }
            } else {
                placeholderView
            }
        }
    }
    
    private var placeholderView: some View {
        Image(systemName: "car.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 48, height: 48)
            .foregroundColor(.gray)
    }
}

struct InsuranceCardView: View {
    let insuranceCardData: Data?
    
    var body: some View {
        Group {
            if let insuranceCardData = insuranceCardData {
                if let uiImage = UIImage(data: insuranceCardData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                } else {
                    placeholderView
                }
            } else {
                placeholderView
            }
        }
    }
    
    private var placeholderView: some View {
        Image(systemName: "doc.text")
            .resizable()
            .scaledToFit()
            .frame(width: 48, height: 48)
            .foregroundColor(.gray)
    }
} 