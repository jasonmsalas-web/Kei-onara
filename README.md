# Kei-onara! 🚛

A comprehensive iOS app for managing your Kei truck with a focus on simplicity, accessibility, and fun!

## Features

### 🎯 Core Features
- **Giant Button Interface** - Huge, clear buttons with big text for easy use
- **One-Tap Drive Logging** - Just tap "Start Drive" and "End Drive" to auto-log kilometers
- **Automatic Unit Conversion** - Shows both metric and imperial units side by side
- **Instant MPG Dashboard** - Giant circular display showing current and average fuel efficiency

### ⛽ Fuel Management
- **Fuel Journal** - Simple screen to enter liters/gallons, price, and odometer
- **Auto Cost Calculation** - Automatically calculates cost per km/mile
- **Fuel Efficiency Trends** - Simple graphs showing fuel economy over time

### 🔧 Maintenance Tracking
- **Maintenance Logbook** - Record oil changes, tire rotations, brake checks, etc.
- **Due Date Alerts** - Shows next maintenance due dates clearly on dashboard
- **Push Notifications** - Friendly reminders with emojis for upcoming maintenance

### 🎨 Accessibility Features
- **Grandma Mode** - Even larger text, simpler screens, high-contrast colors
- **Voice Entry** - "Hey app, log my fuel: 30 liters at 100,000 km"
- **Dark Mode** - Auto-switch based on time or user preference

### 📊 Advanced Features
- **GPS Speedometer** - Real-time speed tracking with route visualization
- **Expense Tracker** - Monthly/yearly fuel and maintenance cost analysis
- **Multi-Vehicle Support** - Switch easily between multiple Kei trucks
- **Backup & Restore** - iCloud backup and export to PDF for printouts

### 🎮 Fun Features
- **Cute Mascot** - Animated Kei truck character provides encouragement
- **Achievement Badges** - "Good driver!" and "Fuel saver!" badges for motivation
- **Mileage Goals** - Set and track monthly/yearly driving distance goals

## Screenshots

*[Screenshots would be added here]*

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

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
- **Marketing Version**: 1.0.130 (Freeway)
- **Build Number**: 130

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
│   ├── VehicleData.swift      # Core data models and VehicleManager
│   ├── DataManager.swift      # Data persistence layer
│   └── NotificationManager.swift # Push notification handling
├── Views/
│   ├── DashboardView.swift    # Main dashboard with giant buttons
│   ├── FuelEntryView.swift    # Fuel logging interface
│   ├── MaintenanceView.swift  # Maintenance tracking
│   ├── SpeedometerView.swift  # GPS speedometer and route tracking
│   ├── ExpenseTrackerView.swift # Cost analysis and charts
│   ├── SettingsView.swift     # App settings and preferences
│   └── MascotView.swift       # Cute animated mascot
└── Assets.xcassets/           # App icons and colors
```

### Key Components

- **VehicleManager**: Central data management and business logic
- **DataManager**: UserDefaults-based persistence
- **LocationManager**: GPS tracking for speedometer feature
- **NotificationManager**: Push notification scheduling

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

## Roadmap

### Version 1.1
- [ ] QR code export for service centers
- [ ] Tire wear tracking
- [ ] iOS widget for home screen
- [ ] Monthly summary reports

### Version 1.2
- [ ] Cloud sync with iCloud
- [ ] Advanced analytics and insights
- [ ] Export to PDF functionality
- [ ] Social sharing features

### Version 1.3
- [ ] Multiple vehicle profiles
- [ ] Advanced route planning
- [ ] Integration with service centers
- [ ] Voice commands for hands-free operation

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