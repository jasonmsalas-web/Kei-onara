# 🚗 Why Your CarPlay App Isn't Showing - Quick Fix

## TL;DR - Main Reasons

### ❌ CarPlay apps DON'T appear if:

1. **Built on iOS Simulator** - CarPlay requires a physical iPhone
2. **CarPlay capability not enabled** - Must be set in Apple Developer Portal
3. **Using App Store provisioning** - Needs Development or Ad-Hoc build
4. **App not approved** - For production, Apple requires CarPlay approval

### ✅ To Make It Show:

## Step-by-Step Fix

### 1. Enable CarPlay in Xcode (5 minutes)

1. Open `Kei-onara!.xcodeproj` in Xcode
2. Select your target (Kei-onara!)
3. Go to **"Signing & Capabilities"** tab
4. Click **"+ Capability"** button
5. Add **"CarPlay (Communication)"**
   - You'll see it in the list
   - Double-click to add
6. Xcode automatically updates entitlements

### 2. Configure in Apple Developer Portal (10 minutes)

1. Go to [developer.apple.com](https://developer.apple.com)
2. Log in with your Apple ID
3. Navigate to **Certificates, Identifiers & Profiles**
4. Click **Identifiers** → find your app's Bundle ID
5. Edit the capability settings
6. Check **"CarPlay"** checkbox
7. Select **"Communications"** type
8. Click **Save**
9. Click **Continue** and confirm

### 3. Build Requirements

**Must build on physical iPhone:**
- ❌ iOS Simulator won't work
- ✅ Connect real iPhone
- ✅ Enable Developer Mode on iPhone
- ✅ Select your iPhone as build target
- ✅ Build and Run (⌘R)

### 4. Enable CarPlay App on iPhone

1. On iPhone: **Settings** → **General** → **CarPlay**
2. Select your vehicle
3. Scroll down to **"Custom App Shortcuts"**
4. Look for Kei-onara!
5. Enable it if it appears

### 5. Test in Car

1. Connect iPhone to CarPlay (USB or Wireless)
2. Unlock iPhone
3. Approve CarPlay connection
4. Look for Kei-onara! on CarPlay screen
5. Tap to launch

## What's Already Done ✅

- CarPlay code is implemented
- Entitlements configured
- Scene delegate setup
- All CarPlay templates ready
- GPS speedometer working
- Fuel and maintenance logging ready

## What's Missing ⚠️

### You Need To:
1. ✅ Enable CarPlay capability in Xcode (see Step 1 above)
2. ✅ Configure CarPlay in Apple Developer Portal (see Step 2 above)
3. ✅ Build on physical iPhone (see Step 3 above)
4. ✅ Connect to CarPlay-enabled vehicle (see Step 5 above)

## Debugging Commands

### Check if CarPlay is supported:
```swift
// In Xcode console while app is running:
po UIApplication.shared.supportsCarPlay
// Should print: true
```

### Check if scene is configured:
```swift
// In Xcode console:
po UIApplication.shared.supportsSceneSessions
// Should print: true
```

### Check connection:
Look for these logs in Xcode console:
```
🚗 AppDelegate initialized
🚗 Configuring scene for CarPlay
🚗 CarPlay scene connected
✅ CarPlay connected successfully
```

## Alternative: Test Without a Car

### Using CarPlay Simulator:

```bash
# In Terminal on your Mac:
xcrun simctl ui booted CarPlay
```

Then in Xcode, run the app. You'll see a CarPlay window appear.

## Still Not Showing?

### Common Issues:

1. **"App doesn't appear in CarPlay settings"**
   → CarPlay capability not enabled in Apple Developer Portal
   → Fix: Complete Step 2 above

2. **"Works in simulator but not in car"**
   → Development provisioning issue
   → Fix: Use Ad-Hoc or Apple approved certificate

3. **"No CarPlay capability option"**
   → Requires paid Apple Developer account ($99/year)
   → Free accounts can't use CarPlay

4. **"App appears but crashes"**
   → Check Xcode console for error messages
   → Look for CarPlay-specific errors
   → Common: Missing CarPlay entitlement

## Production Release Notes

For App Store release:
- ⚠️ Apple requires CarPlay app approval
- Submit a request to Apple Developer Support
- Include use case and security review
- Takes 2-4 weeks for approval
- Workaround: Use Siri Shortcuts for voice-only access

## Summary

✅ **Code**: Complete and fixed
⚠️ **Configuration**: Needs Xcode + Developer Portal setup
🚗 **Testing**: Requires physical iPhone + CarPlay vehicle

The app code is ready. You just need to configure CarPlay in Xcode and Apple Developer Portal, then build on a physical device.

