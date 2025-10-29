import SwiftUI

struct MaintenanceView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: MaintenanceType = .oilChange
    @State private var odometer: String = ""
    @State private var cost: String = ""
    @State private var notes: String = ""
    @State private var locationOfService: String = ""
    @State private var maintenanceDate: Date = Date()
    @State private var showingAddRecord = false
    @State private var editingRecord: MaintenanceRecord? = nil
    @State private var showingEditRecord = false
    @State private var reminderEnabled: Bool = false
    @State private var reminderType: ReminderType = .odometer
    @State private var reminderValue: String = ""
    @State private var showingDeleteAlert = false
    @State private var recordToDelete: MaintenanceRecord? = nil
    
    var body: some View {
        NavigationView {
            List {
                addMaintenanceSection
                maintenanceHistorySection
            }
            .navigationTitle("Maintenance")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Done") {
                dismiss()
            })
            .alert("Add Maintenance Record", isPresented: $showingAddRecord) {
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    addMaintenanceRecord()
                }
            } message: {
                Text("Add \(selectedType.rawValue) at \(odometer) km?")
            }
            .sheet(isPresented: $showingEditRecord) {
                if let record = editingRecord {
                    EditMaintenanceRecordView(vehicleManager: vehicleManager, record: record)
                } else {
                    EmptyView()
                }
            }
            .alert("Delete Maintenance Record", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let record = recordToDelete {
                        vehicleManager.deleteMaintenanceRecord(record)
                    }
                }
            } message: {
                if let record = recordToDelete {
                    Text("Are you sure you want to delete the \(record.type.rawValue) record from \(record.date.formatted(date: .abbreviated, time: .omitted))? This action cannot be undone.")
                }
            }
        }
    }
    
    private var addMaintenanceSection: some View {
        Section("Add Maintenance Record") {
            Picker("Type", selection: $selectedType) {
                ForEach(MaintenanceType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: type.icon)
                        Text(type.rawValue)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.menu)
            
            DatePicker("Date", selection: $maintenanceDate, displayedComponents: .date)
            
            HStack {
                Text("Odometer")
                Spacer()
                TextField("0", text: $odometer)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            
            HStack {
                Text("Cost (Optional)")
                Spacer()
                TextField("0.00", text: $cost)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            
            VStack(alignment: .leading) {
                Text("Notes (Optional)")
                TextField("Add notes...", text: $notes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack {
                Text("Location of Service (Optional)")
                Spacer()
                TextField("Service center name...", text: $locationOfService)
                    .multilineTextAlignment(.trailing)
            }
            
            // Reminder Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                    Text("Maintenance Reminder")
                        .font(.headline)
                    Spacer()
                    Toggle("", isOn: $reminderEnabled)
                }
                
                if reminderEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Reminder Type", selection: $reminderType) {
                            ForEach(ReminderType.allCases, id: \.self) { type in
                                HStack {
                                    Image(systemName: type.icon)
                                    Text(type.rawValue)
                                }
                                .tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        HStack {
                            Text(reminderType == .odometer ? "Additional km:" : "Days from now:")
                            Spacer()
                            TextField(reminderType == .odometer ? "5000" : "30", text: $reminderValue)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                    }
                    .padding(.leading, 20)
                }
            }
            
            Button("Add Record") {
                showingAddRecord = true
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding()
            .background(canAddRecord ? Color.blue : Color.gray)
            .cornerRadius(10)
            .disabled(!canAddRecord)
        }
    }
    
    private var maintenanceHistorySection: some View {
        Section("Maintenance History") {
            if currentVehicleRecords.isEmpty {
                Text("No maintenance records yet")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(currentVehicleRecords) { record in
                    MaintenanceRecordRow(record: record, onEdit: {
                        editingRecord = record
                        showingEditRecord = true
                    }, onDelete: {
                        recordToDelete = record
                        showingDeleteAlert = true
                    })
                }
            }
        }
    }
    
    private var currentVehicleRecords: [MaintenanceRecord] {
        vehicleManager.maintenanceRecords
            .filter { $0.vehicleId == vehicleManager.currentVehicle?.id }
            .sorted(by: { $0.date > $1.date })
    }
    
    private var canAddRecord: Bool {
        guard let odometerValue = Double(odometer) else { return false }
        return odometerValue > 0
    }
    
    private func addMaintenanceRecord() {
        guard let odometerValue = Double(odometer) else { return }
        
        let costValue = Double(cost)
        let reminderValueDouble = Double(reminderValue) ?? 0
        
        let maintenanceRecord = MaintenanceRecord(
            vehicleId: vehicleManager.currentVehicle?.id ?? UUID(),
            type: selectedType,
            date: maintenanceDate,
            odometer: odometerValue,
            cost: costValue,
            notes: notes.isEmpty ? nil : notes,
            locationOfService: locationOfService.isEmpty ? nil : locationOfService,
            nextDueOdometer: nil as Double?,
            nextDueDate: nil as Date?,
            reminderEnabled: reminderEnabled,
            reminderType: reminderType,
            reminderValue: reminderValueDouble
        )
        
        vehicleManager.addMaintenanceRecord(maintenanceRecord)
        
        // Reset form
        odometer = ""
        cost = ""
        notes = ""
        locationOfService = ""
        reminderEnabled = false
        reminderType = .odometer
        reminderValue = ""
        maintenanceDate = Date()
    }
}

struct MaintenanceRecordRow: View {
    let record: MaintenanceRecord
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: record.type.icon)
                    .foregroundColor(.blue)
                
                Text(record.type.rawValue)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(record.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("\(Int(record.odometer)) km")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let cost = record.cost {
                    Spacer()
                    Text("$\(String(format: "%.2f", cost))")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            if let notes = record.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let location = record.locationOfService, !location.isEmpty {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let nextDue = record.nextDueOdometer, record.reminderEnabled {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("Next due: \(Int(nextDue)) km")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            if record.reminderEnabled {
                HStack {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("Reminder: \(record.reminderType.rawValue) - \(Int(record.reminderValue))")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            HStack {
                Button(action: {
                    print("🔧 Edit button tapped for \(record.type.rawValue)")
                    onEdit()
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: {
                    print("🗑️ Delete button tapped for \(record.type.rawValue)")
                    onDelete()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct EditMaintenanceRecordView: View {
    @ObservedObject var vehicleManager: VehicleManager
    let record: MaintenanceRecord
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: MaintenanceType
    @State private var odometer: String
    @State private var cost: String
    @State private var notes: String
    @State private var locationOfService: String
    @State private var maintenanceDate: Date
    @State private var reminderEnabled: Bool
    @State private var reminderType: ReminderType
    @State private var reminderValue: String
    
    init(vehicleManager: VehicleManager, record: MaintenanceRecord) {
        self.vehicleManager = vehicleManager
        self.record = record
        self._selectedType = State(initialValue: record.type)
        self._odometer = State(initialValue: String(Int(record.odometer)))
        self._cost = State(initialValue: record.cost != nil ? String(format: "%.2f", record.cost!) : "")
        self._notes = State(initialValue: record.notes ?? "")
        self._locationOfService = State(initialValue: record.locationOfService ?? "")
        self._maintenanceDate = State(initialValue: record.date)
        self._reminderEnabled = State(initialValue: record.reminderEnabled)
        self._reminderType = State(initialValue: record.reminderType)
        self._reminderValue = State(initialValue: String(Int(record.reminderValue)))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Edit Maintenance Record") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(MaintenanceType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    DatePicker("Date", selection: $maintenanceDate, displayedComponents: .date)
                    
                    HStack {
                        Text("Odometer")
                        Spacer()
                        TextField("0", text: $odometer)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Cost (Optional)")
                        Spacer()
                        TextField("0.00", text: $cost)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Notes (Optional)")
                        TextField("Add notes...", text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Text("Location of Service (Optional)")
                        Spacer()
                        TextField("Service center name...", text: $locationOfService)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    // Reminder Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                            Text("Maintenance Reminder")
                                .font(.headline)
                            Spacer()
                            Toggle("", isOn: $reminderEnabled)
                        }
                        
                        if reminderEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Reminder Type", selection: $reminderType) {
                                    ForEach(ReminderType.allCases, id: \.self) { type in
                                        HStack {
                                            Image(systemName: type.icon)
                                            Text(type.rawValue)
                                        }
                                        .tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                HStack {
                                    Text(reminderType == .odometer ? "Additional km:" : "Days from now:")
                                    Spacer()
                                    TextField(reminderType == .odometer ? "5000" : "30", text: $reminderValue)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 100)
                                }
                            }
                            .padding(.leading, 20)
                        }
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
            .navigationTitle("Edit Maintenance")
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
        guard let odometerValue = Double(odometer) else { return false }
        return odometerValue > 0
    }
    
    private func saveChanges() {
        guard let odometerValue = Double(odometer) else { return }
        
        let costValue = Double(cost)
        let reminderValueDouble = Double(reminderValue) ?? 0
        
        let updatedRecord = MaintenanceRecord(
            id: record.id,
            vehicleId: record.vehicleId,
            type: selectedType,
            date: maintenanceDate,
            odometer: odometerValue,
            cost: costValue,
            notes: notes.isEmpty ? nil : notes,
            locationOfService: locationOfService.isEmpty ? nil : locationOfService,
            nextDueOdometer: record.nextDueOdometer,
            nextDueDate: record.nextDueDate,
            reminderEnabled: reminderEnabled,
            reminderType: reminderType,
            reminderValue: reminderValueDouble
        )
        
        vehicleManager.updateMaintenanceRecord(updatedRecord)
        
        dismiss()
    }
}

#Preview {
    MaintenanceView(vehicleManager: VehicleManager())
} 