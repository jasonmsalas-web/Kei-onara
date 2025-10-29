# Troubleshooting CarPlay Capability for Paid Developer Account

## You Have a Paid Account - Let's Fix This!

Since you have an active paid Apple Developer account but still can't see CarPlay, here's what to check:

## Step 1: Check Xcode Sign-In

1. **Open Xcode**
2. **Go to:** Xcode → Settings (⌘,)
3. **Click:** Accounts tab
4. **Check your Apple ID:**
   - Is it showing your team name?
   - Does it show "Apple Developer Program" membership?
   - If you see "Personal Team" only, sign out and back in

5. **If needed, re-authenticate:**
   - Click the Apple ID
   - Click "Manage Certificates" 
   - Download the needed certificates

## Step 2: Enable CarPlay in Apple Developer Portal First

**Important**: You may need to enable CarPlay in the Developer Portal FIRST before it shows in Xcode.

1. **Go to:** [developer.apple.com/account](https://developer.apple.com/account)
2. **Navigate to:** Certificates, Identifiers & Profiles
3. **Click:** Identifiers
4. **Find your app ID** (search for your bundle identifier)
5. **Edit** the identifier
6. **Scroll down and enable:**
   - **CarPlay** checkbox
   - Select **"Communication"**
7. **Click:** Continue → Save

8. **Wait 5 minutes** for Apple's servers to sync
9. **Return to Xcode**
10. **Try adding Capability again**

## Step 3: Verify Xcode Version

CarPlay requires specific Xcode versions:

```bash
# Check your Xcode version
xcodebuild -version
```

**Required:** Xcode 12.0 or later

If older, update Xcode:
- Xcode → Check for Updates
- Or download from: developer.apple.com/xcode/

## Step 4: Search for Different Names

Try searching for these terms in "+ Capability":
- "CarPlay" 
- "CPTemplateApplication"
- "Communication"
- "car play" (lowercase)
- "template application"

## Step 5: Manual Enable via Info.plist

If the capability still doesn't appear, we can manually add it:

### Check if you have an Info.plist:
1. In Xcode project navigator
2. Look for: "Kei-onara!" → Info.plist

### If Info.plist exists:
Add this to it:
```xml
<key>CPTemplateApplicationSceneSessionRoleApplication</key>
<array>
    <dict>
        <key>UISceneConfigurationName</key>
        <string>CarPlay</string>
        <key>UISceneDelegateClassName</key>
        <string>CarPlaySceneDelegate</string>
    </dict>
</array>
```

## Step 6: Clean and Rebuild

After any changes:
1. **Clean:** Product → Clean Build Folder (⇧⌘K)
2. **Quit Xcode**
3. **Restart Xcode**
4. **Build:** Product → Build (⌘B)

## Step 7: Alternative - Enable Through Bundle Identifier

1. **Go to Apple Developer Portal**
2. **Edit your App Identifier**
3. **Enable CarPlay Communication**
4. **Save**
5. **In Xcode:** Product → Clean → Build

This sometimes forces Xcode to recognize the capability.

## What to Do Right Now

**Try this order:**

1. **First:** Enable CarPlay in Apple Developer Portal
   - developer.apple.com → Certificates, Identifiers & Profiles
   - Edit your App ID → Enable CarPlay → Save

2. **Wait 5 minutes** (for server sync)

3. **In Xcode:**
   - Sign out and sign back in to your Apple ID
   - Product → Clean Build Folder
   - Restart Xcode

4. **Try adding capability again**

5. **If still missing:** The capability might need special approval from Apple

## Verify Your Account Status

Run this to check:
```bash
# See if you can access CarPlay APIs
grep -r "CarPlay" /Applications/Xcode.app/Contents/Developer
```

If this finds files, CarPlay is available in your Xcode installation.

## Contact Apple Support If Needed

If none of this works:
1. **Contact:** developer.apple.com/contact/
2. **Subject:** "CarPlay capability not available in Xcode"
3. **Include:** Your team ID, Apple ID, Xcode version
4. **Request:** CarPlay capability approval

They may need to manually enable it for your account.

## Quick Test

Let's verify your setup is correct:

```bash
# Check if CarPlay framework exists
ls -la /Applications/Xcode.app/Contents/Frameworks/ | grep -i carplay
```

If this shows files, CarPlay is installed. The issue is just the capability UI not showing.

