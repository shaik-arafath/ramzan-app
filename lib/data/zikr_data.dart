class ZikrData {
  static final List<Map<String, String>> _zikrList = [
    {
      'arabic': 'سُبْحَانَ اللَّهِ',
      'transliteration': 'SubhanAllah',
      'meaning': 'Glory be to Allah',
      'count': '33 times',
    },
    {
      'arabic': 'الْحَمْدُ لِلَّهِ',
      'transliteration': 'Alhamdulillah',
      'meaning': 'Praise be to Allah',
      'count': '33 times',
    },
    {
      'arabic': 'اللَّهُ أَكْبَر',
      'transliteration': 'Allahu Akbar',
      'meaning': 'Allah is the Greatest',
      'count': '33 times',
    },
    {
      'arabic': 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      'transliteration': 'La ilaha illa Allah',
      'meaning': 'There is no god but Allah',
      'count': '100 times',
    },
    {
      'arabic': 'أَسْتَغْفِرُ اللَّه',
      'transliteration': 'Astaghfirullah',
      'meaning': 'I seek forgiveness from Allah',
      'count': '100 times',
    },
    {
      'arabic': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'transliteration': 'La hawla wa la quwwata illa billah',
      'meaning': 'There is no power except with Allah',
      'count': '100 times',
    },
    {
      'arabic': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّد',
      'transliteration': 'Allahumma salli ala Muhammad',
      'meaning': 'O Allah, send blessings upon Muhammad',
      'count': '100 times',
    },
    {
      'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'transliteration': 'SubhanAllahi wa bihamdihi',
      'meaning': 'Glory be to Allah and praise be to Him',
      'count': '100 times',
    },
  ];

  static String getZikrForDay(int day) {
    final index = (day - 1) % _zikrList.length;
    final zikr = _zikrList[index];
    return '${zikr['arabic']}\n${zikr['transliteration']}\n${zikr['meaning']}\n${zikr['count']}';
  }

  static Map<String, String> getZikrDetails(int day) {
    final index = (day - 1) % _zikrList.length;
    return _zikrList[index];
  }
}
