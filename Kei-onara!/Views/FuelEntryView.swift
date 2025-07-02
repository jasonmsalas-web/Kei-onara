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
    
    init(vehicleManager: VehicleManager) {
        self.vehicleManager = vehicleManager
        // Default to gallons if imperial units are selected, otherwise liters
        let defaultUnit: FuelUnit = vehicleManager.settings.useMetric ? .liters : .gallons
        self._fuelUnit = State(initialValue: defaultUnit)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Fuel Details") {
                    DatePicker("Date", selection: $fuelDate, displayedComponents: .date)
                    
                    Picker("Fuel Unit", selection: $fuelUnit) {
                        ForEach(FuelUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    HStack {
                        Text(fuelUnit.rawValue)
                        Spacer()
                        TextField("0.0", text: $fuelAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if let fuelValue = Double(fuelAmount), fuelValue > 0 {
                        HStack {
                            Text(fuelUnit == .liters ? "Gallons" : "Liters")
                            Spacer()
                            Text(String(format: "%.2f", fuelValue * (fuelUnit == .liters ? 0.264172 : 3.78541)))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Price per \(fuelUnit.singular)")
                        Spacer()
                        TextField("0.00", text: $pricePerUnit)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if let priceValue = Double(pricePerUnit), priceValue > 0 {
                        HStack {
                            Text("Price per \(fuelUnit == .liters ? "Gallon" : "Liter")")
                            Spacer()
                            Text(String(format: "$%.2f", priceValue * (fuelUnit == .liters ? 3.78541 : 0.264172)))
                                .foregroundColor(.secondary)
                        }
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
                        Text("Current Reading")
                        Spacer()
                        TextField("0", text: $odometer)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if let odometerValue = Double(odometer), odometerValue > 0 {
                        HStack {
                            Text("Miles")
                            Spacer()
                            Text(String(format: "%.1f", odometerValue * 0.621371))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Toggle("Full Tank", isOn: $isFullTank)
                }
                
                Section {
                    Button("Save Fuel Entry") {
                        saveFuelEntry()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(canSave ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .disabled(!canSave)
                }
                
                Section("Recent Fuel History") {
                    let currentVehicleFuelEntries = vehicleManager.fuelEntries
                        .filter { $0.vehicleId == vehicleManager.currentVehicle?.id }
                        .sorted(by: { $0.date > $1.date })
                        .prefix(5)
                    
                    if currentVehicleFuelEntries.isEmpty {
                        Text("No fuel entries yet")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(Array(currentVehicleFuelEntries)) { fuelEntry in
                            FuelHistoryRow(fuelEntry: fuelEntry, onEdit: {
                                editingFuelEntry = fuelEntry
                                showingEditFuel = true
                            })
                        }
                    }
                }
            }
            .navigationTitle("Add Fuel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingEditFuel) {
                if let fuelEntry = editingFuelEntry {
                    EditFuelEntryView(vehicleManager: vehicleManager, fuelEntry: fuelEntry)
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
    
    private func saveFuelEntry() {
        guard let fuelValue = Double(fuelAmount),
              let priceValue = Double(pricePerUnit),
              let odometerValue = Double(odometer) else {
            return
        }
        
        // Convert to liters for storage
        let litersValue = fuelValue * fuelUnit.conversionToLiters
        let pricePerLiter = priceValue / fuelUnit.conversionToLiters
        
        vehicleManager.addFuelEntry(
            liters: litersValue,
            pricePerLiter: pricePerLiter,
            odometer: odometerValue,
            date: fuelDate,
            location: location.isEmpty ? nil : location,
            fuelGrade: selectedFuelGrade
        )
        
        dismiss()
    }
}

struct FuelHistoryRow: View {
    let fuelEntry: FuelEntry
    let onEdit: () -> Void
    
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
        
        // Update the fuel entry using the public method
        vehicleManager.updateFuelEntry(
            fuelEntry,
            date: fuelDate,
            liters: litersValue,
            pricePerLiter: pricePerLiter,
            odometer: odometerValue,
            location: location.isEmpty ? nil : location,
            fuelGrade: selectedFuelGrade
        )
        
        dismiss()
    }
}

#Preview {
    FuelEntryView(vehicleManager: VehicleManager())
} 