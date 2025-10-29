# Kei-onara! 🚛

A comprehensive iOS app for managing your Kei truck fleet with a focus on simplicity, accessibility, and fun! Track fuel, maintenance, and expenses across all your vehicles with native support for iPhone, iPad, Apple Watch, and CarPlay.

## ✨ Key Features

### 🚗 Multi-Vehicle Management
- **Unlimited Vehicles** - Track multiple vehicles with individual profiles
- **Quick Vehicle Switching** - Easy switching between your fleet
- **Vehicle Photos** - Add photos and insurance card storage
- **VIN Tracking** - Store Vehicle Identification Numbers
- **Data Transfer** - Move maintenance records between vehicles

### ⛽ Advanced Fuel Management
- **Dual Unit Support** - Track in Liters or Gallons with auto-conversion
- **Real-time Conversions** - See equivalent values as you type
- **Fuel Grades** - Track Regular, Mid-grade, Premium, and Ethanol-free
- **Location Logging** - Remember where you filled up
- **Full Tank Tracking** - Mark partial vs full tank purchases
- **Cost Analytics** - Automatic total cost and per-unit calculations

### 🔧 Comprehensive Maintenance Tracking
- **15+ Service Types** - Oil changes, tire rotation, brakes, filters, and more
- **Smart Reminders** - Odometer or date-based maintenance alerts
- **Overdue Tracking** - Visual indicators for overdue services
- **Service History** - Complete maintenance timeline
- **Cost Tracking** - Record service costs and notes

### 📱 Platform Support
- **iPhone** - Full-featured native experience with Steve Jobs-inspired UI
- **iPad** - Optimized iPadOS layouts with split-screen support
- **Apple Watch** - Companion app with GPS location tracking
- **CarPlay** - In-car access to your vehicle data

### 🔄 Data Management
- **iCloud Backup** - Automatic syncing across all your devices
- **Google Drive Export** - Manual backup to Google Drive
- **Data Export** - JSON export for local backups
- **Automatic Sync** - Keep your data up-to-date across devices

### 🎯 Smart Features
- **Siri Shortcuts** - Voice commands to log fuel and maintenance
- **Voice Entry** - Dictate fuel entries using voice recognition
- **GPS Speedometer** - Real-time speed tracking with route visualization
- **Dark Mode** - Beautiful dark theme with automatic switching
- **Metric/Imperial** - Seamless unit conversion throughout

### 📊 Analytics & Insights
- **Fuel Efficiency** - Track MPG/KPL over time
- **Expense Tracker** - Monthly and yearly cost analysis
- **Dashboard** - At-a-glance overview of all key metrics
- **Drive Logging** - Automatic trip tracking with GPS
- **Cost Per Mile** - Understand your true vehicle costs

### 🎨 User Experience
- **Steve Jobs UI** - Clean, minimalist design inspired by Apple's founder
- **Grandma Mode** - Extra-large text and simplified interfaces
- **Accessibility** - Full VoiceOver support and high contrast
- **Localization** - Support for multiple languages
- **Achievement System** - Track your driving milestones

## Screenshots

*[Screenshots would be added here]*

## Requirements

- **iOS 15.0+** - iPhone and iPad
- **watchOS 9.0+** - Apple Watch
- **Xcode 14.0+**
- **Swift 5.7+**
- **CloudKit** - For iCloud backup (optional)
- **Google Drive API** - For Google Drive backup (optional)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/kei-onara.git
cd kei-onara
```

2. Open the project in Xcode:
```bash
open "Kei-onara!.xcodeproj"
```

3. Select your target device or simulator

4. Build and run the project (⌘+R)

## Version Management

The app uses an automated version management system that increments the version number by 0.001 with each change.

### Current Version
- **Marketing Version**: 1.0.133 (Freeway)
- **Build Number**: 133

### Version Management Scripts

#### Automatic Version Incrementing
- **Cursor Integration**: Automatically increments version when changes are accepted in Cursor
- **Git Hook**: A pre-commit hook automatically increments the version before each commit
- **Manual Increment**: Run `./increment_version.sh` to manually increment the version

#### Cursor Auto-Increment
```bash
# Run automatically when changes are accepted in Cursor
./cursor_auto_increment.sh

# Or manually run the auto increment
./auto_increment_version.sh
```

#### Version Information
```bash
# Show current version information
./update_version.sh show

