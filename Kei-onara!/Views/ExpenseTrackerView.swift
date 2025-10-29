import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct ExpenseTrackerView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPeriod: ExpensePeriod = .monthly
    
    enum ExpensePeriod: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    // Steve Jobs style colors
    private var steveJobsColors: [Color] {
        return [.blue, .blue, .blue, .blue]
    }
    
    private var fuelColor: Color { steveJobsColors[0] }
    private var maintenanceColor: Color { steveJobsColors[1] }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Vehicle Name Display
                    if let currentVehicle = vehicleManager.currentVehicle {
                        VStack(spacing: 8) {
                            Text("Expenses for")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(currentVehicle.displayName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    
                    // Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(ExpensePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Total Expenses
                    totalExpensesCard
                    
                    // Expense Breakdown
                    expenseBreakdownCard
                    
                    // Monthly/Yearly Chart
                    expenseChartCard
                    
                    // Recent Transactions
                    recentTransactionsCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Expense Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                print("📊 Expense Tracker opened for vehicle: \(vehicleManager.currentVehicle?.displayName ?? "None")")
            }
            .onChange(of: vehicleManager.currentVehicle?.id) { oldValue, newValue in
                print("🔄 Vehicle changed in Expense Tracker: \(oldValue?.uuidString ?? "None") -> \(newValue?.uuidString ?? "None")")
            }
        }
    }
    
    private var totalExpensesCard: some View {
        VStack(spacing: 16) {
            Text("Total Expenses")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("$\(String(format: "%.2f", totalFuelCost))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(fuelColor)
                    
                    Text("Fuel")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text("$\(String(format: "%.2f", totalMaintenanceCost))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(maintenanceColor)
                    
                    Text("Maintenance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text("$\(String(format: "%.2f", totalFuelCost + totalMaintenanceCost))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var expenseBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Expense Breakdown")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ExpenseRow(
                    title: "Fuel",
                    amount: totalFuelCost,
                    percentage: fuelPercentage,
                    color: fuelColor
                )
                
                ExpenseRow(
                    title: "Maintenance",
                    amount: totalMaintenanceCost,
                    percentage: maintenancePercentage,
                    color: maintenanceColor
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var expenseChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(selectedPeriod.rawValue) Trend")
                .font(.title2)
                .fontWeight(.semibold)
            
            #if canImport(Charts)
            if #available(iOS 16.0, *) {
                Chart(expenseData) { data in
                    BarMark(
                        x: .value("Month", data.month),
                        y: .value("Amount", data.amount)
                    )
                    .foregroundStyle(by: .value("Type", data.type))
                }
                .frame(height: 200)
                .chartForegroundStyleScale([
                    "Fuel": fuelColor,
                    "Maintenance": maintenanceColor
                ])
            } else {
                Text("Charts available in iOS 16+")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            }
            #else
            Text("Charts framework not available")
                .foregroundColor(.secondary)
                .frame(height: 200)
            #endif
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var recentTransactionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(recentTransactions.prefix(5), id: \.id) { transaction in
                    TransactionRow(transaction: transaction, fuelColor: fuelColor, maintenanceColor: maintenanceColor)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Computed Properties
    
    private var totalFuelCost: Double {
        let now = Date()
        let calendar = Calendar.current
        let currentVehicleId = vehicleManager.currentVehicle?.id
        print("🔍 Calculating total fuel cost for vehicle: \(currentVehicleId?.uuidString ?? "None")")
        
        return vehicleManager.fuelEntries
            .filter { $0.vehicleId == currentVehicleId }
            .filter { fuel in
                if selectedPeriod == .monthly {
                    return calendar.isDate(fuel.date, equalTo: now, toGranularity: .month)
                } else {
                    return calendar.isDate(fuel.date, equalTo: now, toGranularity: .year)
                }
            }
            .reduce(0) { $0 + $1.totalCost }
    }
    
    private var totalMaintenanceCost: Double {
        let now = Date()
        let calendar = Calendar.current
        let currentVehicleId = vehicleManager.currentVehicle?.id
        print("🔍 Calculating total maintenance cost for vehicle: \(currentVehicleId?.uuidString ?? "None")")
        
        return vehicleManager.maintenanceRecords
            .filter { $0.vehicleId == currentVehicleId }
            .filter { record in
                if selectedPeriod == .monthly {
                    return calendar.isDate(record.date, equalTo: now, toGranularity: .month)
                } else {
                    return calendar.isDate(record.date, equalTo: now, toGranularity: .year)
                }
            }
            .compactMap { $0.cost }
            .reduce(0, +)
    }
    
    private var fuelPercentage: Double {
        let total = totalFuelCost + totalMaintenanceCost
        return total > 0 ? (totalFuelCost / total) * 100 : 0
    }
    
    private var maintenancePercentage: Double {
        let total = totalFuelCost + totalMaintenanceCost
        return total > 0 ? (totalMaintenanceCost / total) * 100 : 0
    }
    
    private var expenseData: [ExpenseData] {
        var data: [ExpenseData] = []
        let calendar = Calendar.current
        let now = Date()
        
        if selectedPeriod == .monthly {
            // Generate data for last 3 months
            for i in 0..<3 {
                guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
                
                let monthName = monthDate.formatted(.dateTime.month(.abbreviated))
                
                // Calculate fuel costs for this month
                let monthFuelCost = vehicleManager.fuelEntries
                    .filter { 
                        $0.vehicleId == vehicleManager.currentVehicle?.id &&
                        calendar.isDate($0.date, equalTo: monthDate, toGranularity: .month)
                    }
                    .reduce(0) { $0 + $1.totalCost }
                
                // Calculate maintenance costs for this month
                let monthMaintenanceCost = vehicleManager.maintenanceRecords
                    .filter { 
                        $0.vehicleId == vehicleManager.currentVehicle?.id &&
                        calendar.isDate($0.date, equalTo: monthDate, toGranularity: .month)
                    }
                    .compactMap { $0.cost }
                    .reduce(0, +)
                
                data.append(ExpenseData(month: monthName, amount: monthFuelCost, type: "Fuel"))
                data.append(ExpenseData(month: monthName, amount: monthMaintenanceCost, type: "Maintenance"))
            }
        } else {
            // Generate data for last 3 years
            for i in 0..<3 {
                guard let yearDate = calendar.date(byAdding: .year, value: -i, to: now) else { continue }
                
                let yearName = yearDate.formatted(.dateTime.year())
                
                // Calculate fuel costs for this year
                let yearFuelCost = vehicleManager.fuelEntries
                    .filter { 
                        $0.vehicleId == vehicleManager.currentVehicle?.id &&
                        calendar.isDate($0.date, equalTo: yearDate, toGranularity: .year)
                    }
                    .reduce(0) { $0 + $1.totalCost }
                
                // Calculate maintenance costs for this year
                let yearMaintenanceCost = vehicleManager.maintenanceRecords
                    .filter { 
                        $0.vehicleId == vehicleManager.currentVehicle?.id &&
                        calendar.isDate($0.date, equalTo: yearDate, toGranularity: .year)
                    }
                    .compactMap { $0.cost }
                    .reduce(0, +)
                
                data.append(ExpenseData(month: yearName, amount: yearFuelCost, type: "Fuel"))
                data.append(ExpenseData(month: yearName, amount: yearMaintenanceCost, type: "Maintenance"))
            }
        }
        
        // Reverse the data so it shows oldest to newest
        return data.reversed()
    }
    
    private var recentTransactions: [Transaction] {
        var transactions: [Transaction] = []
        
        // Add fuel entries
        let filteredFuelEntries = vehicleManager.fuelEntries
            .filter { $0.vehicleId == vehicleManager.currentVehicle?.id }
            .sorted(by: { $0.date > $1.date })
        
        for fuel in filteredFuelEntries {
            var title = "Fuel (\(fuel.fuelGrade.rawValue))"
            if let location = fuel.location, !location.isEmpty {
                title += " - \(location)"
            }
            
            transactions.append(Transaction(
                id: fuel.id,
                date: fuel.date,
                title: title,
                amount: fuel.totalCost,
                type: .fuel
            ))
        }
        
        // Add maintenance records
        let filteredMaintenanceRecords = vehicleManager.maintenanceRecords
            .filter { $0.vehicleId == vehicleManager.currentVehicle?.id }
            .sorted(by: { $0.date > $1.date })
        
        for maintenance in filteredMaintenanceRecords {
            if let cost = maintenance.cost {
                transactions.append(Transaction(
                    id: maintenance.id,
                    date: maintenance.date,
                    title: maintenance.type.rawValue,
                    amount: cost,
                    type: .maintenance
                ))
            }
        }
        
        return transactions.sorted(by: { $0.date > $1.date })
    }
}

struct ExpenseRow: View {
    let title: String
    let amount: Double
    let percentage: Double
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(String(format: "%.2f", amount))")
                    .fontWeight(.semibold)
                
                Text("\(String(format: "%.1f", percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    let fuelColor: Color
    let maintenanceColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: transaction.type.icon)
                .foregroundColor(transaction.type.color(fuelColor: fuelColor, maintenanceColor: maintenanceColor))
                .frame(width: 24)
            
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .fontWeight(.medium)
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", transaction.amount))")
                .fontWeight(.semibold)
                .foregroundColor(transaction.type.color(fuelColor: fuelColor, maintenanceColor: maintenanceColor))
        }
        .padding(.vertical, 4)
    }
}

struct ExpenseData: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
    let type: String
}

struct Transaction: Identifiable {
    let id: UUID
    let date: Date
    let title: String
    let amount: Double
    let type: TransactionType
    
    enum TransactionType {
        case fuel, maintenance
        
        var icon: String {
            switch self {
            case .fuel: return "fuelpump.fill"
            case .maintenance: return "wrench.fill"
            }
        }
        
        func color(fuelColor: Color, maintenanceColor: Color) -> Color {
            switch self {
            case .fuel: return fuelColor
            case .maintenance: return maintenanceColor
            }
        }
    }
}

#Preview {
    ExpenseTrackerView(vehicleManager: VehicleManager())
} 