# ConsistHabit App Store Setup Guide

## Required Info.plist Configuration

Add the following keys to your project's Info.plist (or configure through Xcode):

### Notification Permissions
```xml
<key>NSUserNotificationUsageDescription</key>
<string>ConsistHabit sends daily reminders to help you maintain your habits and alerts when your streak is at risk.</string>
```

### Photo Library Access
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>ConsistHabit uses your photo library to let you set a custom profile avatar.</string>
```

### App Privacy
```xml
<key>NSPrivacyTracking</key>
<false/>
<key>NSPrivacyTrackingDomains</key>
<array/>
```

## CloudKit Setup (for iCloud Sync)

1. Open ConsistHabit.xcodeproj
2. Select the ConsistHabit target
3. Go to Signing & Capabilities tab
4. Click "+ Capability"
5. Add "iCloud" capability
6. Select "CloudKit"
7. Ensure a CloudKit container is selected

## StoreKit Configuration

1. In Xcode, create a new "StoreKit Configuration File"
2. Add the following products:
   - **com.consisthabit.premium.monthly**
     - Type: Auto-Renewable Subscription
     - Price Tier: Choose appropriate tier (e.g., $4.99/month)
     - Duration: 1 Month
   
   - **com.consisthabit.premium.annual**
     - Type: Auto-Renewable Subscription
     - Price Tier: $49.99/year (or tier equivalent)
     - Duration: 1 Year

3. Configure Subscription Group (link both subscriptions)

## Widget Configuration

1. A Widget Extension target (ConsistHabitWidget) has been created
2. To properly add it to your project:
   - In Xcode, go to File > New > Target
   - Choose "Widget Extension"
   - Name: ConsistHabitWidget
   - Include in: ConsistHabit
   - Replace the generated code with the provided ConsistHabitWidget.swift

3. Widget displays:
   - Today's completion progress (ring)
   - Current streak count
   - Habits completed today
   - Supports small and medium widget sizes

## Privacy Policy & Terms

Before submitting to App Store, create:

### Privacy Policy (required)
- Hosted at: https://yourcompany.com/consisthabit-privacy
- Must disclose:
  - No third-party tracking
  - Local data storage only
  - Photo library use for avatars
  - Notification usage
  - iCloud sync if enabled

### Terms of Service (recommended)
- Hosted at: https://yourcompany.com/consisthabit-terms

## Build Settings

Ensure these are configured:

1. **Minimum Deployment Target**: iOS 17.0
2. **Swift Language Version**: Swift 6 (or latest)
3. **Code Signing**: Automatic or Manual provisioning profile

## Testing Before Submission

1. Test all features on physical device (not just simulator)
2. Test notification permissions flow
3. Test photo library permissions
4. Test StoreKit purchases (use TestFlight)
5. Test iCloud sync with multiple devices
6. Verify dark mode and light mode rendering
7. Test Dynamic Type with accessibility sizes
8. Test with VoiceOver enabled

## App Store Submission Checklist

- [ ] App icon set (all required sizes)
- [ ] Launch screen configured
- [ ] App name and subtitle finalized
- [ ] Keywords: habit tracker, consistency, streak, daily goals, productivity
- [ ] Category: Health & Fitness
- [ ] Age Rating: 4+
- [ ] Screenshots for all required device sizes
- [ ] Description and promotional text
- [ ] Privacy policy URL added
- [ ] Support URL (contact/website)
- [ ] CloudKit identifier configured
- [ ] StoreKit products configured
- [ ] Build number incremented
- [ ] Version number set correctly (1.0.0 for initial release)

## Post-Launch Tasks

1. Monitor reviews for bugs
2. Enable crash analytics
3. Set up support email
4. Plan future updates:
   - Advanced analytics
   - Custom themes
   - Social sharing features
   - More notification types
