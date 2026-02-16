class PrayerTiming {
  final String name;
  final String time;
  final String arabicName;

  PrayerTiming({
    required this.name,
    required this.time,
    required this.arabicName,
  });
}

class RamadanDay {
  final int day;
  final DateTime date;
  final String sehriTime;
  final String iftarTime;
  final List<PrayerTiming> prayers;
  final int juzNumber;
  final String zikr;
  final String sunnah;

  RamadanDay({
    required this.day,
    required this.date,
    required this.sehriTime,
    required this.iftarTime,
    required this.prayers,
    required this.juzNumber,
    required this.zikr,
    required this.sunnah,
  });
}
