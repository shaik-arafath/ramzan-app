# Android Deployment Script for Ramadan App
# This script builds the Android APK/AAB for deployment

Write-Host "Building Flutter Android App..." -ForegroundColor Cyan

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Check for release signing configuration
Write-Host "Checking Android configuration..." -ForegroundColor Yellow

# Build APK (for direct installation)
Write-Host ""
Write-Host "Building APK (for direct installation)..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "APK build successful!" -ForegroundColor Green
    Write-Host "APK location: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Cyan
}

# Build App Bundle (for Google Play Store)
Write-Host ""
Write-Host "Building App Bundle (for Google Play Store)..." -ForegroundColor Yellow
flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "App Bundle build successful!" -ForegroundColor Green
    Write-Host "AAB location: build/app/outputs/bundle/release/app-release.aab" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps for Google Play Store:" -ForegroundColor Cyan
    Write-Host "1. Go to Google Play Console (https://play.google.com/console)"
    Write-Host "2. Create a new app or select existing app"
    Write-Host "3. Upload the app-release.aab file"
    Write-Host "4. Fill in store listing details"
    Write-Host "5. Submit for review"
    Write-Host ""
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}
