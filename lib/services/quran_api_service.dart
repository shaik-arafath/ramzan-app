import 'dart:convert';

import 'package:http/http.dart' as http;

class QuranSurah {
  final int number;
  final String name;
  final String englishName;

  QuranSurah({required this.number, required this.name, required this.englishName});

  factory QuranSurah.fromJson(Map<String, dynamic> json) {
    return QuranSurah(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String? ?? '',
    );
  }
}

class QuranVerse {
  final int numberInSurah;
  final String arabic;
  final String translationEn;
  final String translationUr;

  QuranVerse({
    required this.numberInSurah,
    required this.arabic,
    required this.translationEn,
    required this.translationUr,
  });
}

class QuranApiService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  Future<List<QuranSurah>> fetchSurahs() async {
    final uri = Uri.parse('$_baseUrl/surah');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load surahs');
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final List list = data['data'] as List;
    return list.map((e) => QuranSurah.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<QuranVerse>> fetchSurahVerses(int surahNumber) async {
    // Arabic text
    final arabicUri = Uri.parse('$_baseUrl/surah/$surahNumber');
    // English translation (e.g. en.asad)
    final englishUri = Uri.parse('$_baseUrl/surah/$surahNumber/en.asad');
    // Urdu translation (e.g. ur.jalandhry)
    final urduUri = Uri.parse('$_baseUrl/surah/$surahNumber/ur.jalandhry');

    final responses = await Future.wait([
      http.get(arabicUri),
      http.get(englishUri),
      http.get(urduUri),
    ]);

    if (responses.any((r) => r.statusCode != 200)) {
      throw Exception('Failed to load surah verses');
    }

    final arabicData = json.decode(responses[0].body) as Map<String, dynamic>;
    final englishData = json.decode(responses[1].body) as Map<String, dynamic>;
    final urduData = json.decode(responses[2].body) as Map<String, dynamic>;

    final List arabicAyahs = (arabicData['data'] as Map<String, dynamic>)['ayahs'] as List;
    final List englishAyahs = (englishData['data'] as Map<String, dynamic>)['ayahs'] as List;
    final List urduAyahs = (urduData['data'] as Map<String, dynamic>)['ayahs'] as List;

    final int count = arabicAyahs.length;
    return List.generate(count, (index) {
      final a = arabicAyahs[index] as Map<String, dynamic>;
      final e = englishAyahs[index] as Map<String, dynamic>;
      final u = urduAyahs[index] as Map<String, dynamic>;
      return QuranVerse(
        numberInSurah: a['numberInSurah'] as int,
        arabic: a['text'] as String,
        translationEn: e['text'] as String? ?? '',
        translationUr: u['text'] as String? ?? '',
      );
    });
  }
}
