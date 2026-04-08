import '../models/prayer_timing.dart';
import 'zikr_data.dart';
import 'sunnah_data.dart';

class RamadanData {
  // Generate 30 days of Ramadan plan
  static List<RamadanDay> generateRamadanPlan() {
    final days = <RamadanDay>[];
    // Ramadan 2026 starts on February 18, 2026 (1 Ramadan 1447)
    final startDate = DateTime(2026, 2, 19);
    
    for (int i = 0; i < 30; i++) {
      final date = startDate.add(Duration(days: i));
      final dayNumber = i + 1;
      
      // Calculate Juz for 30-day completion (30 Juz / 30 days = 1 Juz per day)
      final juzNumber = dayNumber;
      
      days.add(RamadanDay(
        day: dayNumber,
        date: date,
        sehriTime: _getSehriTime(dayNumber),
        iftarTime: _getIftarTime(dayNumber),
        prayers: _getPrayerTimings(dayNumber),
        juzNumber: juzNumber.clamp(1, 30),
        zikr: ZikrData.getZikrForDay(dayNumber),
        sunnah: SunnahData.getSunnahForDay(dayNumber),
      ));
    }
    
    return days;
  }

  static String _getSehriTime(int day) {
    // Sample times - replace with actual data from image 2
    // Times gradually shift as Ramadan progresses
    final baseHour = 4;
    final baseMinute = 30;
    final shiftMinutes = (day * 1.5).round(); // Approximate shift
    final totalMinutes = baseMinute + shiftMinutes;
    final hour = baseHour + (totalMinutes ~/ 60);
    final minute = totalMinutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static String _getIftarTime(int day) {
    // Sample times - replace with actual data from image 2
    final baseHour = 18;
    final baseMinute = 15;
    final shiftMinutes = (day * 1.5).round(); // Approximate shift
    final totalMinutes = baseMinute - shiftMinutes;
    final hour = baseHour + (totalMinutes ~/ 60);
    final minute = totalMinutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static List<PrayerTiming> _getPrayerTimings(int day) {
    // Sample prayer times - replace with actual data from image 2
    // Times shift slightly each day
    final shift = (day * 1.2).round();
    
    return [
      PrayerTiming(
        name: 'Fajr',
        arabicName: 'الفجر',
        time: _addMinutes('05:00', shift),
      ),
      PrayerTiming(
        name: 'Dhuhr',
        arabicName: 'الظهر',
        time: _addMinutes('12:30', shift),
      ),
      PrayerTiming(
        name: 'Asr',
        arabicName: 'العصر',
        time: _addMinutes('15:45', shift),
      ),
      PrayerTiming(
        name: 'Maghrib',
        arabicName: 'المغرب',
        time: _getIftarTime(day), // Maghrib is same as Iftar
      ),
      PrayerTiming(
        name: 'Isha',
        arabicName: 'العشاء',
        time: _addMinutes('19:30', shift),
      ),
    ];
  }

  static String _addMinutes(String time, int minutes) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final totalMinutes = hour * 60 + minute + minutes;
    final newHour = (totalMinutes ~/ 60) % 24;
    final newMinute = totalMinutes % 60;
    return '${newHour.toString().padLeft(2, '0')}:${newMinute.toString().padLeft(2, '0')}';
  }
}
