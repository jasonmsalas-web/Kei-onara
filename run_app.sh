#!/bin/bash

echo "🚛 Building Kei-onara! app..."
xcodebuild -project "Kei-onara!.xcodeproj" -scheme "Kei-onara!" -destination "platform=iOS Simulator,name=iPhone 15" build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "🎉 Kei-onara! is ready to run!"
    echo ""
    echo "To run the app:"
    echo "1. Open Xcode"
    echo "2. Open 'Kei-onara!.xcodeproj'"
    echo "3. Select iPhone 15 simulator"
    echo "4. Press ⌘+R to run"
    echo ""
    echo "Or use the command line:"
    echo "xcrun simctl install booted ./DerivedData/Build/Products/Debug-iphonesimulator/Kei-onara!.app"
    echo "xcrun simctl launch booted CarmaLog.Kei-onara-"
else
    echo "❌ Build failed!"
    exit 1
fi 