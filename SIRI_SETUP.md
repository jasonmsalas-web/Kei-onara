# Siri Shortcuts Setup for Kei-onara!

## Overview
This app now supports Siri Shortcuts, allowing users to create custom voice commands for quick actions like "Log my gas" or "Start my ride".

## Features Added

### 1. SiriShortcutsManager
- Manages Siri shortcut creation and donation
- Handles shortcut interactions
- Provides three main shortcuts:
  - "Log my gas" - Opens fuel entry screen
  - "Start my ride" - Begins GPS tracking
  - "Log maintenance" - Opens maintenance screen

### 2. SiriShortcutsView
- User interface for managing Siri shortcuts
- Shows available shortcuts with descriptions
- Provides instructions for setup
- Allows custom shortcut creation

### 3. Integration Points
- Added to Settings view under "Voice & Accessibility"
- Integrated with AppDelegate for shortcut handling
- Notification system for shortcut triggers

## Setup Instructions

### 1. Xcode Project Configuration
1. Open the project in Xcode
2. Select the target "Kei-onara!"
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Siri" capability

### 2. Info.plist Configuration
Add the following to your Info.plist:

```xml
<key>NSUserActivityTypes</key>
<array>
    <string>LogGasIntent</string>
    <string>StartRideIntent</string>
    <string>LogMaintenanceIntent</string>
</array>
```

### 3. Usage Instructions

#### For Users:
1. Open Settings in the app
2. Tap "Siri Shortcuts" under Voice & Accessibility
3. Tap any shortcut to add it to Siri
4. Say "Hey Siri" followed by the command:
   - "Log my gas"
   - "Start my ride"
   - "Log maintenance"

#### For Developers:
- Shortcuts are automatically donated when the app launches
- Shortcut interactions are handled via NotificationCenter
- Custom shortcuts can be created through the SiriShortcutsView

## Technical Implementation

### Custom Intents
- `LogGasIntent`: Triggers fuel entry screen
- `StartRideIntent`: Begins GPS tracking
- `LogMaintenanceIntent`: Opens maintenance screen

### Notification System
- `.showFuelEntry`: Triggers fuel entry
- `.startRide`: Triggers ride start
- `.showMaintenance`: Triggers maintenance screen

### Integration Points
- AppDelegate handles shortcut registration
- SplashScreenView listens for shortcut notifications
- SettingsView provides access to Siri shortcuts

## Testing
1. Build and run the app
2. Go to Settings > Siri Shortcuts
3. Add shortcuts to Siri
4. Test voice commands:
   - "Hey Siri, log my gas"
   - "Hey Siri, start my ride"
   - "Hey Siri, log maintenance"

## Future Enhancements
- Custom shortcut creation with user-defined phrases
- Integration with CarPlay for voice commands
- Advanced shortcut parameters (fuel amount, location, etc.)
- Shortcut analytics and usage tracking 