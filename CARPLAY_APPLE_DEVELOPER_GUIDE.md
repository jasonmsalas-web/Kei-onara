# CarPlay Development - Official Apple Resources

## 🎯 Main Resource: developer.apple.com/carplay

The official Apple CarPlay developer documentation is at:
**https://developer.apple.com/carplay/**

## 📚 Key Resources for Developers

### 1. **CarPlay Developer Guide**
- **Location:** developer.apple.com/carplay/guide
- **What it covers:**
  - Supported app categories
  - CarPlay templates and frameworks
  - Integration requirements
  - Best practices for development

### 2. **Design Guidelines**
- **Purpose:** Optimize your app's UI for CarPlay
- **Focus:** Safety, usability, and consistency
- **Covers:**
  - Touch target sizes
  - Typography
  - Color schemes
  - Navigation patterns

### 3. **CarPlay Simulator**
- **Included in:** Xcode 12.0+
- **Purpose:** Test CarPlay apps without a vehicle
- **Access:** iOS Simulator menu → I/O → CarPlay
- **Alternative:** Download additional tools from Apple

### 4. **CarPlay Framework Documentation**
- **Framework:** CarPlay.framework
- **API Reference:** developer.apple.com/documentation/carplay
- **Key Classes:**
  - `CPInterfaceController` - Main interface
  - `CPListTemplate` - Lists and navigation
  - `CPAlertTemplate` - Alerts and confirmations
  - `CPMapTemplate` - Navigation apps
  - `CPVoiceControlTemplate` - Voice commands

## 🚗 Supported App Categories

Apple allows these categories in CarPlay:

### ✅ Allowed Categories:
1. **Audio Apps** (Music, Podcasts, Audiobooks)
2. **Messaging Apps** (Text messages with SiriKit)
3. **Navigation Apps** (Turn-by-turn directions)
4. **EV Charging Apps** (Electric vehicle charging)
5. **Fueling Apps** (Gas station finders)
6. **Parking Apps** (Parking finders and payments)
7. **Quick Food Ordering** (Drive-through ordering)
8. **Driving Task Apps** (Vehicle-related tasks) ← **This is Kei-onara!**

### ❌ Not Allowed:
- General productivity apps
- Social media (except messaging)
- Games
- Photography
- Video (except CarPlay Ultra)

## 🔐 CarPlay Requirements

### Development Requirements:
1. ✅ **Paid Apple Developer Account** ($99/year)
2. ✅ **Xcode 12.0+**
3. ✅ **iOS 14.0+** deployment target
4. ✅ **Request CarPlay Entitlement** from Apple

### Production Requirements:
1. ✅ **Apple Approval Process** (2-4 weeks)
2. ✅ **Technical review** of CarPlay implementation
3. ✅ **Compliance** with CarPlay HIG
4. ✅ **Capability** enabled in Developer Portal

## 📋 How to Request CarPlay Entitlement

### Step 1: Prepare Your App
- App must be functional in CarPlay simulator
- Implement required CarPlay templates
- Follow CarPlay design guidelines
- Test extensively

### Step 2: Submit Request
1. Go to: developer.apple.com/support
2. Select: "CarPlay" as topic
3. Provide:
   - Your App ID
   - Use case description
   - How your app enhances driving
   - Technical implementation details

### Step 3: Review Process
- Apple reviews your request (1-2 weeks)
- They may ask for demo or clarification
- If approved, capability becomes available
- If rejected, they'll explain why

## 🛠️ CarPlay Development Tools

### Built into Xcode:
- **CarPlay Simulator** - Test in iOS Simulator
- **Instruments** - Profile CarPlay apps
- **Debugging tools** - Console logs for CarPlay

### Downloadable Tools:
- **Additional Xcode tools** for CarPlay
- **CarPlay design templates** and resources
- **Sample code** and examples

## 📖 Key Documentation Links

1. **Main Page:** https://developer.apple.com/carplay/
2. **Developer Guide:** https://developer.apple.com/carplay/guide
3. **API Reference:** https://developer.apple.com/documentation/carplay
4. **Design Guidelines:** https://developer.apple.com/carplay/design/
5. **Human Interface Guidelines:** https://developer.apple.com/carplay/hig/
6. **Support:** https://developer.apple.com/support/

## 🎯 Kei-onara! & CarPlay

### Why Kei-onara! Qualifies:
✅ **Driving Task App** - Vehicle tracking and fuel logging
✅ **Safety Focus** - Simplifies car-related tasks
✅ **Reduces Distraction** - Quick vehicle info access
✅ **Utility** - Helps drivers track maintenance, fuel, etc.

### Features We've Implemented:
✅ Main CarPlay menu with 5 actions
✅ Fuel logging via CarPlay
✅ Maintenance reminders
✅ Quick stats (MPG, odometer)
✅ GPS speedometer
✅ Vehicle info at a glance

## 🚀 Getting Started Checklist

### For Kei-onara!:

- [ ] **Read CarPlay Developer Guide**
  - developer.apple.com/carplay/guide

- [ ] **Review Design Guidelines**
  - Follow CarPlay HIG
  - Test all templates

- [ ] **Test in CarPlay Simulator**
  - Xcode → Simulator → I/O → CarPlay
  - Verify all features work

- [ ] **Request CarPlay Entitlement**
  - developer.apple.com/support
  - Include "Driving Task App" use case

- [ ] **Submit for Review**
  - Wait for Apple approval
  - Fix any issues they raise

- [ ] **Deploy to TestFlight**
  - Test with real CarPlay vehicles
  - Gather feedback

- [ ] **Submit to App Store**
  - After CarPlay approval
  - Include CarPlay screenshots

## 💡 Pro Tips from Apple

1. **Keep it Simple** - Large buttons, clear text
2. **Voice First** - Prefer Siri integration over manual input
3. **Safety First** - Minimize glances from road
4. **Test Extensively** - Different vehicles, screen sizes
5. **Follow HIG** - Apple will reject if you don't

## 📞 Getting Help

### Apple Developer Support:
- **Email:** developer@apple.com
- **Portal:** developer.apple.com/support
- **Topics:** CarPlay, App Review, Technical Issues

### Forums:
- **Apple Developer Forums:** forums.developer.apple.com
- **Search:** "CarPlay" for existing discussions

### WWDC Sessions:
- Search for CarPlay sessions
- developer.apple.com/videos/
- Keywords: "CarPlay", "Template Application"

## 🎓 Key Takeaways

1. **CarPlay is for driving** - Apps must enhance, not distract
2. **Template-based** - Use Apple's templates, don't reinvent
3. **Safety is key** - Apple is strict about this
4. **Approval required** - Can't just add to App Store
5. **Test thoroughly** - In simulator AND physical vehicles

## 🔗 Direct Links for Kei-onara! Development

1. **Start Here:** https://developer.apple.com/carplay/
2. **Our Category:** "Driving Task Apps"
3. **Request:** developer.apple.com/support → CarPlay
4. **Documentation:** developer.apple.com/documentation/carplay
5. **Design Guide:** https://developer.apple.com/carplay/design/

---

**Summary:** CarPlay requires Apple approval, but Kei-onara! qualifies as a "Driving Task App" for vehicle tracking and maintenance. You need to request the entitlement from Apple Developer Support with a clear use case.

