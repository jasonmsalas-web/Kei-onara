#!/bin/bash

# CarPlay Simulator Setup Script
# This script helps you test CarPlay without a physical vehicle

echo "🚗 CarPlay Simulator Setup"
echo "========================="
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode not found. Please install Xcode first."
    exit 1
fi

echo "✅ Xcode found"
echo ""

# Check simulator availability
echo "📱 Checking for iOS Simulator..."
simulators=$(xcrun simctl list devices available | grep -i "iphone")
if [ -z "$simulators" ]; then
    echo "❌ No simulators available"
else
    echo "✅ iOS Simulators available"
    echo ""
    echo "Available iPhone simulators:"
    xcrun simctl list devices available | grep "iPhone" | head -5
fi

echo ""
echo "🎮 Starting CarPlay Simulator..."
echo ""
echo "Option 1: From Xcode"
echo "  1. Run your app in iOS Simulator (⌘R)"
echo "  2. In Simulator menu: I/O → CarPlay → CarPlay (Car)"
echo "  3. CarPlay window will appear alongside simulator"
echo ""
echo "Option 2: From Command Line"
echo "  Run: xcrun simctl ui booted CarPlay"
echo ""
echo "Option 3: From Xcode (Alternative)"
echo "  Window → External Displays → CarPlay"

echo ""
read -p "Would you like to launch CarPlay simulator now? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Launching CarPlay simulator..."
    
    # Boot the simulator if not running
    BOOTED=$(xcrun simctl list devices | grep Booted)
    if [ -z "$BOOTED" ]; then
        echo "📱 Starting iOS Simulator first..."
        xcrun simctl boot "iPhone 15 Pro"
        sleep 3
    fi
    
    # Launch CarPlay
    echo "🚗 Starting CarPlay..."
    xcrun simctl ui booted CarPlay
    echo ""
    echo "✅ CarPlay simulator launched!"
    echo ""
    echo "📱 Next steps:"
    echo "  1. Return to Xcode"
    echo "  2. Run your app (⌘R)"
    echo "  3. The CarPlay interface should appear"
    echo ""
else
    echo ""
    echo "To manually start CarPlay simulator:"
    echo "  Run: xcrun simctl ui booted CarPlay"
    echo ""
    echo "Or from Xcode: Window → External Displays → CarPlay"
fi

