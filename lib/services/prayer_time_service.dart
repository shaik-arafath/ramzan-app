import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_timing.dart';
import '../data/prayer_timings_data.dart';
import 'audio_service.dart';
import 'notification_service.dart';

class PrayerTimeService extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final NotificationService _notificationService;
  Timer? _checkTimer;
  DateTime? _lastSehriPlayed;
  DateTime? _lastIftarPlayed;
  final Map<String, DateTime?> _lastPrayerPlayed = {};
  bool _adhanEnabled = true;
  bool _sirenEnabled = true;

  // Optional admin overrides (e.g. from Supabase timetable)
  String? _sehriTimeOverride;
  String? _iftarTimeOverride;
  Map<String, String>? _prayerTimeOverrides;

  // When true, we rely on native Android alarms for playback/notifications
  // and skip in-app audio + notifications to avoid duplicates.
  bool _nativeAlarmsActive = false;

  PrayerTimeService(this._notificationService) {
    _loadPreferences();
    _startTimer();
  }

  bool get adhanEnabled => _adhanEnabled;
  bool get sirenEnabled => _sirenEnabled;

  // Expose current overrides (if needed elsewhere)
  String? get sehriTimeOverride => _sehriTimeOverride;
  String? get iftarTimeOverride => _iftarTimeOverride;
  Map<String, String>? get prayerTimeOverrides => _prayerTimeOverrides;

  /// Called from UI when admin/remote timetable is fetched so that
  /// audio + notifications follow the same times as shown on screen.
  void updateTimetableOverrides({
    String? sehriTime,
    String? iftarTime,
    Map<String, String>? prayers,
  }) {
    _sehriTimeOverride = sehriTime;
    _iftarTimeOverride = iftarTime;
    _prayerTimeOverrides = prayers;

    // If we have any admin overrides, assume native alarms are being used
    // and in-app playback/notifications should be suppressed.
    _nativeAlarmsActive = (_sehriTimeOverride != null && _sehriTimeOverride!.isNotEmpty) ||
        (_iftarTimeOverride != null && _iftarTimeOverride!.isNotEmpty) ||
        (_prayerTimeOverrides != null && _prayerTimeOverrides!.isNotEmpty);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _adhanEnabled = prefs.getBool('settings_adhan_enabled') ?? true;
    _sirenEnabled = prefs.getBool('settings_siren_enabled') ?? true;
    notifyListeners();
  }

  Future<void> setAdhanEnabled(bool value) async {
    _adhanEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_adhan_enabled', value);
    notifyListeners();
  }

  Future<void> setSirenEnabled(bool value) async {
    _sirenEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_siren_enabled', value);
    notifyListeners();
  }

  void _startTimer() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkPrayerTimes();
    });
  }

  void _checkPrayerTimes() {
    // If native Android alarms are active, do not fire in-app audio
    // or notifications to avoid double Adhan/Siren and duplicates.
    if (_nativeAlarmsActive) {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final ramadanDay = PrayerTimingsData.getRamadanDayForDate(today);
    if (ramadanDay == null) return;

    // Helper: true if a is within the same minute window as b
    bool _withinSameMinute(DateTime a, DateTime b) {
      if (a.year != b.year || a.month != b.month || a.day != b.day) {
        return false;
      }
      final diff = a.difference(b).inSeconds.abs();
      // Treat as match if within +/- 59 seconds
      return diff < 60;
    }

    // Decide effective Sehri / Iftar times, preferring admin overrides
    final sehriSource =
        (_sehriTimeOverride != null && _sehriTimeOverride!.isNotEmpty)
            ? _sehriTimeOverride!
            : ramadanDay.sehriTime;
    final iftarSource =
        (_iftarTimeOverride != null && _iftarTimeOverride!.isNotEmpty)
            ? _iftarTimeOverride!
            : ramadanDay.iftarTime;

    // Parse target times with robust parser
    final sehriTime = parseTime(sehriSource);
    final iftarTime = parseTime(iftarSource);

    // Check Sehri time (play siren if enabled)
    if (sehriTime != null && _withinSameMinute(now, sehriTime) &&
        (_lastSehriPlayed == null || _lastSehriPlayed!.day != now.day)) {
      if (_sirenEnabled) {
        _audioService.playSiren();
      }
      _notificationService.showNotification(
        'Sehri Time',
        'Time to stop eating and drinking. Sehri ends now.',
      );
      // Debug: mark when sehri triggered
      debugPrint('Sehri siren triggered at $now for target ${sehriTime.toIso8601String()}');
      _lastSehriPlayed = now;
    }

    // Check Iftar time (play siren if enabled)
    if (iftarTime != null && _withinSameMinute(now, iftarTime) &&
        (_lastIftarPlayed == null || _lastIftarPlayed!.day != now.day)) {
      if (_sirenEnabled) {
        _audioService.playSiren();
      }
      _notificationService.showNotification(
        'Iftar Time',
        'Time to break your fast. May Allah accept from all of us.',
      );
      // Debug: mark when iftar triggered
      debugPrint('Iftar siren triggered at $now for target ${iftarTime.toIso8601String()}');
      _lastIftarPlayed = now;
    }

    // Check prayer times (play adhan if enabled)
    for (var prayer in ramadanDay.prayers) {
      // Maghrib is already aligned with Iftar and triggers the siren above,
      // so skip it here to avoid double playback.
      if (prayer.name == 'Maghrib') continue;

      // Choose effective time for this prayer, preferring admin override
      String prayerTimeStr = prayer.time;
      if (_prayerTimeOverrides != null) {
        final override = _prayerTimeOverrides![prayer.name];
        if (override != null && override.isNotEmpty) {
          prayerTimeStr = override;
        }
      }

      final prayerDateTime = parseTime(prayerTimeStr);
      if (prayerDateTime != null && _withinSameMinute(now, prayerDateTime) &&
          (_lastPrayerPlayed[prayer.name] == null ||
              _lastPrayerPlayed[prayer.name]!.day != now.day)) {
        if (_adhanEnabled) {
          _audioService.playAdhan();
        }
        _notificationService.showNotification(
          '${prayer.arabicName} - ${prayer.name}',
          'Time for ${prayer.name} prayer',
        );
        // Debug: mark when prayer triggered
        debugPrint('Adhan triggered for ${prayer.name} at $now for target ${prayerDateTime.toIso8601String()}');
        _lastPrayerPlayed[prayer.name] = now;
        notifyListeners();
      }
    }
  }

  DateTime? parseTime(String timeStr) {
    try {
      final now = DateTime.now();

      // Normalize input, supports formats like:
      // '05:30', '5:30', '5', '5 am', '5:30 pm', '17:45'
      final cleaned = timeStr.trim().toLowerCase();

      bool isPm = cleaned.contains('pm');
      bool isAm = cleaned.contains('am');

      // Remove am/pm text to parse numeric time part
      var numericPart = cleaned
          .replaceAll('am', '')
          .replaceAll('pm', '')
          .trim();

      if (numericPart.isEmpty) return null;

      final parts = numericPart.split(':');
      if (parts.isEmpty) return null;

      int? hour = int.tryParse(parts[0]);
      if (hour == null) return null;

      int minute = 0;
      if (parts.length > 1) {
        minute = int.tryParse(parts[1]) ?? 0;
      }

      // Apply 12h -> 24h conversion only if am/pm explicitly present
      if (isPm) {
        if (hour < 12) {
          hour += 12;
        }
      } else if (isAm) {
        if (hour == 12) {
          hour = 0;
        }
      }

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  String? getNextPrayerTime(List<PrayerTiming> prayers) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    for (var prayer in prayers) {
      if (prayer.time.compareTo(currentTime) > 0) {
        return prayer.time;
      }
    }
    return prayers.isNotEmpty ? prayers[0].time : null;
  }

  void dispose() {
    _checkTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
