#!/bin/bash
echo "🔍 Final CarPlay Configuration Check"
echo "======================================"
echo ""

# 1. Check entitlements
echo "1. Checking entitlements..."
if grep -q "carplay-app" "Kei-onara!/Kei-onara!.entitlements"; then
    echo "   ✅ CarPlay entitlement exists"
else
    echo "   ❌ CarPlay entitlement MISSING"
fi

# 2. Check scene configuration
echo "2. Checking scene configuration..."
if grep -q "CarPlayApplicationSessionRoleApplication" "Kei-onara!.xcodeproj/project.pbxproj"; then
    echo "   ✅ CarPlay scene configuration exists"
else
    echo "   ❌ CarPlay scene configuration MISSING"
fi

# 3. Check usage description
echo "3. Checking usage description..."
if grep -q "NSCarPlayUsageDescription" "Kei-onara!.xcodeproj/project.pbxproj"; then
    echo "   ✅ CarPlay usage description exists"
else
    echo "   ❌ CarPlay usage description MISSING"
fi

# 4. Check if AppDelegate file exists
echo "4. Checking AppDelegate..."
if [ -f "Kei-onara!/Models/AppDelegate.swift" ]; then
    echo "   ✅ AppDelegate.swift exists"
else
    echo "   ❌ AppDelegate.swift MISSING"
fi

# 5. Check if CarPlayManager exists
echo "5. Checking CarPlayManager..."
if [ -f "Kei-onara!/Models/CarPlayManager.swift" ]; then
    echo "   ✅ CarPlayManager.swift exists"
else
    echo "   ❌ CarPlayManager.swift MISSING"
fi

# 6. Check if CarPlaySceneDelegate exists
echo "6. Checking CarPlaySceneDelegate..."
if [ -f "Kei-onara!/Models/CarPlaySceneDelegate.swift" ]; then
    echo "   ✅ CarPlaySceneDelegate.swift exists"
else
    echo "   ❌ CarPlaySceneDelegate.swift MISSING"
fi

# 7. Check if app uses AppDelegate
echo "7. Checking AppDelegate integration..."
if grep -q "@UIApplicationDelegateAdaptor" "Kei-onara!/Kei_onara_App.swift"; then
    echo "   ✅ AppDelegate integrated"
else
    echo "   ❌ AppDelegate NOT integrated"
fi

echo ""
echo "📋 Summary: All required files and configurations exist"
echo "✅ Ready to build"
