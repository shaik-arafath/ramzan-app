# Ramadan Planner App

A comprehensive Flutter app for managing your Ramadan journey with prayer times, Quran tracking, Zikr reminders, and daily Sunnah learning.

## Features

### 🕌 Prayer Times & Alerts
- **Siren Sound**: Automatically plays at Sehri (Suhoor) and Iftar times
- **Adhan Sound**: Plays at each prayer time (Fajr, Dhuhr, Asr, Maghrib, Isha)
- Real-time prayer time tracking
- Beautiful prayer time display with Arabic names

### 📖 Quran Tracker
- 29-day Quran completion plan
- Daily Juz tracking
- Progress visualization
- Complete the entire Quran during Ramadan

### 💚 Zikr After Prayer
- Daily Zikr reminders after each prayer
- Arabic text with transliteration and meaning
- Recommended counts for each Zikr

### ☪️ Daily Sunnah Learning
- One Sunnah practice to learn each day
- 29 different Sunnah actions throughout Ramadan
- Easy-to-follow guidance

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Audio Files
The app requires two audio files in the Android raw resources folder:
- `android/app/src/main/res/raw/siren.mp3` - For Sehri/Iftar alerts
- `android/app/src/main/res/raw/azan.mp3` - For prayer time Adhan

These files should already be copied from your previous project.

### 3. Prayer Timings
Update the prayer timings in `lib/data/ramadan_data.dart` with the actual timings from your image 2. The current implementation uses sample data that needs to be replaced.

### 4. Run the App
```bash
flutter run
```

## Project Structure

```
lib/
├── data/
│   ├── prayer_timings_data.dart    # Prayer timing data access
│   ├── ramadan_data.dart            # Ramadan day generation (29 days)
│   ├── zikr_data.dart               # Zikr collection
│   └── sunnah_data.dart             # Daily Sunnah practices
├── models/
│   └── prayer_timing.dart           # Data models
├── screens/
│   └── home_screen.dart             # Main home screen
├── services/
│   ├── audio_service.dart           # Audio playback (siren & adhan)
│   ├── notification_service.dart    # Push notifications
│   └── prayer_time_service.dart     # Prayer time monitoring
├── widgets/
│   ├── prayer_card.dart             # Prayer times display
│   ├── quran_progress_card.dart     # Quran progress tracker
│   ├── zikr_card.dart               # Zikr display
│   └── sunnah_card.dart             # Sunnah display
└── main.dart                        # App entry point
```

## How It Works

1. **Prayer Time Monitoring**: The `PrayerTimeService` checks every 30 seconds for prayer times and plays the appropriate sound (Adhan for prayers, Siren for Sehri/Iftar).

2. **Audio Playback**: Uses `just_audio` package to play sounds from Android raw resources.

3. **Notifications**: Local notifications are sent when prayer times arrive.

4. **29-Day Plan**: The app generates a 29-day Ramadan plan with:
   - Daily prayer timings
   - Quran reading schedule (completing 30 Juz in 29 days)
   - Daily Zikr
   - Daily Sunnah practice

## Customization

### Update Prayer Timings
Edit `lib/data/ramadan_data.dart` and replace the `_getSehriTime()`, `_getIftarTime()`, and `_getPrayerTimings()` methods with your actual prayer timings from image 2.

### Customize Zikr
Edit `lib/data/zikr_data.dart` to add or modify Zikr collections.

### Customize Sunnah
Edit `lib/data/sunnah_data.dart` to add or modify daily Sunnah practices.

## Requirements

- Flutter SDK 3.11.0 or higher
- Android SDK (for Android build)
- Audio files in `android/app/src/main/res/raw/` directory

## Permissions

The app requires the following Android permissions (already configured):
- Internet
- Wake Lock
- Vibrate
- Post Notifications
- Receive Boot Completed

## Notes

- The app automatically plays sounds at prayer times when running
- Make sure to grant notification permissions when prompted
- Audio files must be in the correct Android raw resources folder
- Prayer timings should be updated with actual data from your location
