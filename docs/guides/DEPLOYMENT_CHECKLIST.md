# HERQ Deployment Checklist

## ✅ Rebrand Implementation - COMPLETE

All rebrand tasks have been completed and verified:

- ✅ **Localization**: App name, tagline, brand story in 3 languages
- ✅ **Color Theme**: HERQ palette implemented (Teal & Lime)
- ✅ **Theme System**: User-selectable themes with persistence
- ✅ **Package IDs**: Updated to `com.herq.app`
- ✅ **Import Paths**: All 196+ files updated
- ✅ **Code Generation**: Completed (419 outputs)
- ✅ **Build Test**: ✅ APK builds successfully
- ✅ **Analysis**: ✅ No errors

## 📱 Testing Checklist

### Local Testing
- [ ] Test on iOS Simulator
  ```bash
  flutter run -d "iPhone 15 Pro"
  ```
- [ ] Test on Android Emulator
  ```bash
  flutter run -d emulator-5554
  ```
- [ ] Test theme switching (Settings → Appearance → Color Theme)
- [ ] Verify HERQ colors appear correctly
- [ ] Test in both light and dark modes
- [ ] Verify all localizations (EN, PT, ES)
- [ ] Test on physical iOS device
- [ ] Test on physical Android device

### Feature Verification
- [ ] Splash screen shows HERQ branding
- [ ] Home screen displays correctly
- [ ] Workout tracking works
- [ ] Settings screen theme selector works
- [ ] Navigation between screens
- [ ] Data persistence works
- [ ] Theme preference persists after restart

## 🎨 App Icon & Assets

### Required Assets
- [ ] **App Icon** - Design HERQ monogram with movement arc
  - iOS: 1024x1024 PNG
  - Android: Adaptive icon (foreground + background)
  - Web: favicon.ico, 192x192, 512x512

### Design Brief (from Brand Guidelines)
```
Concept: Bold monogram with movement arc
Elements:
  - Stylized "H" or "HQ" monogram
  - Geometric, modern shape
  - Movement or progress arc integrated
  - Strong, recognizable silhouette
  - Works at small sizes (16x16 to 1024x1024)
Colors:
  - Primary: Electric Teal (#00BFA6) background
  - Accent: Warm Lime (#D4FF4D) highlights
  - Alternative: Graphite (#1B1D21) with Teal/Lime gradient
```

## 🏪 App Store Submission

### ⚠️ IMPORTANT: This is a NEW APP
New package IDs (`com.herq.app`) mean this will be submitted as a **completely new app**, not an update.

### Apple App Store (iOS)

#### Prerequisites
- [ ] Apple Developer Account ($99/year)
- [ ] App Store Connect access
- [ ] Certificates & Provisioning Profiles for `com.herq.app`

#### Steps
1. [ ] Create new app in App Store Connect
   - Bundle ID: `com.herq.app`
   - App Name: "HERQ"
   - Subtitle: "Smart Strength. Simplified."

2. [ ] Prepare App Information
   - **Category**: Health & Fitness
   - **Age Rating**: 4+
   - **Privacy Policy URL**: (to be created)
   - **Support URL**: (to be created)

3. [ ] Screenshots (required sizes)
   - [ ] 6.5" iPhone (1284 x 2778)
   - [ ] 6.7" iPhone (1290 x 2796)
   - [ ] 5.5" iPhone (1242 x 2208)
   - [ ] 12.9" iPad Pro (2048 x 2732)

4. [ ] App Description (use from Brand Guidelines)
   ```
   HERQ - Smart strength training with AI coaching.
   
   Inspired by the spirit of Heracles — the original symbol 
   of strength and perseverance — HERQ fuses ancient power 
   with modern intelligence.
   
   Whether you're chasing your first pull-up or your next PR, 
   HERQ helps you train smarter, recover better, and rise stronger.
   
   FEATURES:
   • Intelligent workout tracking
   • AI-powered coaching recommendations
   • Progress analytics and charts
   • Personal record tracking
   • Social features and leaderboards
   • Customizable workout templates
   • Multi-language support (EN, PT, ES)
   
   Built for lifters, movers, and everyday heroes who believe 
   strength isn't just physical — it's a mindset.
   ```

5. [ ] Build & Upload
   ```bash
   flutter build ipa --release
   # Upload via Xcode or Transporter
   ```

6. [ ] Submit for Review

### Google Play Store (Android)

#### Prerequisites
- [ ] Google Play Console account ($25 one-time)
- [ ] Signing key for `com.herq.app`

