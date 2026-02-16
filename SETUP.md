# Setup Guide for Ramadan App

## Quick Start

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Audio Files:**
   - ✅ Audio files are already copied to `android/app/src/main/res/raw/`
   - `siren.mp3` - For Sehri/Iftar alerts
   - `azan.mp3` - For prayer time Adhan

3. **Update Prayer Timings:**
   - Open `lib/data/ramadan_data.dart`
   - Replace the `_getSehriTime()`, `_getIftarTime()`, and `_getPrayerTimings()` methods with actual timings from your image 2
   - The methods currently use sample data that shifts based on day number

4. **Package Name Configuration:**
   - If audio doesn't play, check your app's package name in `android/app/build.gradle` (look for `applicationId`)
   - Update `lib/services/package_info_service.dart` with your actual package name, or
   - The app will try multiple methods automatically

5. **Run the app:**
   ```bash
   flutter run
   ```

## Features Implemented

✅ **Siren Sound** - Plays at Sehri and Iftar times  
✅ **Adhan Sound** - Plays at each prayer time (Fajr, Dhuhr, Asr, Maghrib, Isha)  
✅ **Quran Tracker** - 29-day completion plan  
✅ **Zikr Display** - Shows Zikr after each prayer  
✅ **Daily Sunnah** - One Sunnah practice per day  
✅ **Prayer Times** - Beautiful display with Arabic names  
✅ **Notifications** - Local notifications for prayer times  

## Audio Troubleshooting

If audio doesn't play:

1. Check that files exist in `android/app/src/main/res/raw/`
2. Verify file names are exactly `siren.mp3` and `azan.mp3` (lowercase)
3. Check AndroidManifest.xml has required permissions
4. Try rebuilding the app: `flutter clean && flutter pub get && flutter run`
5. Check device volume is not muted
6. Check app notification permissions are granted

## Updating Prayer Timings

To update with actual timings from image 2:

1. Open `lib/data/ramadan_data.dart`
2. Modify these methods:
   - `_getSehriTime(int day)` - Returns Sehri time for each day
   - `_getIftarTime(int day)` - Returns Iftar time for each day  
   - `_getPrayerTimings(int day)` - Returns list of prayer times for each day

Example format:
```dart
static String _getSehriTime(int day) {
  // Return time in HH:mm format
  return '04:30'; // Example
}
```

## Testing

- The app checks prayer times every 30 seconds
- Sounds will play automatically when prayer times match current time
- Make sure your device time is set correctly
- Test by temporarily setting device time to a prayer time

## Next Steps

1. Update prayer timings with actual data from image 2
2. Customize Zikr and Sunnah content if needed
3. Test audio playback on a physical device
4. Adjust UI colors/styling if desired