# Manually increment version
./update_version.sh increment
```

#### Version Format
- **Marketing Version**: `1.0.XXX` (e.g., 1.0.127, 1.0.128, 1.0.130)
- **Build Number**: Increments with each version change
- **Version Name**: Each version has a codename (e.g., "Freeway")

### Version History
- **1.0.130 (Freeway)**: Added splash screen and automatic version incrementing
- **1.0.129 (Freeway)**: Fixed Apple Maps route display and GPS speedometer improvements

## Usage

### Getting Started
1. Launch the app
2. The app will create a default vehicle (2020 Suzuki Every)
3. Start by adding your first fuel entry or maintenance record

### Basic Operations
- **Start/End Drive**: Tap the green "Start Drive" button when you begin driving, then "End Drive" when you finish
- **Add Fuel**: Tap "Add Fuel" to log fuel purchases with automatic cost calculation
- **Maintenance**: Tap "Maintenance" to record service history and get due date reminders
- **Speedometer**: Tap "Speedometer" for GPS-based speed tracking and route visualization

### Settings
- **Grandma Mode**: Enable for larger text and simpler interface
- **Units**: Switch between metric (km/L) and imperial (mi/gal)
- **Notifications**: Configure maintenance and fuel reminders
- **Backup**: Export your data for safekeeping

## Architecture

The app is built using SwiftUI with the following structure:

```
Kei-onara!/
├── Models/
│   ├── VehicleData.swift           # Core data models and VehicleManager
│   ├── DataManager.swift           # Data persistence layer
│   ├── NotificationManager.swift   # Push notification handling
│   ├── AppDelegate.swift           # App lifecycle management
│   ├── CarPlayManager.swift        # CarPlay integration
│   ├── CloudKitSyncManager.swift  # iCloud sync
│   ├── ICloudBackupManager.swift  # iCloud backup
│   ├── GoogleDriveBackupManager.swift # Google Drive backup
│   ├── ColorSchemeManager.swift    # Dark mode management
│   └── SiriShortcutsManager.swift  # Siri integration
├── Views/
│   ├── DashboardView.swift         # Main dashboard
│   ├── FuelEntryView.swift         # Fuel logging
│   ├── MaintenanceView.swift       # Maintenance tracking
│   ├── SpeedometerView.swift       # GPS tracking
│   ├── ExpenseTrackerView.swift    # Cost analysis
│   ├── VehicleManagementView.swift # Multi-vehicle management
│   ├── SettingsView.swift         # App settings
│   ├── MascotView.swift           # Animated mascot
│   ├── iPadOSView.swift           # iPad-specific layouts
│   ├── VoiceEntryView.swift       # Voice input
│   ├── SiriShortcutsView.swift    # Siri configuration
│   └── ICloudBackupView.swift     # iCloud backup UI
├── Kei-onara! Watch App/          # Apple Watch companion
│   ├── ContentView.swift
│   ├── WatchLocationManager.swift
│   └── KeiOnaraWatchApp.swift
└── Assets.xcassets/               # App icons and colors
```

### Key Components

- **VehicleManager**: Central data management with caching for performance
- **DataManager**: JSON-based file persistence with encryption
- **NotificationManager**: Push notification scheduling and delivery
- **CloudKitSyncManager**: Real-time iCloud synchronization
- **CarPlayManager**: In-car experience integration
- **SiriShortcutsManager**: Voice command support
- **ColorSchemeManager**: Dynamic dark mode support

## Data Models

- **Vehicle**: Basic vehicle information (make, model, year, odometer)
- **DriveLog**: Trip tracking with start/end times and distances
- **FuelEntry**: Fuel purchase records with cost calculations
- **MaintenanceRecord**: Service history with due date tracking
- **AppSettings**: User preferences and accessibility options

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Recent Updates (v1.0.133)

✅ **Apple Watch Support** - Companion app with GPS location tracking
✅ **iPadOS Optimization** - Dedicated iPad layouts for better tablet experience
✅ **iCloud Backup & Sync** - Automatic data synchronization across devices
✅ **Google Drive Backup** - Manual backup to Google Drive
✅ **Siri Shortcuts** - Voice commands for logging fuel and maintenance
✅ **CarPlay Integration** - In-car access to your vehicle data
✅ **Voice Entry** - Dictate fuel entries using speech recognition
✅ **Dark Mode** - Beautiful dark theme with automatic switching
✅ **Performance Optimization** - Caching system for faster data access
✅ **Multi-Vehicle Management** - Track unlimited vehicles
✅ **Enhanced UI** - Steve Jobs-inspired minimalist design

## Roadmap

### Version 1.1 (Planned)
- [ ] iOS Home Screen Widget
- [ ] Monthly/Yearly Summary Reports
- [ ] Enhanced Analytics Dashboard
- [ ] Service Center QR Code Export

### Version 1.2 (Planned)
- [ ] PDF Export for Reports
- [ ] Social Sharing Features
- [ ] Advanced Route Planning
- [ ] Integration with Service Centers

### Version 1.3 (Future)
- [ ] AI-Powered Maintenance Predictions
- [ ] Carbon Footprint Tracking
- [ ] Fleet Management Dashboard
- [ ] Community Features

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the simplicity and charm of Kei trucks
- Designed with accessibility and ease of use in mind
- Built with love for the Kei truck community

## Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Check the documentation
- Contact the development team

---

**Kei-onara!** - Making Kei truck management fun and easy! 🚛✨ 