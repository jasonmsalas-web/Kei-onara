# Quick CarPlay Setup Steps

## Enable CarPlay for Kei-onara!

### Step 1: Apple Developer Portal
1. Go to: https://developer.apple.com/account/resources/identifiers/list
2. Click on your app's identifier (com.yourteam.Kei-onara)
3. Click "Edit" (or create new if doesn't exist)
4. Scroll to "Capabilities"
5. Check ✅ "CarPlay"
6. Select "Communication" 
7. Click "Continue" → "Save"
8. **Wait 5 minutes** for Apple servers to sync

### Step 2: Xcode
1. Open "Kei-onara!.xcodeproj" in Xcode
2. Sign out and back in to your Apple ID (Xcode → Settings → Accounts)
3. Product → Clean Build Folder (⇧⌘K)
4. Close and reopen Xcode
5. Try adding Capability again

### Step 3: Search For CarPlay
In Xcode:
- Target → Signing & Capabilities
- Click "+ Capability"
- Search: **"CarPlay Communication"** or **"Template Application"**

### If Still Not Found:
The capability might be under a different name:
- Look for: "Template Application"
- Look for: "Communications"
- Look for: "CPTemplate"

