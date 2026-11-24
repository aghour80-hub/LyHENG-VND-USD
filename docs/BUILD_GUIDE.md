# Build & Deployment Guide — LyHENG VND-USD

This guide details how to build and package **LyHENG VND-USD** for Android and iOS production release.

---

## 1. Prerequisites
- **Flutter SDK**: 3.50.0 (Channel stable)
- **Dart SDK**: 3.14.0+
- **Android Studio** & **Android SDK**: Version 34+ (Build tools & Command-line tools)
- **Java**: OpenJDK 17

---

## 2. Configuration Setup
Ensure your local `config/dev.json` file is populated with your Supabase credentials:
```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT_ID.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.YOUR_KEY"
}
```

---

## 3. Android Build Workflows

### 3.1 Debug APK (Development & Testing)
```bash
flutter build apk --debug --dart-define-from-file=config/dev.json
```
Output location:
`build/app/outputs/flutter-apk/app-debug.apk`

### 3.2 Release APK (Direct Distribution / Sideloading)
```bash
flutter build apk --release --dart-define-from-file=config/dev.json
```
Output location:
`build/app/outputs/flutter-apk/app-release.apk`

### 3.3 Android App Bundle (AAB - Google Play Store)
```bash
flutter build appbundle --release --dart-define-from-file=config/dev.json
```
Output location:
`build/app/outputs/bundle/release/app-release.aab`

---

## 4. Production Keystore Signing (Android)

1. Generate an upload keystore:
```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties` (never commit this file):
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

3. Update `android/app/build.gradle.kts` to load `key.properties` for the release build type.

---

## 5. iOS Build Workflows

> [!IMPORTANT]
> Development and cross-platform verification can take place on Windows 11. However, generating native iOS binaries (`.ipa`), provisioning profiles, codesigning, and submitting to TestFlight / Apple App Store **strictly requires macOS and Xcode**. Windows cannot produce signed iOS release archives.

### On macOS with Xcode:
1. Ensure CocoaPods is installed:
```bash
sudo gem install cocoapods
```

2. Install iOS pods:
```bash
cd ios && pod install && cd ..
```

3. Build Release IPA:
```bash
flutter build ipa --release --dart-define-from-file=config/dev.json
```
Output location:
`build/ios/archive/Runner.xcarchive` and `build/ios/ipa/`

4. Upload to App Store Connect:
```bash
xcrun altool --upload-app --type ios -f build/ios/ipa/lyheng_vnd_usd.ipa --apiKey YOUR_KEY_ID --apiIssuer YOUR_ISSUER_UUID
```
