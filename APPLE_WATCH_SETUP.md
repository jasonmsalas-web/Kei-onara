# Apple Watch Companion App for Kei-onara!

## Overview
The Apple Watch companion app provides a simple, focused interface showing current speed and direction. Perfect for quick glances while driving without taking your eyes off the road.

## Features

### 🚗 **Speed Display**
- **Large, Clear Numbers**: 48pt thin font for easy reading
- **Real-time Updates**: Updates every 1 meter of movement
- **Unit Support**: MPH and KM/H conversion
- **Auto-scaling**: Text scales to fit screen size

### 🧭 **Direction Display**
- **Compass Arrow**: Rotating arrow showing current heading
- **Direction Labels**: N, NE, E, SE, S, SW, W, NW
- **8-Point System**: Accurate direction indicators
- **Smooth Rotation**: Animated arrow rotation

### 🎨 **Design**
- **Black Background**: High contrast for visibility
- **White Speed Text**: Clear, readable numbers
- **Blue Direction Arrow**: Distinctive color for direction
- **Minimal Interface**: Focused on essential information

## Technical Implementation

### **File Structure**
```
Kei-onara! Watch App/
├── KeiOnaraWatchApp.swift      # Main app entry point
├── ContentView.swift           # Main UI view
├── WatchLocationManager.swift  # GPS and compass handling
├── ExtensionDelegate.swift     # Watch app lifecycle
└── Info.plist                 # App configuration
```

### **Core Components**

#### **1. KeiOnaraWatchApp.swift**
- Main app entry point
- Sets up the app structure

#### **2. ContentView.swift**
- **Speed Display**: Large numbers with unit labels
- **Direction Display**: Rotating arrow with direction text
- **Responsive Design**: Adapts to different watch sizes
- **Real-time Updates**: Receives data from location manager

#### **3. WatchLocationManager.swift**
- **GPS Tracking**: Monitors location and speed
- **Compass Data**: Tracks heading and direction
- **Permission Handling**: Manages location authorization
- **Data Conversion**: Converts m/s to mph/kmh

#### **4. ExtensionDelegate.swift**
- **Lifecycle Management**: Handles app state changes
- **Background Tasks**: Manages background processing
- **Performance**: Optimizes for watch battery life

## Setup Instructions

### **1. Xcode Project Configuration**
1. Open the project in Xcode
2. Add a new Watch App target:
   - File → New → Target
   - Choose "Watch App"
   - Name it "Kei-onara! Watch App"
3. Configure the target:
   - Set deployment target to watchOS 9.0+
   - Enable location capabilities
   - Configure bundle identifier

### **2. Capabilities Setup**
1. Select the Watch App target
2. Go to "Signing & Capabilities"
3. Add "Background Modes" capability
4. Check "Location updates"
5. Add "Location" capability if needed

### **3. Info.plist Configuration**
The Info.plist includes:
- Location usage description
- Background modes for location
- Watch app configuration
- Bundle information

### **4. Permission Handling**
The app automatically:
- Requests location permission on first launch
- Handles permission changes
- Provides user feedback for permission status
- Gracefully handles denied permissions

## Usage

### **For Users:**
1. **Install**: Install the main app on iPhone
2. **Pair**: Apple Watch will automatically install companion app
3. **Launch**: Open the Kei-onara! app on Apple Watch
4. **Grant Permission**: Allow location access when prompted
5. **Use**: View speed and direction at a glance

### **For Developers:**
- **Location Updates**: Every 1 meter of movement
- **Heading Updates**: Every 1 degree of rotation
- **Background Mode**: Continues updating in background
- **Battery Optimization**: Efficient location tracking

## Design Philosophy

### **Steve Jobs Inspired**
- **Minimal Interface**: Only essential information
- **High Contrast**: Black background with white text
- **Large Typography**: Easy to read at a glance
- **Focused Purpose**: Speed and direction only

### **Watch-Optimized**
- **Quick Glance**: Information visible in under 1 second
- **One-Hand Use**: No scrolling or complex interactions
- **Battery Efficient**: Minimal processing and updates
- **Always On**: Works with Always-On Display

## Technical Details

### **Location Services**
- **Accuracy**: Best available GPS accuracy
- **Filtering**: 1-meter distance filter
- **Heading**: 1-degree heading filter
- **Background**: Continues in background mode

### **Data Processing**
- **Speed Conversion**: m/s to mph/kmh
- **Heading Processing**: True heading preferred, magnetic fallback
- **Error Handling**: Graceful handling of GPS errors
- **Performance**: Optimized for watch CPU

### **User Experience**
- **Immediate Feedback**: Updates in real-time
- **Visual Clarity**: High contrast design
- **Intuitive Interface**: No learning curve
- **Reliable**: Works in various conditions

## Testing

### **Simulator Testing**
1. Use Watch Simulator in Xcode
2. Test location simulation
3. Verify speed and direction updates
4. Test permission handling

### **Device Testing**
1. Test on physical Apple Watch
2. Verify GPS accuracy
3. Test background functionality
4. Check battery impact

## Future Enhancements

### **Planned Features**
- **Speed Alerts**: Custom speed limit warnings
- **Trip Tracking**: Start/stop trip recording
- **Haptic Feedback**: Speed-based vibrations
- **Custom Units**: User preference for speed units

### **Advanced Features**
- **Voice Commands**: Siri integration
- **Complications**: Watch face complications
- **Health Integration**: Activity tracking
- **Family Sharing**: Share with family members

## Troubleshooting

### **Common Issues**
1. **No Speed Display**: Check location permissions
2. **Inaccurate Speed**: Ensure GPS signal strength
3. **No Direction**: Check compass calibration
4. **Battery Drain**: Verify background mode settings

### **Debug Information**
- Location manager logs all errors
- Permission status is tracked
- GPS accuracy is monitored
- Performance metrics are available

The Apple Watch companion app provides a focused, reliable way to monitor speed and direction while driving, maintaining the app's elegant design philosophy while being optimized for the watch form factor. 