# Why Kei-onara! Is Not Showing in CarPlay

## 🔍 Current Status
Looking at your CarPlay screenshot, Kei-onara! is **NOT appearing** in the CarPlay app list.

You're seeing:
- Messages ✓
- Now Playing ✓
- Calendar ✓
- Settings ✓

But NOT Kei-onara! ❌

## 🎯 The Problem

CarPlay apps require **specific configuration** in Xcode to appear. Just having the code isn't enough - you need to:

1. ✅ **Enable CarPlay Capability** in Xcode (project settings)
2. ✅ **Configure in Apple Developer Portal**
3. ✅ **Rebuild the app** with CarPlay enabled

## 🔧 How to Fix It

### Step 1: Enable CarPlay in Xcode (2 minutes)

1. **Open your project in Xcode:**
   ```bash
   open "Kei-onara!.xcodeproj"
   ```

2. **Select the project** in the left sidebar:
   - Click on "Kei-onara!" (the blue icon at the top)

3. **Select your target:**
   - In the middle panel, click on "Kei-onara!" target

4. **Go to "Signing & Capabilities" tab**

5. **Add CarPlay Capability:**
   - Click the **"+ Capability"** button (top-left of the tab)
   - Search for "CarPlay"
   - Double-click **"CarPlay (Communication)"**
   - It will be added to your project

6. **Xcode automatically updates the entitlements file**

### Step 2: Configure Apple Developer Portal (5 minutes)

1. **Go to** [developer.apple.com](https://developer.apple.com)
2. **Sign in** with your Apple ID
3. **Navigate to:** Certificates, Identifiers & Profiles
4. **Click:** Identifiers
5. **Find your App ID:** (look for your bundle identifier)
6. **Edit** the identifier
7. **Check the box:** "CarPlay"
8. **Select:** "Communication"
9. **Click:** Continue → Save

### Step 3: Rebuild and Run

1. **Clean build folder:**
   - In Xcode: Product → Clean Build Folder (⇧⌘K)

2. **Rebuild:**
   - Product → Build (⌘B)

3. **Run on simulator:**
   - Product → Run (⌘R)

4. **Enable CarPlay:**
   - In Simulator: I/O → CarPlay → CarPlay (Car)

5. **Look for Kei-onara!** - It should now appear!

## 📝 What You Should See

After enabling CarPlay capability and rebuilding:

In CarPlay, you should see:
- Messages
- Now Playing
- Calendar
- Settings
- **Kei-onara!** ← This should appear!

## ⚠️ Important Notes

### If Still Not Showing:

1. **Are you using iOS Simulator?**
   - CarPlay Simulator works for development
   - Full testing requires physical device

2. **Did you rebuild after adding capability?**
   - Old builds don't have CarPlay
   - Must rebuild after adding capability

3. **Is CarPlay approved?**
   - Development builds work on your device
   - Production/App Store requires Apple approval

## 🚗 Testing Steps

Once configured:

1. **Run app in Xcode** (⌘R)
2. **Enable CarPlay** (I/O → CarPlay)
3. **Look for Kei-onara!** in CarPlay app list
4. **Tap to launch**
5. **Test features:**
   - Log Fuel
   - Maintenance
   - Quick Stats
   - GPS Speedometer

## 📊 Quick Check List

Before your app will show:
- [ ] Code is ready ✓
- [ ] Entitlements configured ✓
- [ ] Need to enable in Xcode
- [ ] Need to configure in Developer Portal
- [ ] Need to rebuild app

## 🎯 Bottom Line

**Your app isn't showing because:**
- CarPlay capability not enabled in Xcode project settings
- App needs to be rebuilt with CarPlay support

**To fix:**
1. Open Xcode
2. Project → Signing & Capabilities → + Capability → CarPlay
3. Rebuild (⌘B)
4. Run (⌘R)
5. Enable CarPlay in Simulator

Then Kei-onara! will appear! 🚗✨

