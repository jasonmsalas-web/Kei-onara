# Kei-onara! Backup Instructions

## 📦 How to Create a Backup

The app has built-in backup features. Here's how to use them:

### Option 1: iCloud Backup (Recommended)
1. Open the **Kei-onara!** app
2. Go to **Settings** (gear icon)
3. Tap **iCloud Backup**
4. Tap **Backup to iCloud**
5. Wait for the backup to complete

### Option 2: Manual Data Export
1. Open the **Kei-onara!** app
2. Go to **Settings**
3. Scroll to **Data Management**
4. Tap **Export Data**
5. Choose where to save the backup file:
   - AirDrop to another device
   - Share via email
   - Save to Files app
   - Upload to Google Drive

### Option 3: Command Line Backup (Advanced)
If you have access to the iOS device's file system:

```bash
# Connect your device and run:
xcrun devicectl developer dvc backup --container "Kei-onara!" backup_data.tar.gz
```

## 🔄 Restoring a Backup

1. Open the app
2. Go to **Settings**
3. Tap **Restore from Backup**
4. Choose your backup source:
   - **iCloud**: Restore from iCloud backup
   - **File**: Select a backup file

## 📁 What Gets Backed Up

The backup includes:
- ✅ All vehicles and their photos
- ✅ All fuel entries
- ✅ All maintenance records
- ✅ All drive logs
- ✅ App settings
- ✅ Insurance card data
- ✅ Version information

## ⚠️ Important Notes

- Backups are automatically created when you use iCloud
- The backup file format is JSON
- Vehicle photos may be large - ensure you have enough iCloud storage
- Backups are automatically synced across all your devices signed into the same iCloud account

## 🎯 Current App Version

- **Version**: 1.0
- **Build**: 222
- **Build Name**: Freeway

