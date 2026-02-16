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
    for (var day in days) {
      if (day.date.year == date.year &&
          day.date.month == date.month &&
          day.date.day == date.day) {
        return day;
      }
    }
    return null;
  }

  static RamadanDay? getTodayRamadanDay() {
    return getRamadanDayForDate(DateTime.now());
  }
}
