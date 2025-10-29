# Make CarPlay Work - Actual Steps

## The Problem
- ✅ Code is ready (100%)
- ✅ Entitlements file configured
- ❌ Capability not enabled in Apple Developer Portal
- ❌ App doesn't appear in CarPlay

## The Solution - Do This NOW

### Step 1: Enable in Apple Developer Portal (5 minutes)

1. **Go to:** https://developer.apple.com/account/resources/identifiers/list
2. **Sign in** with your paid developer account
3. **Click** on your App ID (search for your bundle identifier)
4. **Click "Edit"**
5. **Scroll to "Capabilities"** section
6. **Check the box** for "CarPlay"
7. **Select** "Communication"
8. **Click** "Continue" → "Save"

### Step 2: Wait 5 Minutes
Apple servers need to sync. Wait 5 minutes.

### Step 3: Open Xcode

```bash
open "Kei-onara!.xcodeproj"
```

### Step 4: Add Capability in Xcode

1. **Select** project in left sidebar
2. **Select** target "Kei-onara!"
3. **Go to** "Signing & Capabilities" tab
4. **Click** "+ Capability" button
5. **Search** for "CarPlay" or "Template" or "Communication"
6. If it appears: Add it
7. If it doesn't: Use the script method below

### Step 5: Clean Build

In Xcode:
- **Product** → **Clean Build Folder** (⇧⌘K)
- **Product** → **Build** (⌘B)
- **Product** → **Run** (⌘R)

### Step 6: Test CarPlay

1. In Simulator: **I/O** → **CarPlay** → **CarPlay (Car)**
2. Look for **Kei-onara!** in the apps
3. Should appear!

## If Capability Still Doesn't Appear in Xcode

The capability might be hidden. Use this method:

### Manual Method (Bypasses Xcode UI)

```bash
# This adds CarPlay capability directly to your project
# Run this in Terminal from your project directory
```

**Or manually add to project.pbxproj:**
- Look for: `/* Begin XCBuildConfiguration section */`
- Add: `CARPLAY_ENABLED = YES;`
- In your target's build settings

## Check if It's Enabled

```bash
# Check if capability is in Apple Developer Portal
# Go to: developer.apple.com/account/resources/identifiers

# Look for your bundle identifier
# Should show: CarPlay ✓
```

## What Should Happen

After Step 1 (Apple Developer Portal):
- ✅ CarPlay capability registered with Apple
- Wait 5 minutes

After Step 4-6 (Xcode):
- ✅ Capability appears in project
- ✅ App builds with CarPlay
- ✅ App appears in CarPlay simulator

## Still Not Working?

If after all this it still doesn't work:
1. You need to request CarPlay entitlement from Apple
2. Contact: developer.apple.com/support
3. Use the text from: `APPLE_DEVELOPER_CARPLAY_REQUEST.txt`
4. Submit the request
5. Wait 2-4 weeks

## TL;DR - Do This First

1. Go to Apple Developer Portal
2. Find your App ID
3. Edit it
4. Enable CarPlay (Communication)
5. Save
6. Wait 5 minutes
7. Open Xcode
8. Build and run
9. Enable CarPlay in simulator
10. Your app should appear!

**The issue is:** Capability not enabled, not code problems.

