# Deployment Guide for Ramadan App

This guide covers deploying the Ramadan Planner App to various platforms.

## Prerequisites

1. **Flutter SDK** installed and configured
2. **Dependencies** installed: `flutter pub get`
3. **Audio files** in place: `android/app/src/main/res/raw/siren.mp3` and `android/app/src/main/res/raw/azan.mp3`

## Quick Deploy Scripts

### Web Deployment
```powershell
.\deploy-web.ps1
```

### Android Deployment
```powershell
.\deploy-android.ps1
```

---

## 🌐 Web Deployment

### Option 1: Firebase Hosting (Recommended)

1. **Install Firebase CLI** (if not already installed):
   ```powershell
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```powershell
   firebase login
   ```

3. **Initialize Firebase** (if not already done):
   ```powershell
   firebase init hosting
   ```
   - Select existing project or create new one
   - Public directory: `build/web`
   - Configure as single-page app: Yes
   - Set up automatic builds: No (we'll build manually)

4. **Build and Deploy**:
   ```powershell
   .\deploy-web.ps1
   firebase deploy --only hosting
   ```

5. Your app will be live at: `https://YOUR-PROJECT-ID.web.app`

### Option 2: Netlify

1. **Build the app**:
   ```powershell
   .\deploy-web.ps1
   ```

2. **Deploy via Netlify Dashboard**:
   - Go to [Netlify](https://app.netlify.com)
   - Drag and drop the `build/web` folder
   - Your app will be live immediately

3. **Deploy via Netlify CLI**:
   ```powershell
   npm install -g netlify-cli
   netlify login
   netlify deploy --prod --dir=build/web
   ```

4. **Automatic Deployments** (if using Git):
   - Connect your Git repository to Netlify
   - Netlify will automatically build and deploy using `netlify.toml`

### Option 3: Vercel

1. **Install Vercel CLI**:
   ```powershell
   npm install -g vercel
   ```

2. **Build and Deploy**:
   ```powershell
   .\deploy-web.ps1
   vercel --prod
   ```

3. **Automatic Deployments** (if using Git):
   - Connect your Git repository to Vercel
   - Vercel will automatically build and deploy using `vercel.json`

### Option 4: GitHub Pages

1. **Build the app**:
   ```powershell
   .\deploy-web.ps1
   ```

2. **Configure GitHub Pages**:
   - Go to your repository Settings → Pages
   - Source: Deploy from a branch
   - Branch: `gh-pages` (create this branch)
   - Folder: `/ (root)`

3. **Deploy**:
   ```powershell
   git checkout -b gh-pages
   git add build/web/*
   git commit -m "Deploy to GitHub Pages"
   git subtree push --prefix build/web origin gh-pages
   ```

   Or use GitHub Actions (create `.github/workflows/deploy.yml`):
   ```yaml
   name: Deploy to GitHub Pages
   on:
     push:
       branches: [ main ]
   jobs:
     deploy:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - uses: subosito/flutter-action@v2
           with:
             flutter-version: '3.11.0'
         - run: flutter pub get
         - run: flutter build web --release
         - uses: peaceiris/actions-gh-pages@v3
           with:
             github_token: ${{ secrets.GITHUB_TOKEN }}
             publish_dir: ./build/web
   ```

---

## 🤖 Android Deployment

### Build APK (for Direct Installation)

1. **Run the build script**:
   ```powershell
   .\deploy-android.ps1
   ```

2. **APK Location**: `build/app/outputs/flutter-apk/app-release.apk`

3. **Distribute**:
   - Share the APK file directly
   - Upload to your website for download
   - Use file sharing services

### Build App Bundle (for Google Play Store)

1. **Run the build script**:
   ```powershell
   .\deploy-android.ps1
   ```

2. **AAB Location**: `build/app/outputs/bundle/release/app-release.aab`

3. **Google Play Store Submission**:
   - Go to [Google Play Console](https://play.google.com/console)
   - Create a new app or select existing app
   - Navigate to "Production" → "Create new release"
   - Upload `app-release.aab`
   - Fill in release notes
   - Review and submit

### Android Signing Configuration

For production releases, you need to configure signing:

1. **Create a keystore**:
   ```powershell
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Create `android/key.properties`**:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

3. **Update `android/app/build.gradle.kts`**:
   ```kotlin
   // Add at the top
   val keystoreProperties = Properties()
   val keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(FileInputStream(keystorePropertiesFile))
   }

   // Update buildTypes.release
   buildTypes {
       release {
           signingConfig = signingConfigs.getByName("release")
       }
   }

   // Add signingConfigs
   signingConfigs {
       create("release") {
           keyAlias = keystoreProperties["keyAlias"] as String
           keyPassword = keystoreProperties["keyPassword"] as String
           storeFile = file(keystoreProperties["storeFile"] as String)
           storePassword = keystoreProperties["storePassword"] as String
       }
   }
   ```

---

## 🍎 iOS Deployment (macOS Required)

### Prerequisites
- macOS with Xcode installed
- Apple Developer Account ($99/year)
- iOS device or simulator

### Build for iOS

1. **Open in Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure Signing**:
   - Select your team in Xcode
   - Configure bundle identifier
   - Set up provisioning profiles

3. **Build Archive**:
   - Product → Archive
   - Distribute App
   - Choose App Store Connect
   - Upload to App Store

### TestFlight Distribution

1. Build and upload via Xcode
2. Go to App Store Connect
3. Add to TestFlight
4. Invite testers

---

## 📱 Windows Deployment

1. **Build Windows app**:
   ```powershell
   flutter build windows --release
   ```

2. **Output**: `build/windows/runner/Release/ramzan_app.exe`

3. **Package for distribution**:
   - Create installer using Inno Setup or WiX
   - Or distribute the executable directly

---

## 🐧 Linux Deployment

1. **Build Linux app**:
   ```bash
   flutter build linux --release
   ```

2. **Output**: `build/linux/x64/release/bundle/`

3. **Create AppImage or Snap**:
   - Use tools like `appimagetool` for AppImage
   - Or create a Snap package for Snap Store

---

## 🔧 Troubleshooting

### Web Build Issues

- **Missing dependencies**: Run `flutter pub get`
- **Build errors**: Check `flutter doctor` for issues
- **Audio not working**: Web doesn't support Android raw resources - consider using web-compatible audio URLs

### Android Build Issues

- **Gradle errors**: Run `cd android && ./gradlew clean`
- **Signing errors**: Verify `key.properties` configuration
- **Audio not found**: Ensure audio files are in `android/app/src/main/res/raw/`

### General Issues

- **Flutter version**: Ensure you're using Flutter 3.11.0 or higher
- **Dependencies**: Run `flutter pub upgrade` to update packages
- **Clean build**: Run `flutter clean` before building

---

## 📝 Notes

- **Audio Files**: Web deployment won't use Android raw resources. You'll need to host audio files separately or use web-compatible audio URLs.
- **Prayer Times**: Make sure prayer timings are updated in `lib/data/ramadan_data.dart` before deployment.
- **Permissions**: Ensure all required permissions are configured in platform-specific files.
- **Testing**: Always test on target devices/platforms before deploying.

---

## 🚀 Quick Start Commands

```powershell
# Web (Firebase)
.\deploy-web.ps1
firebase deploy --only hosting

# Android APK
.\deploy-android.ps1

# Check Flutter setup
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
```

---

For more information, visit:
- [Flutter Deployment Docs](https://docs.flutter.dev/deployment)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
- [Google Play Console](https://play.google.com/console)
