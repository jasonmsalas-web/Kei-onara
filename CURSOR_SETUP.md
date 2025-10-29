# Cursor Auto Version Increment Setup

This guide explains how to set up automatic version incrementing in Cursor for the Kei-onara! app.

## 🎯 Overview

The app now includes automatic version incrementing that increases the version by 0.001 every time changes are accepted in Cursor.

## 📋 Setup Instructions

### 1. Available Scripts

- **`cursor_trigger.sh`** - Main trigger script for Cursor
- **`auto_increment_version.sh`** - Core version increment logic
- **`cursor_auto_increment.sh`** - Alternative trigger script

### 2. How to Use

#### Option A: Manual Trigger
When you accept changes in Cursor, run:
```bash
./cursor_trigger.sh
```

#### Option B: Git Hook Integration
The existing pre-commit hook will automatically increment versions on commit.

#### Option C: Direct Script
Run the auto increment directly:
```bash
./auto_increment_version.sh
```

### 3. What Happens

1. **Version Increment**: MARKETING_VERSION increases by 0.001 (e.g., 1.0.130 → 1.0.131)
2. **Build Number**: CURRENT_PROJECT_VERSION increases by 1
3. **Git Staging**: Updated project file is automatically staged
4. **Settings Display**: Version in Settings view updates automatically

### 4. Version Display

The app now shows the current version dynamically in Settings:
- **Before**: Hardcoded "1.0.129 (Freeway)"
- **After**: Dynamic version from Bundle info

### 5. Splash Screen

The app now includes a splash screen that:
- Shows the app icon and title
- Fades in smoothly after 2 seconds
- Uses the app's color scheme
- Transitions to the main dashboard

## 🔧 Technical Details

### Version Format
- **Marketing Version**: `1.0.XXX` (increments by 0.001)
- **Build Number**: `XXX` (increments by 1)
- **Example**: 1.0.131 (Build 131)

### Files Modified
- `Kei-onara!.xcodeproj/project.pbxproj` - Version numbers
- `Kei_onara_App.swift` - Splash screen integration
- `SettingsView.swift` - Dynamic version display
- `MascotView.swift` - Enhanced splash screen

### Scripts Created
- `cursor_trigger.sh` - Main Cursor trigger
- `auto_increment_version.sh` - Core increment logic
- `cursor_auto_increment.sh` - Alternative trigger

## 🚀 Usage

### For Cursor Users
1. Accept changes in Cursor
2. Run `./cursor_trigger.sh` in terminal
3. Version automatically increments
4. Commit changes with new version

### For Manual Users
1. Make changes to code
2. Run `./auto_increment_version.sh`
3. Version increments automatically
4. Commit changes

## ✅ Verification

To verify the setup is working:

1. **Check Current Version**:
   ```bash
   ./update_version.sh show
   ```

2. **Test Increment**:
   ```bash
   ./cursor_trigger.sh
   ```

3. **Verify in App**:
   - Open Settings
   - Check version number is current

## 🎨 Splash Screen Features

- **Duration**: 2 seconds
- **Animation**: Smooth fade transition
- **Icon**: Uses app icon artwork
- **Colors**: Matches app theme
- **Text**: "KEI-ONARA!" branding

## 📝 Notes

- Version increments are automatic and consistent
- Build numbers always match the patch version
- Settings view shows real-time version info
- Splash screen provides professional app launch experience
- All scripts are executable and ready to use

## 🔄 Maintenance

The scripts are designed to be:
- **Idempotent**: Safe to run multiple times
- **Automatic**: No manual intervention required
- **Consistent**: Always increments by 0.001
- **Git-friendly**: Automatically stages changes 