#### Steps
1. [ ] Create new app in Play Console
   - Package name: `com.herq.app`
   - App name: "HERQ"
   - Short description: "Smart Strength. Simplified."

2. [ ] Prepare Store Listing
   - **Category**: Health & Fitness
   - **Target Audience**: Everyone
   - **Content Rating**: (complete questionnaire)

3. [ ] Screenshots (required)
   - [ ] Phone: 2-8 screenshots (1080 x 1920 or higher)
   - [ ] 7-inch tablet: 2-8 screenshots
   - [ ] 10-inch tablet: 2-8 screenshots

4. [ ] Feature Graphic
   - [ ] 1024 x 500 PNG/JPEG

5. [ ] App Description (same as iOS)

6. [ ] Build & Upload
   ```bash
   flutter build appbundle --release
   # Upload to Play Console
   ```

7. [ ] Complete Content Rating questionnaire
8. [ ] Set pricing (Free)
9. [ ] Select countries/regions
10. [ ] Submit for Review

## 📸 Screenshot Guidelines

### What to Capture
1. **Home Screen** - Show HERQ branding and quick actions
2. **Active Workout** - Demonstrate workout tracking
3. **Progress Charts** - Show analytics and graphs
4. **Exercise Library** - Display exercise browsing
5. **Theme Switching** - Show HERQ vs Default theme

### Design Tips
- Use HERQ color palette prominently
- Show real workout data (mock if needed)
- Include device frame
- Add text overlays highlighting features
- Maintain consistent style across all screenshots

## 🔐 Privacy & Legal

### Required Documents
- [ ] **Privacy Policy**
  - Data collection practices
  - Local storage vs cloud sync
  - Third-party services (Supabase, etc.)
  - User rights (export, delete)

- [ ] **Terms of Service**
  - Usage terms
  - Health disclaimer
  - Liability limitations
  - Intellectual property

- [ ] **Support Page**
  - Contact information
  - FAQ
  - Troubleshooting

### Template Locations
- Base privacy policy: `lib/src/features/settings/presentation/screens/settings_screen.dart` (lines 843-875)
- Base terms of service: Same file (lines 895-942)
- Update these with HERQ branding and publish to website

## 🌐 Web & Marketing

### Website (Optional but Recommended)
- [ ] Create landing page (herq.app or similar)
- [ ] Add app store badges
- [ ] Display screenshots
- [ ] Include brand story
- [ ] Link to privacy policy & terms

### Social Media
- [ ] Create social media accounts
  - Twitter/X: @herqapp
  - Instagram: @herqapp
  - Facebook: HERQ
- [ ] Post launch announcement
- [ ] Share feature highlights
- [ ] Engage with fitness community

## 📊 Analytics & Monitoring

### Setup Tracking
- [ ] Firebase Analytics (recommended)
- [ ] Crashlytics for error tracking
- [ ] Performance monitoring
- [ ] User engagement metrics

### Key Metrics to Track
- Daily/Monthly Active Users (DAU/MAU)
- Session duration
- Feature usage (workout tracking, templates, etc.)
- Retention rate
- Crash-free rate
- Theme preference (HERQ vs Default)

## 🔄 Post-Launch

### Week 1
- [ ] Monitor crash reports
- [ ] Review user feedback/reviews
- [ ] Fix critical bugs if any
- [ ] Respond to reviews
- [ ] Track download numbers

### Month 1
- [ ] Analyze user engagement
- [ ] Identify most-used features
- [ ] Plan feature improvements
- [ ] Gather feature requests
- [ ] Consider marketing campaigns

### Ongoing
- [ ] Regular updates (bug fixes, features)
- [ ] Maintain app store presence
- [ ] Engage with community
- [ ] Monitor competitors
- [ ] Iterate based on feedback

## ✅ Final Pre-Launch Checklist

- [ ] All rebrand changes reviewed and accepted
- [ ] App builds successfully on iOS and Android
- [ ] No critical bugs in testing
- [ ] App icon designed and integrated
- [ ] Screenshots prepared
- [ ] Store descriptions written
- [ ] Privacy policy & terms published
- [ ] Support page created
- [ ] App store accounts ready
- [ ] Team aligned on launch plan

---

## 🚀 Ready to Launch!

When all items are checked, you're ready to submit HERQ to the app stores.

**Remember**: This is a NEW app submission with package ID `com.herq.app`. Previous users of the old app (if any) cannot update - they would need to download HERQ as a new app.

---

**HERQ - Smart Strength. Simplified.**

Train smarter. Recover better. Rise stronger. 💪⚡

