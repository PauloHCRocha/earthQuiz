# AdMob Setup Guide for Earth Quiz

This guide will walk you through setting up Google AdMob in your Earth Quiz iOS app.

## Prerequisites

- Google account
- Xcode project (earthQuiz.xcodeproj)
- iOS deployment target 15.0+

## Step 1: Create AdMob Account and Get Your IDs

### 1.1 Sign up for AdMob

1. Go to https://admob.google.com/
2. Sign in with your Google account
3. Click "GET STARTED"
4. Accept the AdMob terms and conditions
5. Complete your account information

### 1.2 Add Your App to AdMob

1. In the AdMob dashboard, click **"Apps"** in the left sidebar
2. Click **"ADD APP"** button
3. Select **"iOS"** as the platform
4. Choose **"No"** for "Is your app listed on a supported app store?" (unless already published)
5. Enter your app name: **"Earth Quiz"**
6. Click **"ADD"**
7. **IMPORTANT**: Copy your **App ID** - it looks like:
   ```
   ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
   ```
   (Save this - you'll need it in Step 2!)

### 1.3 Create a Banner Ad Unit

1. After creating the app, AdMob will ask you to create an ad unit
2. Click **"ADD AD UNIT"**
3. Select **"Banner"** as the ad format
4. Name it: **"Earth Quiz Banner"**
5. Click **"CREATE AD UNIT"**
6. **IMPORTANT**: Copy your **Ad Unit ID** - it looks like:
   ```
   ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY
   ```
   (Save this too - you'll need it in Step 3!)

## Step 2: Add Google Mobile Ads SDK to Your Project

### 2.1 Open Your Project in Xcode

1. Open `earthQuiz.xcodeproj` in Xcode

### 2.2 Add the Swift Package

1. In Xcode, select your project in the navigator (blue icon at the top)
2. Select the **"earthQuiz"** target
3. Click on the **"Package Dependencies"** tab
4. Click the **"+"** button (bottom left)
5. In the search field (top right), paste:
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads.git
   ```
6. Click **"Add Package"**
7. Wait for the package to load
8. Ensure **"GoogleMobileAds"** is checked
9. Click **"Add Package"**

## Step 3: Configure Info.plist

### 3.1 Add GADApplicationIdentifier

You need to add your AdMob App ID to Info.plist:

**Option A: Using Info.plist file directly**
1. Find `Info.plist` in your project (usually in the earthQuiz folder)
2. Right-click and select "Open As" > "Source Code"
3. Add this before the final `</dict>`:
   ```xml
   <key>GADApplicationIdentifier</key>
   <string>YOUR_ADMOB_APP_ID_HERE</string>
   ```
4. Replace `YOUR_ADMOB_APP_ID_HERE` with your actual App ID from Step 1.2

**Option B: Using Xcode's Info tab**
1. Select your project in the navigator
2. Select the "earthQuiz" target
3. Go to the "Info" tab
4. Click the **"+"** button next to any key
5. Type: `GADApplicationIdentifier`
6. Set Type to **"String"**
7. Set Value to your App ID from Step 1.2

### 3.2 Add SKAdNetworkItems (Required by Apple)

Google Mobile Ads requires SKAdNetwork identifiers. Add these to your Info.plist:

1. Open Info.plist as source code
2. Add this before the final `</dict>`:
   ```xml
   <key>SKAdNetworkItems</key>
   <array>
       <dict>
           <key>SKAdNetworkIdentifier</key>
           <string>cstr6suwn9.skadnetwork</string>
       </dict>
       <dict>
           <key>SKAdNetworkIdentifier</key>
           <string>4fzdc2evr5.skadnetwork</string>
       </dict>
       <dict>
           <key>SKAdNetworkIdentifier</key>
           <string>2fnua5tdw4.skadnetwork</string>
       </dict>
       <dict>
           <key>SKAdNetworkIdentifier</key>
           <string>ydx93a7ass.skadnetwork</string>
       </dict>
       <dict>
           <key>SKAdNetworkIdentifier</key>
           <string>5a6flpkh64.skadnetwork</string>
       </dict>
       <dict>
           <key>SKAdNetworkIdentifier</key>
           <string>p78axxw29g.skadnetwork</string>
       </dict>
       <dict>
           <key>SKAdNetworkIdentifier</key>
           <string>v72qych5uu.skadnetwork</string>
       </dict>
   </array>
   ```

For the complete list of SKAdNetwork IDs, visit: https://developers.google.com/admob/ios/skadnetwork

## Step 4: Update Ad Unit ID in Code

1. Open `earthQuiz/Views/BannerAdView.swift`
2. Find this line:
   ```swift
   private let adUnitID = "ca-app-pub-3940256099942544/2934735716"
   ```
3. Replace the test ID with **your actual Ad Unit ID** from Step 1.3:
   ```swift
   private let adUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
   ```

## Step 5: Build and Test

### 5.1 Test with Test Ads First

Before switching to your real Ad Unit ID, test that everything works:

1. Build and run the app (Cmd+R)
2. You should see test ads (they'll have "Test Ad" text)
3. Test ads appear on:
   - Start screen (bottom)
   - Game screen (bottom)
   - Game over screen (bottom)

**Current Test IDs (already in the code):**
- Test App ID: `ca-app-pub-3940256099942544~1458002511`
- Test Ad Unit ID: `ca-app-pub-3940256099942544/2934735716`

### 5.2 Switch to Production Ads

Once you've verified test ads work:

1. Update Info.plist with your real App ID (from Step 1.2)
2. Update BannerAdView.swift with your real Ad Unit ID (from Step 1.3)
3. Rebuild the app

### 5.3 Important Testing Notes

- **AdMob ads may not show in the iOS Simulator** - test on a real device
- **New ad units can take up to 24 hours** to start serving ads
- **Low fill rates** are normal for new apps - don't worry if ads don't always appear
- **Test mode**: Keep using test IDs during development to avoid policy violations

## Step 6: Prepare for App Store

Before submitting to the App Store:

1. ✅ Ensure you're using your **real App ID** in Info.plist
2. ✅ Ensure you're using your **real Ad Unit ID** in BannerAdView.swift
3. ✅ Remove any test IDs from the code
4. ✅ Update your app's privacy policy to mention ads
5. ✅ Add your app to App Store Connect
6. ✅ Link your AdMob app to your App Store listing in AdMob dashboard

## Troubleshooting

### Ads not showing?

1. **Check the Xcode console** for error messages starting with `GAD`
2. **Verify your App ID** is correct in Info.plist
3. **Verify your Ad Unit ID** is correct in BannerAdView.swift
4. **Test on a real device** (not simulator)
5. **Wait 24 hours** for new ad units to activate
6. **Check AdMob dashboard** to ensure your app and ad unit are active

### Common Error Messages

- `"No ad to show"` - Normal, just means no ad available right now
- `"Invalid App ID"` - Check your App ID in Info.plist
- `"Invalid Ad Unit ID"` - Check your Ad Unit ID in BannerAdView.swift
- `"The operation couldn't be completed"` - Network issue, try again

### Where are the ads displayed?

The banner ads appear at the bottom of:
- **StartView.swift** (line 91) - Start screen
- **GameView.swift** (line 170) - During gameplay
- **GameOverView.swift** (line 264) - Results screen

## Revenue and Analytics

1. Visit https://admob.google.com/ to view:
   - Earnings
   - Ad performance
   - User metrics
2. Revenue is typically paid out monthly (minimum $100 USD)
3. Set up payment information in AdMob settings

## Need Help?

- AdMob Help Center: https://support.google.com/admob
- iOS Integration Guide: https://developers.google.com/admob/ios/quick-start
- SKAdNetwork Setup: https://developers.google.com/admob/ios/skadnetwork

---

**Good luck with your app monetization! 🎉**
