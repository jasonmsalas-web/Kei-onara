# How to Launch CarPlay Right Now

## Current Status
❌ No simulator is currently booted

## Best Method: Run from Xcode

### Step 1: Open Xcode and Run Your App

1. **Open the project:**
   ```bash
   open "Kei-onara!.xcodeproj"
   ```

2. **Press ⌘R** (Command + R) to build and run
   - This will boot the iOS Simulator automatically
   - Your app will launch in the simulator

### Step 2: Launch CarPlay

**Option A: Use the Simulator Menu**
1. Look at the **top of your Mac screen** (menu bar)
2. Click **"I/O"** menu
3. Select **"CarPlay"** → **"CarPlay (Car)"**

**Option B: Use Terminal After Running**
Once your app is running in the simulator, run:
```bash
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl ui booted CarPlay
```

## Visual Guide

```
In Xcode:
1. Click Play button (⌘R)
   ↓
2. iOS Simulator opens
   ↓
3. Top of Mac screen → I/O → CarPlay
   ↓
4. CarPlay window appears!
```

## Alternative: Two-Terminal Method

### Terminal 1: Boot and Run CarPlay
```bash
# Boot iPhone 16 Pro simulator
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl boot "iPhone 16 Pro"

# Launch CarPlay
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl ui booted CarPlay

# Open Xcode project
open "Kei-onara!.xcodeproj"
```

### Terminal 2: Run Your App
Now in Xcode:
1. **⌘R** to build and run
2. Your app will appear in the CarPlay window!

## Quickest Method (Recommended)

**Just run your app in Xcode:**

1. In Xcode: **⌘R** (or click Play ▶️)
2. Simulator opens with your app
3. Mac menu bar: **I/O** → **CarPlay** → **CarPlay (Car)**
4. Done! 🎉

---

**Note**: You need Xcode running to test CarPlay. The CarPlay simulator is a feature within the iOS Simulator, not a standalone tool.

