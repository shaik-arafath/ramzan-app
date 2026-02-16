import 'dart:async';
import 'package:flutter/material.dart';
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
  Map<String, DateTime?> _lastPrayerPlayed = {};

  PrayerTimeService(this._notificationService) {
    _startTimer();
  }

  void _startTimer() {
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkPrayerTimes();
    });
  }

  void _checkPrayerTimes() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get today's Ramadan day data
    final ramadanDay = PrayerTimingsData.getRamadanDayForDate(today);
    if (ramadanDay == null) return;

    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Check Sehri time (play siren)
    if (currentTime == ramadanDay.sehriTime && 
        (_lastSehriPlayed == null || _lastSehriPlayed!.day != now.day)) {
      _audioService.playSiren();
      _notificationService.showNotification(
        'Sehri Time',
        'Time to stop eating and drinking. Sehri ends now.',
      );
      _lastSehriPlayed = now;
    }

    // Check Iftar time (play siren)
    if (currentTime == ramadanDay.iftarTime && 
        (_lastIftarPlayed == null || _lastIftarPlayed!.day != now.day)) {
      _audioService.playSiren();
      _notificationService.showNotification(
        'Iftar Time',
        'Time to break your fast. May Allah accept from all of us.',
      );
      _lastIftarPlayed = now;
    }

    // Check prayer times (play adhan)
    for (var prayer in ramadanDay.prayers) {
      if (currentTime == prayer.time && 
          (_lastPrayerPlayed[prayer.name] == null || 
           _lastPrayerPlayed[prayer.name]!.day != now.day)) {
        _audioService.playAdhan();
        _notificationService.showNotification(
          '${prayer.arabicName} - ${prayer.name}',
          'Time for ${prayer.name} prayer',
        );
        _lastPrayerPlayed[prayer.name] = now;
        notifyListeners();
      }
    }
  }

  DateTime? parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, 
                     int.parse(parts[0]), int.parse(parts[1]));
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
