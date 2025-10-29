import SwiftUI

struct iPadOSView: View {
    @ObservedObject var vehicleManager: VehicleManager
    @State private var selectedTab = 0
    @State private var showingFuelEntry = false
    @State private var showingMaintenance = false
    @State private var showingSpeedometer = false
    @State private var showingSettings = false
    @State private var showingExpenseTracker = false
    @State private var showingVehicleManagement = false
    @State private var selectedVehicle: Vehicle?
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            iPadOSSidebarView(
                selectedTab: $selectedTab,
                vehicleManager: vehicleManager,
                selectedVehicle: $selectedVehicle
            )
        } content: {
            // Content area
            iPadOSContentView(
                selectedTab: $selectedTab,
                vehicleManager: vehicleManager,
                selectedVehicle: $selectedVehicle,
                showingFuelEntry: $showingFuelEntry,
                showingMaintenance: $showingMaintenance,
                showingSpeedometer: $showingSpeedometer,
                showingSettings: $showingSettings,
                showingExpenseTracker: $showingExpenseTracker,
                showingVehicleManagement: $showingVehicleManagement
            )
        } detail: {
            // Detail view
            iPadOSDetailView(
                selectedTab: $selectedTab,
                vehicleManager: vehicleManager,
                selectedVehicle: $selectedVehicle,
                showingFuelEntry: $showingFuelEntry,
                showingMaintenance: $showingMaintenance,
                showingSpeedometer: $showingSpeedometer,
                showingSettings: $showingSettings,
                showingExpenseTracker: $showingExpenseTracker,
                showingVehicleManagement: $showingVehicleManagement
            )
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showingFuelEntry) {
            FuelEntryView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingMaintenance) {
            MaintenanceView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingSpeedometer) {
            SpeedometerView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingExpenseTracker) {
            ExpenseTrackerView(vehicleManager: vehicleManager)
        }
        .sheet(isPresented: $showingVehicleManagement) {
            VehicleManagementView(vehicleManager: vehicleManager)
        }
    }
}

struct iPadOSSidebarView: View {
    @Binding var selectedTab: Int
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var selectedVehicle: Vehicle?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "car.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("KEI-ONARA!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                
                Text("Vehicle Management")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
            
            // Navigation
            VStack(spacing: 8) {
                iPadOSNavigationItem(
                    icon: "house.fill",
                    title: "Dashboard",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 },
                    vehicleManager: vehicleManager
                )
                
                iPadOSNavigationItem(
                    icon: "fuelpump.fill",
                    title: "Fuel",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 },
                    vehicleManager: vehicleManager
                )
                
                iPadOSNavigationItem(
                    icon: "wrench.and.screwdriver.fill",
                    title: "Maintenance",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 },
                    vehicleManager: vehicleManager
                )
                
                iPadOSNavigationItem(
                    icon: "location.fill",
                    title: "Drive",
                    isSelected: selectedTab == 3,
                    action: { selectedTab = 3 },
                    vehicleManager: vehicleManager
                )
                
                iPadOSNavigationItem(
                    icon: "chart.bar.fill",
                    title: "Expenses",
                    isSelected: selectedTab == 4,
                    action: { selectedTab = 4 },
                    vehicleManager: vehicleManager
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Current Vehicle
            if let currentVehicle = vehicleManager.currentVehicle {
                VStack(spacing: 12) {
                    Text("CURRENT VEHICLE")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                        .tracking(1)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currentVehicle.displayName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                            
                            Text("\(Int(currentVehicle.currentOdometer)) \(vehicleManager.settings.useMetric ? "km" : "mi")")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(vehicleManager.colorSchemeManager.cardBackgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(vehicleManager.colorSchemeManager.cardBorderColor, lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 280)
        .background(vehicleManager.colorSchemeManager.backgroundColor)
    }
}

struct iPadOSNavigationItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @ObservedObject var vehicleManager: VehicleManager
    
    init(icon: String, title: String, isSelected: Bool, action: @escaping () -> Void, vehicleManager: VehicleManager) {
        self.icon = icon
        self.title = title
        self.isSelected = isSelected
        self.action = action
        self.vehicleManager = vehicleManager
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .white : vehicleManager.colorSchemeManager.secondaryTextColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : vehicleManager.colorSchemeManager.primaryTextColor)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct iPadOSContentView: View {
    @Binding var selectedTab: Int
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var selectedVehicle: Vehicle?
    @Binding var showingFuelEntry: Bool
    @Binding var showingMaintenance: Bool
    @Binding var showingSpeedometer: Bool
    @Binding var showingSettings: Bool
    @Binding var showingExpenseTracker: Bool
    @Binding var showingVehicleManagement: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(tabTitle)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 16) {
                    if selectedTab == 1 { // Fuel tab
                        Button(action: { showingFuelEntry = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                Text("Add Fuel Entry")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue)
                            )
                        }
                    }
                    
                    if selectedTab == 2 { // Maintenance tab
                        Button(action: { showingMaintenance = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                Text("Add Maintenance")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange)
                            )
                        }
                    }
                    
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .background(vehicleManager.colorSchemeManager.backgroundColor)
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    switch selectedTab {
                    case 0:
                        iPadOSDashboardView(vehicleManager: vehicleManager, showingSpeedometer: $showingSpeedometer)
                    case 1:
                        iPadOSFuelView(vehicleManager: vehicleManager, showingFuelEntry: $showingFuelEntry)
                    case 2:
                        iPadOSMaintenanceView(vehicleManager: vehicleManager, showingMaintenance: $showingMaintenance)
                    case 3:
                        iPadOSDriveView(vehicleManager: vehicleManager, showingSpeedometer: $showingSpeedometer)
                    case 4:
                        iPadOSExpensesView(vehicleManager: vehicleManager, showingExpenseTracker: $showingExpenseTracker)
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .background(vehicleManager.colorSchemeManager.backgroundColor)
    }
    
    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Dashboard"
        case 1: return "Fuel"
        case 2: return "Maintenance"
        case 3: return "Drive"
        case 4: return "Expenses"
        default: return ""
        }
    }
}

struct iPadOSDetailView: View {
    @Binding var selectedTab: Int
    @ObservedObject var vehicleManager: VehicleManager
    @Binding var selectedVehicle: Vehicle?
    @Binding var showingFuelEntry: Bool
    @Binding var showingMaintenance: Bool
    @Binding var showingSpeedometer: Bool
    @Binding var showingSettings: Bool
    @Binding var showingExpenseTracker: Bool
    @Binding var showingVehicleManagement: Bool
    
    var body: some View {
        VStack {
            if let selectedVehicle = selectedVehicle {
                // Vehicle detail view
                iPadOSVehicleDetailView(
                    vehicle: selectedVehicle,
                    vehicleManager: vehicleManager
                )
            } else {
                // Default detail view
                VStack(spacing: 24) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 80))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                    
                    Text("Select a Vehicle")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(vehicleManager.colorSchemeManager.primaryTextColor)
                    
                    Text("Choose a vehicle from the sidebar to view details")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(vehicleManager.colorSchemeManager.secondaryTextColor)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(vehicleManager.colorSchemeManager.backgroundColor)
    }
}

#Preview {
    iPadOSView(vehicleManager: VehicleManager())
} 