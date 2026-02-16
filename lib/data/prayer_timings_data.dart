import '../models/prayer_timing.dart';
import 'ramadan_data.dart';

class PrayerTimingsData {
  // This will be populated with data from image 2
  // For now, using sample data structure
  static List<RamadanDay> getRamadanDays() {
    return RamadanData.generateRamadanPlan();
  }

  static RamadanDay? getRamadanDayForDate(DateTime date) {
    final days = getRamadanDays();
    
    // Normalize date to compare only year, month, day (ignore time)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // Find exact match first
    for (var day in days) {
      final normalizedDayDate = DateTime(day.date.year, day.date.month, day.date.day);
      if (normalizedDayDate == normalizedDate) {
        return day;
      }
    }
    
    // If no exact match, find the closest Ramadan day
    // If before Ramadan starts, return Day 1
    final firstDay = days.first;
    final lastDay = days.last;
    final firstDayDate = DateTime(firstDay.date.year, firstDay.date.month, firstDay.date.day);
    final lastDayDate = DateTime(lastDay.date.year, lastDay.date.month, lastDay.date.day);
    
    if (normalizedDate.isBefore(firstDayDate)) {
      // Before Ramadan - show Day 1
      return firstDay;
    } else if (normalizedDate.isAfter(lastDayDate)) {
      // After Ramadan - show last day
      return lastDay;
    }
    
    // Should not reach here, but return first day as fallback
    return firstDay;
  }

  static RamadanDay? getTodayRamadanDay() {
    return getRamadanDayForDate(DateTime.now());
  }
}
