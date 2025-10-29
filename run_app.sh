#!/bin/bash

echo "🚛 Building Kei-onara! app..."
xcodebuild -project "Kei-onara!.xcodeproj" -scheme "Kei-onara!" -destination "platform=iOS Simulator,name=iPhone 16" build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "🎉 Installing and launching Kei-onara!..."
    
    # Install the app
    xcrun simctl install "iPhone 16" "/Users/jsalas/Library/Developer/Xcode/DerivedData/Kei-onara!-fflelpbhyuayqcgrdqaireordruj/Build/Products/Debug-iphonesimulator/Kei-onara!.app"
    
    # Launch the app
    xcrun simctl launch "iPhone 16" CarmaLog.Kei-onara-
    
    echo "🚀 Kei-onara! is now running!"
else
    echo "❌ Build failed!"
    exit 1
fi 