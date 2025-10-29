#!/bin/bash
echo "🔍 CarPlay Diagnostic Tool"
echo "=========================="
echo ""

# Check Xcode version
echo "📦 Checking Xcode version..."
xcodebuild -version 2>/dev/null || echo "❌ xcodebuild not working"
echo ""

# Check CarPlay framework
echo "🔍 Checking for CarPlay framework..."
if [ -d "/Applications/Xcode.app/Contents/Frameworks" ]; then
    if find /Applications/Xcode.app/Contents/Frameworks -name "*CarPlay*" 2>/dev/null | grep -q .; then
        echo "✅ CarPlay framework found"
    else
        echo "❌ CarPlay framework not found"
    fi
else
    echo "⚠️  Cannot check framework location"
fi
echo ""

# Check entitlements
echo "🔍 Checking entitlements file..."
if [ -f "Kei-onara!/Kei-onara!.entitlements" ]; then
    if grep -q "carplay-communications" "Kei-onara!/Kei-onara!.entitlements"; then
        echo "✅ CarPlay entitlements configured"
        grep -A 2 "carplay-communications" "Kei-onara!/Kei-onara!.entitlements"
    else
        echo "❌ CarPlay not in entitlements"
    fi
else
    echo "❌ Entitlements file not found"
fi
echo ""

# Check project file
echo "🔍 Checking project configuration..."
if grep -q "INFOPLIST_KEY_NSCarPlayUsageDescription" "Kei-onara!.xcodeproj/project.pbxproj" 2>/dev/null; then
    echo "✅ CarPlay usage description found"
else
    echo "❌ CarPlay usage description missing"
fi
echo ""

# Recommendation
echo "💡 Recommendation:"
echo "   Enable CarPlay in Apple Developer Portal first:"
echo "   https://developer.apple.com/account/resources/identifiers/list"
echo "   Then wait 5 minutes and try again in Xcode"
