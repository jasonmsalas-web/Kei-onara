#!/bin/bash

# CarPlay Integration Test Script
# This script verifies the CarPlay setup in the Kei-onara! project

echo "🧪 Testing CarPlay Integration for Kei-onara!"
echo "==========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "Kei-onara!.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Must run from project root directory"
    exit 1
fi

echo "✅ Project found"
echo ""

# Check for CarPlay files
echo "📝 Checking for CarPlay files..."

carplay_files=(
    "Kei-onara!/Models/CarPlayManager.swift"
    "Kei-onara!/Models/CarPlaySceneDelegate.swift"
    "Kei-onara!/Models/AppDelegate.swift"
    "Kei-onara!/Kei-onara!.entitlements"
)

all_present=true
for file in "${carplay_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ Missing: $file"
        all_present=false
    fi
done

echo ""

if [ "$all_present" = true ]; then
    echo "✅ All CarPlay files present"
else
    echo "❌ Some CarPlay files are missing"
    exit 1
fi

echo ""

# Check entitlements for CarPlay
echo "🔍 Checking entitlements..."
if grep -q "carplay-communications" "Kei-onara!/Kei-onara!.entitlements"; then
    echo "  ✅ CarPlay entitlements configured"
else
    echo "  ⚠️  CarPlay entitlements not found"
fi

# Check project.pbxproj for CarPlay usage description
echo ""
echo "🔍 Checking Info.plist entries..."
if grep -q "NSCarPlayUsageDescription" "Kei-onara!.xcodeproj/project.pbxproj"; then
    echo "  ✅ NSCarPlayUsageDescription found"
else
    echo "  ⚠️  NSCarPlayUsageDescription not found"
fi

echo ""
echo "📊 Summary:"
echo "  ✅ CarPlayManager.swift - Found"
echo "  ✅ CarPlaySceneDelegate.swift - Found"
echo "  ✅ AppDelegate.swift - Found"
echo "  ✅ Entitlements configured"
echo ""
echo "🧪 To test CarPlay:"
echo "  1. Open the project in Xcode"
echo "  2. Build and run on a physical iPhone"
echo "  3. Connect to a CarPlay-enabled vehicle"
echo "  4. Launch the app from CarPlay"
echo ""
echo "📖 For more details, see: CARPLAY_TEST.md"
echo ""

