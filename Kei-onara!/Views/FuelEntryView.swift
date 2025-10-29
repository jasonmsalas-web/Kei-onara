import SwiftUI

enum FuelUnit: String, CaseIterable {
    case liters = "Liters"
    case gallons = "Gallons"
    
    var conversionToLiters: Double {
        switch self {
        case .liters: return 1.0
        case .gallons: return 3.78541
        }
    }
    
    var conversionToGallons: Double {
        switch self {
        case .liters: return 0.264172
        case .gallons: return 1.0
        }
    }
    
    var singular: String {
        switch self {
        case .liters: return "Liter"
        case .gallons: return "Gallon"
        }
    }
}

struct FuelEntryView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var fuelAmount: String = ""
    @State private var pricePerUnit: String = ""
    @State private var odometer: String = ""
    @State private var location: String = ""
    @State private var isFullTank: Bool = true
    @State private var fuelUnit: FuelUnit
    @State private var fuelDate: Date = Date()
    @State private var selectedFuelGrade: FuelGrade = .regular
    @State private var showingEditFuel = false
    @State private var editingFuelEntry: FuelEntry? = nil
    @State private var fuelEntryToDelete: FuelEntry? = nil
    @State private var showingDeleteAlert = false
    @State private var showingFinalDeleteAlert = false
    
    init(vehicleManager: VehicleManager) {
        self.vehicleManager = vehicleManager
        // Default to gallons if imperial units are selected, otherwise liters
        let defaultUnit: FuelUnit = vehicleManager.settings.useMetric ? .liters : .gallons
        self._fuelUnit = State(initialValue: defaultUnit)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        headerSection
                        fuelDetailsSection
                        additionalDetailsSection
                        fuelGradeSection
                        saveButtonSection
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
        .sheet(isPresented: $showingEditFuel) {
            if let fuelEntry = editingFuelEntry {
                EditFuelEntryView(vehicleManager: vehicleManager, fuelEntry: fuelEntry)
            }
        }
        .alert("Delete Fuel Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { fuelEntryToDelete = nil }
            Button("Delete", role: .destructive) {
                showingDeleteAlert = false
                showingFinalDeleteAlert = true
            }
        } message: {
            Text("Are you sure you want to delete this fuel entry? This action cannot be undone.")
        }
        .alert("Confirm Deletion", isPresented: $showingFinalDeleteAlert) {
            Button("Cancel", role: .cancel) { fuelEntryToDelete = nil }
            Button("Delete", role: .destructive) {
                if let entry = fuelEntryToDelete {
                    vehicleManager.fuelEntries.removeAll { $0.id == entry.id }
                    vehicleManager.saveAllData()
                    fuelEntryToDelete = nil
                }
            }
        } message: {
            Text("Please confirm again: Delete this fuel entry permanently?")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("FUEL ENTRY")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            Text("Log your fuel purchase")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
    
    private var fuelDetailsSection: some View {
        VStack(spacing: 20) {
            Text("FUEL DETAILS")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                VStack(spacing: 16) {
                    datePickerView
                    fuelUnitPicker
                    fuelAmountField
                    fuelConversionDisplay
                    pricePerUnitField
                    priceConversionDisplay
                }
            }
        }
    }
    
    private var datePickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DATE")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .tracking(1)
            
            DatePicker("", selection: $fuelDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }
    
    private var fuelUnitPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FUEL UNIT")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .tracking(1)
            
            Picker("Fuel Unit", selection: $fuelUnit) {
                ForEach(FuelUnit.allCases, id: \.self) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var fuelAmountField: some View {
        SteveJobsFormField(
            title: fuelUnitTitle,
            text: $fuelAmount,
            placeholder: "0.0",
            keyboardType: .decimalPad,
            vehicleManager: vehicleManager
        )
    }
    
    private var fuelConversionDisplay: some View {
        Group {
            if let fuelValue = Double(fuelAmount), fuelValue > 0 {
                HStack {
                    Text(conversionUnitLabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(conversionValueText)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var pricePerUnitField: some View {
        SteveJobsFormField(
            title: pricePerUnitTitle,
            text: $pricePerUnit,
            placeholder: "0.00",
            keyboardType: .decimalPad,
            vehicleManager: vehicleManager
        )
    }
    
    private var priceConversionDisplay: some View {
        Group {
            if let priceValue = Double(pricePerUnit), priceValue > 0 {
                HStack {
                    Text(priceLabelText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(priceText)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var additionalDetailsSection: some View {
        VStack(spacing: 20) {
            Text("ADDITIONAL DETAILS")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                VStack(spacing: 16) {
                    totalCostDisplay
                    odometerField
                    milesConversionDisplay
                    locationField
                    fullTankToggle
                }
            }
        }
    }
    
    private var totalCostDisplay: some View {
        Group {
            if let fuelValue = Double(fuelAmount), 
               let priceValue = Double(pricePerUnit), 
               fuelValue > 0, 
               priceValue > 0 {
                HStack {
                    Text("TOTAL COST")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(totalCostText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var odometerField: some View {
        SteveJobsFormField(
            title: "ODOMETER",
            text: $odometer,
            placeholder: "0",
            keyboardType: .numberPad,
            vehicleManager: vehicleManager
        )
    }
    
    private var milesConversionDisplay: some View {
        Group {
            if let odometerValue = Double(odometer), odometerValue > 0 {
                HStack {
                    Text("MILES")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(milesText)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var locationField: some View {
        SteveJobsFormField(
            title: "LOCATION",
            text: $location,
            placeholder: "Gas station name",
            vehicleManager: vehicleManager
        )
    }
    
    private var fullTankToggle: some View {
        HStack {
            Text("FULL TANK")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
            Spacer()
            Toggle("", isOn: $isFullTank)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
    }
    
    private var fuelGradeSection: some View {
        VStack(spacing: 20) {
            Text("FUEL GRADE")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SteveJobsLeatherCard(vehicleManager: vehicleManager) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(FuelGrade.allCases, id: \.self) { grade in
                        gradeButton(grade)
                    }
                }
            }
        }
    }
    
    private func gradeButton(_ grade: FuelGrade) -> some View {
        Button(action: {
            selectedFuelGrade = grade
        }) {
            VStack(spacing: 8) {
                Image(systemName: grade.icon)
                    .font(.system(size: 20))
                    .foregroundColor(selectedFuelGrade == grade ? .white : grade.color)
                
                Text(grade.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(selectedFuelGrade == grade ? .white : .black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedFuelGrade == grade ? grade.color : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedFuelGrade == grade ? grade.color : Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var saveButtonSection: some View {
        VStack(spacing: 20) {
            Text("SAVE ENTRY")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: saveFuelEntry) {
                HStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    
                    Text("SAVE FUEL ENTRY")
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
    
    // Computed properties for complex calculations
    private var fuelUnitTitle: String {
        fuelUnit.rawValue.uppercased()
    }
    
    private var conversionUnitLabel: String {
        fuelUnit == .liters ? "GALLONS" : "LITERS"
    }
    
    private var conversionValueText: String {
        guard let fuelValue = Double(fuelAmount), fuelValue > 0 else {
            return ""
        }
        let conversionFactor = fuelUnit == .liters ? 0.264172 : 3.78541
        let convertedValue = fuelValue * conversionFactor
        return String(format: "%.2f", convertedValue)
    }
    
    private var pricePerUnitTitle: String {
        let singularUnit = fuelUnit.singular.uppercased()
        return "PRICE PER \(singularUnit)"
    }
    
    private var priceLabelText: String {
        let priceUnit = fuelUnit == .liters ? "GALLON" : "LITER"
        return "PRICE PER \(priceUnit)"
    }
    
    private var priceText: String {
        guard let priceValue = Double(pricePerUnit), priceValue > 0 else {
            return ""
        }
        let priceConversionFactor = fuelUnit == .liters ? 3.78541 : 0.264172
        let convertedPrice = priceValue * priceConversionFactor
        return String(format: "$%.2f", convertedPrice)
    }
    
    private var totalCostText: String {
        guard let fuelValue = Double(fuelAmount),
              let priceValue = Double(pricePerUnit),
              fuelValue > 0,
              priceValue > 0 else {
            return ""
        }
        let totalCost = fuelValue * priceValue
        return String(format: "$%.2f", totalCost)
    }
    
    private var milesText: String {
        guard let odometerValue = Double(odometer), odometerValue > 0 else {
            return ""
        }
        let milesValue = odometerValue * 0.621371
        return String(format: "%.1f", milesValue)
    }
    
    private var currentVehicleFuelEntries: [FuelEntry] {
        vehicleManager.fuelEntries
            .filter { $0.vehicleId == vehicleManager.currentVehicle?.id }
            .sorted(by: { $0.date > $1.date })
            .prefix(5)
            .map { $0 }
    }
    
    private var canSave: Bool {
        guard let fuelValue = Double(fuelAmount),
              let priceValue = Double(pricePerUnit),
              let odometerValue = Double(odometer) else {
            return false
        }
        
        return fuelValue > 0 && priceValue > 0 && odometerValue > 0
    }
    
    private func saveFuelEntry() {
        guard let fuelValue = Double(fuelAmount),
              let priceValue = Double(pricePerUnit),
              let odometerValue = Double(odometer) else {
            return
        }
        
        // Convert to liters for storage
        let litersValue = fuelValue * fuelUnit.conversionToLiters
        let pricePerLiter = priceValue / fuelUnit.conversionToLiters
        
        let fuelEntry = FuelEntry(
            id: UUID(),
            vehicleId: vehicleManager.currentVehicle?.id ?? UUID(),
            date: fuelDate,
            liters: litersValue,
            pricePerLiter: pricePerLiter,
            odometer: odometerValue,
            isFullTank: true,
            location: location.isEmpty ? nil as String? : location,
            fuelGrade: selectedFuelGrade
        )
        
        vehicleManager.addFuelEntry(fuelEntry)
        
        dismiss()
    }
}

struct FuelHistoryRow: View {
    let fuelEntry: FuelEntry
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: fuelEntry.fuelGrade.icon)
                    .foregroundColor(fuelEntry.fuelGrade.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(fuelEntry.fuelGrade.rawValue) Fuel")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(fuelEntry.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(String(format: "%.2f", fuelEntry.totalCost))")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text("\(String(format: "%.1f", fuelEntry.gallons)) gal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("\(Int(fuelEntry.odometer)) km")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let location = fuelEntry.location, !location.isEmpty {
                    Spacer()
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack {
                Button("Edit") {
                    onEdit()
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", fuelEntry.pricePerGallon))/gal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button("Delete") {
                onDelete()
            }
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }
}

struct EditFuelEntryView: View {
    @ObservedObject var vehicleManager: VehicleManager
    let fuelEntry: FuelEntry
    @Environment(\.dismiss) private var dismiss
    
    @State private var fuelAmount: String
    @State private var pricePerUnit: String
    @State private var odometer: String
    @State private var location: String
    @State private var fuelDate: Date
    @State private var selectedFuelGrade: FuelGrade
    @State private var fuelUnit: FuelUnit = .gallons
    
    init(vehicleManager: VehicleManager, fuelEntry: FuelEntry) {
        self.vehicleManager = vehicleManager
        self.fuelEntry = fuelEntry
        
        // Initialize state with current values
        self._fuelAmount = State(initialValue: String(format: "%.2f", fuelEntry.gallons))
        self._pricePerUnit = State(initialValue: String(format: "%.2f", fuelEntry.pricePerGallon))
        self._odometer = State(initialValue: String(Int(fuelEntry.odometer)))
        self._location = State(initialValue: fuelEntry.location ?? "")
        self._fuelDate = State(initialValue: fuelEntry.date)
        self._selectedFuelGrade = State(initialValue: fuelEntry.fuelGrade)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Fuel Details") {
                    DatePicker("Date", selection: $fuelDate, displayedComponents: .date)
                    
                    HStack {
                        Text("Gallons")
                        Spacer()
                        TextField("0.0", text: $fuelAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Price per Gallon")
                        Spacer()
                        TextField("0.00", text: $pricePerUnit)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if let fuelValue = Double(fuelAmount), let priceValue = Double(pricePerUnit), fuelValue > 0, priceValue > 0 {
                        HStack {
                            Text("Total Cost")
                            Spacer()
                            Text(String(format: "$%.2f", fuelValue * priceValue))
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section("Fuel Grade") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(FuelGrade.allCases, id: \.self) { grade in
                            Button(action: {
                                selectedFuelGrade = grade
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: grade.icon)
                                        .font(.title2)
                                        .foregroundColor(selectedFuelGrade == grade ? .white : grade.color)
                                    
                                    Text(grade.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedFuelGrade == grade ? .white : .primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedFuelGrade == grade ? grade.color : Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedFuelGrade == grade ? grade.color : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Section("Location (Optional)") {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.blue)
                        TextField("Gas station name or location...", text: $location)
                    }
                }
                
                Section("Odometer") {
                    HStack {
                        Text("Reading")
                        Spacer()
                        TextField("0", text: $odometer)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(canSave ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .disabled(!canSave)
                }
            }
            .navigationTitle("Edit Fuel Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var canSave: Bool {
        guard let fuelValue = Double(fuelAmount),
              let priceValue = Double(pricePerUnit),
              let odometerValue = Double(odometer) else {
            return false
        }
        
        return fuelValue > 0 && priceValue > 0 && odometerValue > 0
    }
    
    private func saveChanges() {
        guard let fuelValue = Double(fuelAmount),
              let priceValue = Double(pricePerUnit),
              let odometerValue = Double(odometer) else {
            return
        }
        
        // Convert to liters for storage
        let litersValue = fuelValue * 3.78541 // gallons to liters
        let pricePerLiter = priceValue / 3.78541 // price per gallon to price per liter
        
        // Create updated fuel entry
        let updatedFuelEntry = FuelEntry(
            id: fuelEntry.id,
            vehicleId: fuelEntry.vehicleId,
            date: fuelDate,
            liters: litersValue,
            pricePerLiter: pricePerLiter,
            odometer: odometerValue,
            isFullTank: fuelEntry.isFullTank,
            location: location.isEmpty ? nil as String? : location,
            fuelGrade: selectedFuelGrade
        )
        
        // Update the fuel entry using the public method
        vehicleManager.updateFuelEntry(updatedFuelEntry)
        
        dismiss()
    }
}

#Preview {
    FuelEntryView(vehicleManager: VehicleManager())
} 