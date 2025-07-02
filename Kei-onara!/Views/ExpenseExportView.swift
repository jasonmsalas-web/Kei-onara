import SwiftUI
import UniformTypeIdentifiers

struct ExpenseExportView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedVehicleId: UUID = UUID()
    @State private var exportType: ExportType = .pdf
    @State private var dateRange: DateRange = .allTime
    @State private var includeFuel = true
    @State private var includeMaintenance = true
    @State private var includeDrives = false
    @State private var showingExportOptions = false
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    
    enum ExportType: String, CaseIterable {
        case pdf = "PDF"
        case excel = "Excel"
        
        var fileExtension: String {
            switch self {
            case .pdf: return "pdf"
            case .excel: return "xlsx"
            }
        }
        
        var mimeType: String {
            switch self {
            case .pdf: return "application/pdf"
            case .excel: return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            }
        }
    }
    
    enum DateRange: String, CaseIterable {
        case lastMonth = "Last Month"
        case last3Months = "Last 3 Months"
        case last6Months = "Last 6 Months"
        case lastYear = "Last Year"
        case allTime = "All Time"
        case custom = "Custom Range"
        
        var startDate: Date {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .lastMonth:
                return calendar.date(byAdding: .month, value: -1, to: now) ?? now
            case .last3Months:
                return calendar.date(byAdding: .month, value: -3, to: now) ?? now
            case .last6Months:
                return calendar.date(byAdding: .month, value: -6, to: now) ?? now
            case .lastYear:
                return calendar.date(byAdding: .year, value: -1, to: now) ?? now
            case .allTime:
                return Date.distantPast
            case .custom:
                return now // Will be overridden by custom dates
            }
        }
    }
    
    var selectedVehicle: Vehicle? {
        vehicleManager.vehicles.first(where: { $0.id == selectedVehicleId })
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Vehicle") {
                    if let currentVehicle = vehicleManager.currentVehicle {
                        HStack {
                            Text("Current Vehicle")
                            Spacer()
                            Text(currentVehicle.displayName)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if vehicleManager.vehicles.count > 1 {
                        Picker("Select Vehicle", selection: $selectedVehicleId) {
                            ForEach(vehicleManager.vehicles) { vehicle in
                                Text(vehicle.displayName).tag(vehicle.id)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Export Format") {
                    Picker("Format", selection: $exportType) {
                        ForEach(ExportType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Date Range") {
                    Picker("Time Period", selection: $dateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Data to Include") {
                    Toggle("Fuel Expenses", isOn: $includeFuel)
                    Toggle("Maintenance Costs", isOn: $includeMaintenance)
                    Toggle("Drive Logs", isOn: $includeDrives)
                }
                
                Section("Summary") {
                    if let vehicle = selectedVehicle {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Export Summary:")
                                .font(.headline)
                            
                            Text("Vehicle: \(vehicle.displayName)")
                            Text("Format: \(exportType.rawValue)")
                            Text("Period: \(dateRange.rawValue)")
                            
                            if includeFuel {
                                let fuelCount = getFuelEntries(for: vehicle).count
                                Text("Fuel Entries: \(fuelCount)")
                            }
                            
                            if includeMaintenance {
                                let maintenanceCount = getMaintenanceRecords(for: vehicle).count
                                Text("Maintenance Records: \(maintenanceCount)")
                            }
                            
                            if includeDrives {
                                let driveCount = getDriveLogs(for: vehicle).count
                                Text("Drive Logs: \(driveCount)")
                            }
                            
                            let totalCost = calculateTotalCost(for: vehicle)
                            Text("Total Cost: $\(String(format: "%.2f", totalCost))")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Export Expenses") {
                        exportExpenses()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(canExport ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .disabled(!canExport)
                }
            }
            .navigationTitle("Export Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(items: [url])
            }
        }
        .onAppear {
            if let current = vehicleManager.currentVehicle {
                selectedVehicleId = current.id
            } else if let first = vehicleManager.vehicles.first {
                selectedVehicleId = first.id
            }
        }
    }
    
    private var canExport: Bool {
        selectedVehicle != nil && (includeFuel || includeMaintenance || includeDrives)
    }
    
    private func getFuelEntries(for vehicle: Vehicle) -> [FuelEntry] {
        let entries = vehicleManager.fuelEntries.filter { $0.vehicleId == vehicle.id }
        return entries.filter { $0.date >= dateRange.startDate }
    }
    
    private func getMaintenanceRecords(for vehicle: Vehicle) -> [MaintenanceRecord] {
        let records = vehicleManager.maintenanceRecords.filter { $0.vehicleId == vehicle.id }
        return records.filter { $0.date >= dateRange.startDate }
    }
    
    private func getDriveLogs(for vehicle: Vehicle) -> [DriveLog] {
        let logs = vehicleManager.driveLogs.filter { $0.vehicleId == vehicle.id }
        return logs.filter { $0.startTime >= dateRange.startDate }
    }
    
    private func calculateTotalCost(for vehicle: Vehicle) -> Double {
        var total: Double = 0
        
        if includeFuel {
            total += getFuelEntries(for: vehicle).reduce(0) { $0 + $1.totalCost }
        }
        
        if includeMaintenance {
            total += getMaintenanceRecords(for: vehicle).compactMap { $0.cost }.reduce(0, +)
        }
        
        return total
    }
    
    private func exportExpenses() {
        guard let vehicle = selectedVehicle else { return }
        
        let fileName = "\(vehicle.name)_Expenses_\(Date().formatted(date: .abbreviated, time: .omitted)).\(exportType.fileExtension)"
        
        switch exportType {
        case .pdf:
            exportToPDF(vehicle: vehicle, fileName: fileName)
        case .excel:
            exportToExcel(vehicle: vehicle, fileName: fileName)
        }
    }
    
    private func exportToPDF(vehicle: Vehicle, fileName: String) {
        let fuelEntries = getFuelEntries(for: vehicle)
        let maintenanceRecords = getMaintenanceRecords(for: vehicle)
        let driveLogs = getDriveLogs(for: vehicle)
        
        if let pdfData = PDFExporter.generateExpenseReport(
            vehicle: vehicle,
            fuelEntries: includeFuel ? fuelEntries : [],
            maintenanceRecords: includeMaintenance ? maintenanceRecords : [],
            driveLogs: includeDrives ? driveLogs : [],
            dateRange: dateRange.rawValue,
            includeFuel: includeFuel,
            includeMaintenance: includeMaintenance,
            includeDrives: includeDrives
        ) {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            do {
                try pdfData.write(to: fileURL)
                exportedFileURL = fileURL
                showingShareSheet = true
            } catch {
                print("Error saving PDF: \(error)")
            }
        }
    }
    
    private func exportToExcel(vehicle: Vehicle, fileName: String) {
        // Create Excel content (CSV format for simplicity)
        let csvContent = createCSVContent(for: vehicle)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            exportedFileURL = fileURL
            showingShareSheet = true
        } catch {
            print("Error saving Excel: \(error)")
        }
    }
    
    private func createCSVContent(for vehicle: Vehicle) -> String {
        var content = "Type,Date,Description,Amount,Odometer,Notes\n"
        
        if includeFuel {
            for entry in getFuelEntries(for: vehicle) {
                content += "Fuel,"
                content += "\(entry.date.formatted(date: .abbreviated, time: .omitted)),"
                content += "Fuel Purchase,"
                content += "$\(String(format: "%.2f", entry.totalCost)),"
                content += "\(Int(entry.odometer)),"
                content += "\(entry.liters) liters at $\(String(format: "%.2f", entry.pricePerLiter))/L\n"
            }
        }
        
        if includeMaintenance {
            for record in getMaintenanceRecords(for: vehicle) {
                content += "Maintenance,"
                content += "\(record.date.formatted(date: .abbreviated, time: .omitted)),"
                content += "\(record.type.rawValue),"
                content += "$\(String(format: "%.2f", record.cost ?? 0)),"
                content += "\(Int(record.odometer)),"
                content += "\(record.notes ?? "")\n"
            }
        }
        
        if includeDrives {
            for log in getDriveLogs(for: vehicle) {
                content += "Drive,"
                content += "\(log.startTime.formatted(date: .abbreviated, time: .omitted)),"
                content += "Drive Session,"
                content += "$0.00,"
                content += "\(Int(log.startOdometer)),"
                content += "Distance: \(String(format: "%.1f", log.distance)) km\n"
            }
        }
        
        return content
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExpenseExportView(vehicleManager: VehicleManager())
} 