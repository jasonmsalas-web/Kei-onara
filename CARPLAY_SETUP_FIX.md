# Fix: Why CarPlay App Is Not Showing

## 🔍 The Problem

CarPlay apps require specific configuration that's often missing:

1. **Info.plist must declare the CarPlay scene**
2. **CarPlay capability must be enabled in Apple Developer Portal**
3. **App must be built with Development or Ad-Hoc provisioning**
4. **App must be approved for CarPlay** (for production, requires Apple approval)

## ✅ Solution Steps

### Step 1: Add CarPlay Scene to Info.plist

The app needs to register its CarPlay scene in the Info.plist. Modern Xcode projects store this in the project.pbxproj file. We need to add:

```xml
<key>UISceneConfiguration</key>
<dict>
    <key>CPTemplateApplicationSceneSessionRoleApplication</key>
    <array>
        <dict>
            <key>UISceneConfigurationName</key>
            <string>CarPlay</string>
            <key>UISceneDelegateClassName</key>
            <string>CarPlaySceneDelegate</string>
        </dict>
    </array>
</dict>
```

### Step 2: Enable CarPlay in Xcode

1. Open the project in Xcode
2. Select the project target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "CarPlay (Communication)"
   - OR "CarPlay (Audio App)" if your app is audio-based
6. Xcode will automatically configure the entitlements

### Step 3: Verify Entitlements File

Your entitlements file should include:
```xml
<key>com.apple.developer.carplay-communications</key>
<array>
    <string>carmessages</string>
</array>
```

### Step 4: Apple Developer Portal Configuration

1. Go to [developer.apple.com](https://developer.apple.com)
2. Navigate to Certificates, Identifiers & Profiles
3. Select your App ID
4. Enable "CarPlay (Communication)" capability
5. Save changes

### Step 5: Build Requirements

CarPlay apps have special requirements:
- ❌ **Won't work on iOS Simulator** (needs physical device)
- ✅ **Physical iPhone required**
- ✅ **CarPlay-enabled vehicle OR CarPlay simulator**
- ✅ **Development or Ad-Hoc build** (not App Store until approved)

### Step 6: Enable CarPlay App in iPhone Settings

1. On your iPhone: Settings → Screen Time → Content & Privacy Restrictions
2. Allow CarPlay apps to be installed
3. Settings → General → CarPlay → Your Vehicle
4. Look for "Custom App Shortcuts"
5. Enable your app if it appears

### Step 7: Testing Options

#### Option A: Physical Car with CarPlay
1. Connect iPhone to car's USB port
2. Unlock your iPhone
3. Approve the connection prompt
4. Launch Kei-onara! from CarPlay screen

#### Option B: CarPlay Simulator (Xcode 12+)
1. Open Xcode
2. Window → External Displays → CarPlay
3. OR use terminal:
   ```bash
   xcrun simctl ui booted CarPlay
   ```

#### Option C: Quick Time + CarPlay (Limited)
1. Connect iPhone to Mac
2. QuickTime → New Movie Recording
3. Select iPhone as source
4. Not full CarPlay experience

## 🚨 Important Notes

### CarPlay App Approval Process

For **production apps**, Apple requires:
1. CarPlay capability request via developer support
2. Technical review of CarPlay implementation
3. Compliance with CarPlay HIG
4. Approval before App Store release

For **development/testing**:
- Works with Development builds on your device
- Use TestFlight for beta testing
- Ad-hoc distribution works

### Why It's Not Appearing

Common reasons:
1. ❌ CarPlay capability not enabled in Developer Portal
2. ❌ Using iOS Simulator (CarPlay requires physical device)
3. ❌ Info.plist scene configuration missing
4. ❌ Build provisioning doesn't include CarPlay
5. ❌ App not whitelisted in CarPlay settings

## 🔧 Quick Fix Script

Run this in Xcode console to debug:

```swift
// In Xcode console while debugging:
po UIApplication.shared.supportsCarPlay
// Should return true

po CPInterfaceController()
// Check if CarPlay classes are available
```

## 📝 Current Status

✅ Code is ready:
- CarPlayManager.swift ✓
- CarPlaySceneDelegate.swift ✓
- AppDelegate.swift ✓
- Entitlements configured ✓

⚠️ Needs configuration:
- Info.plist scene registration
- CarPlay capability in Apple Developer Portal
- Physical device build
- CarPlay HIG compliance review (for production)

## 🎯 Quick Test

To immediately test if your build supports CarPlay:

1. Build and run on your iPhone
2. Connect to CarPlay
3. Check Settings → CarPlay → Your Vehicle
4. Look for "Custom Apps" section
5. Your app should appear there

If it doesn't appear, the issue is likely in Apple Developer Portal configuration.

