class SunnahData {
  static final List<String> _sunnahList = [
    'Smile and greet others with "Assalamu Alaikum"',
    'Use Miswak (tooth stick) before prayers',
    'Perform Sunnah prayers before Fajr',
    'Eat dates to break your fast',
    'Make Dua before breaking fast',
    'Recite Quran after Fajr prayer',
    'Give charity (Sadaqah) daily',
    'Visit the sick and help the needy',
    'Perform Tahajjud prayer',
    'Recite morning and evening Adhkar',
    'Fast on Mondays and Thursdays (if not Ramadan)',
    'Perform Istikhara before important decisions',
    'Keep your tongue moist with Dhikr',
    'Sleep early and wake up for Tahajjud',
    'Eat in moderation',
    'Use your right hand for eating',
    'Say Bismillah before eating',
    'Say Alhamdulillah after eating',
    'Perform Wudu before sleeping',
    'Recite Ayat al-Kursi before sleeping',
    'Wake up for Fajr prayer',
    'Perform voluntary prayers (Nawafil)',
    'Read Quran with understanding',
    'Memorize new verses daily',
    'Help with household chores',
    'Be patient and control anger',
    'Forgive others and seek forgiveness',
    'Remember Allah in all actions',
    'Follow the example of Prophet Muhammad (PBUH)',
  ];

  static String getSunnahForDay(int day) {
    final index = (day - 1) % _sunnahList.length;
    return _sunnahList[index];
  }
}
