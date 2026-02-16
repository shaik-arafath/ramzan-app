# Web Deployment Script for Ramadan App
# This script builds the Flutter web app and prepares it for deployment

Write-Host "Building Flutter Web App..." -ForegroundColor Cyan

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build for web
Write-Host "Building for web (release mode)..." -ForegroundColor Yellow
flutter build web --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Build output is in: build/web/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Deployment options:" -ForegroundColor Cyan
    Write-Host "1. Firebase Hosting: firebase deploy --only hosting"
    Write-Host "2. Netlify: Drag and drop the build/web folder to Netlify"
    Write-Host "3. Vercel: vercel --prod"
    Write-Host "4. GitHub Pages: See DEPLOYMENT.md for instructions"
    Write-Host ""
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}
