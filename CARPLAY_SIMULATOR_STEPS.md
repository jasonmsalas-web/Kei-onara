# Step-by-Step: How to Launch CarPlay Simulator in Xcode

## Visual Guide - Finding the CarPlay Menu

### Step 1: Run Your App
1. Open Xcode
2. Press **⌘R** (Command + R) OR
3. Click the **Play button** (▶️) in the top-left

### Step 2: Simulator Appears
After building, the **iOS Simulator** window will open showing your iPhone

### Step 3: Look for the Simulator Menu Bar

**Important**: The menu bar you need is in the **Simulator window**, NOT the Xcode window!

At the **TOP of your Mac screen**, you'll see the menu bar when Simulator has focus. It should say **"iOS Simulator"** in the top-left corner (not "Xcode").

### Step 4: Find the "I/O" Menu

In the **Simulator menu bar** (at the top of your Mac screen):
1. Look for **"I/O"** menu
2. Click **"I/O"** 
3. You'll see a dropdown with:
   - Keyboard
   - Touch ID
   - Screenshots
   - **CarPlay** ← This one!

### Step 5: Select CarPlay

Click **"I/O"** → **"CarPlay"** → **"CarPlay (Car)"**

The CarPlay window will appear next to your iOS Simulator!

## Alternative: From Xcode Menu

If you can't find the I/O menu:

1. Make sure **iOS Simulator window is in focus** (click on it)
2. In **Xcode menu bar** (at top), go to:
   - **Window** → **External Displays** → **CarPlay**

## Still Can't Find It?

### Check Your Setup:

1. **Is the Simulator running?**
   - You should see an iPhone screen
   - Look for "iOS Simulator" in your Mac's menu bar at the top

2. **Is the Simulator focused?**
   - Click on the Simulator window
   - The menu bar should change to show iOS Simulator

3. **Which macOS version?**
   - CarPlay Simulator requires Xcode 12+ (iOS 14+)
   - Check: `xcodebuild -version`

### Quick Command Method:

If you can't find the menu, use Terminal:

```bash
xcrun simctl ui booted CarPlay
```

This command will launch CarPlay immediately.

## Visual Layout

```
┌─────────────────────────────────────────────────┐
│ iOS Simulator (menu bar)                        │
├─────────────────────────────────────────────────┤
│                                                                   │
│  Your iPhone Screen                  │
│  (showing your app)                  │
│                                                                   │
│  When you enable CarPlay:          │
│  ┌──────────┐                       │
│  │          │                       │
│  │  iPhone  │    ┌─────────┐       │
│  │  Screen  │    │ CarPlay │       │
│  │          │    │ Window  │       │
│  └──────────┘    └─────────┘       │
└───────────────────────────────────────┘
```

## Detailed Step-by-Step with Screenshots

### Step 1: Launch Your App

In Xcode:
```
Product → Run (or ⌘R)
```

Wait for the iOS Simulator to boot up.

### Step 2: Locate the Menu Bar

Your Mac's menu bar (at the very top of your screen) should show:
```
⚙️ iOS Simulator          File  Edit  View  Hardware  Debug  I/O  Help
```

**The menu bar changes** based on which app is active:
- When Xcode is focused: Shows "Xcode" in menu bar
- When Simulator is focused: Shows "iOS Simulator" in menu bar

### Step 3: Navigate to CarPlay

In the **"I/O"** menu, you'll see:
```
I/O
├─ Keyboard
├─ Touch ID
├─ Screenshots
├─ CarPlay
│  ├─ CarPlay (Car)    ← Select this!
│  └─ CarPlay (Phone)
└─ ...
```

### Step 4: Enable CarPlay

Click on **"CarPlay (Car)"** and a new CarPlay window appears!

## Common Issues

### Issue: "I/O menu doesn't exist"

**Problem**: You're looking at the Xcode menu bar, not Simulator's

**Solution**: 
1. Click on the iOS Simulator window
2. Look at the top of your screen
3. The menu should now say "iOS Simulator"

### Issue: "CarPlay option is grayed out"

**Problem**: Running on iOS 13 or earlier simulator

**Solution**:
1. In Xcode, select a newer simulator (iOS 14+)
2. iPhone 15 Pro with iOS 17+ recommended
3. Run again

### Issue: "Nothing happens when I click CarPlay"

**Problem**: CarPlay window opens but is hidden

**Solution**:
1. Look for a new window on your Mac
2. Check Mission Control (three-finger swipe up)
3. CarPlay window might be on another desktop

## Command Line Alternative

If the menu is too hard to find, just use Terminal:

```bash
# Open Terminal (⌘Space, type "Terminal")

# Navigate to project (if not already there)
cd "/Users/jsalas/Desktop/Kei-onara!"

# Launch CarPlay
xcrun simctl ui booted CarPlay
```

The CarPlay window will appear instantly!

## Summary

**Easiest Method:**
1. Run app (⌘R in Xcode)
2. Switch focus to iOS Simulator window
3. Top of screen → **I/O** → **CarPlay** → **CarPlay (Car)**

**Fastest Method:**
```bash
xcrun simctl ui booted CarPlay
```

The CarPlay window should appear automatically! 🚗

