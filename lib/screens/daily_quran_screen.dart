import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../services/quran_api_service.dart';
import '../data/prayer_timings_data.dart';

class DailyQuranScreen extends StatefulWidget {
  const DailyQuranScreen({super.key});

  @override
  State<DailyQuranScreen> createState() => _DailyQuranScreenState();
}

class _DailyQuranScreenState extends State<DailyQuranScreen> {
  final _service = QuranApiService();
  late Future<List<QuranSurah>> _futureSurahs;

  @override
  void initState() {
    super.initState();
    _futureSurahs = _service.fetchSurahs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quran'),
        backgroundColor: AppColors.darkBlack,
      ),
      backgroundColor: AppColors.darkBlack,
      body: FutureBuilder<List<QuranSurah>>(
        future: _futureSurahs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load Quran. Please check your internet connection.',
                style: const TextStyle(color: AppColors.white),
                textAlign: TextAlign.center,
              ),
            );
          }

          final surahs = snapshot.data ?? [];
          return ListView.separated(
            itemCount: surahs.length,
            separatorBuilder: (_, __) => const Divider(color: AppColors.white70),
            itemBuilder: (context, index) {
              final s = surahs[index];
              return ListTile(
                title: Text(
                  '${s.number}. ${s.name}',
                  style: const TextStyle(color: AppColors.white),
                ),
                subtitle: Text(
                  s.englishName,
                  style: const TextStyle(color: AppColors.white70, fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gold),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SurahDetailScreen(surah: s),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class SurahDetailScreen extends StatefulWidget {
  final QuranSurah surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final _service = QuranApiService();
  late Future<List<QuranVerse>> _futureVerses;
  late AudioPlayer _audioPlayer;

  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  bool _isPlaying = false;
  bool _audioError = false;

  @override
  void initState() {
    super.initState();
    _futureVerses = _service.fetchSurahVerses(widget.surah.number);
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // Use a well-known public Quran audio CDN (Alafasy recitation, 128 kbps)
      // One file per Surah: /{surahNumber}.mp3
      final url =
          'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${widget.surah.number}.mp3';
      await _audioPlayer.setUrl(url);

      _audioPlayer.durationStream.listen((d) {
        if (!mounted) return;
        setState(() {
          _audioDuration = d ?? Duration.zero;
        });
      });

      _audioPlayer.positionStream.listen((p) {
        if (!mounted) return;
        setState(() {
          _audioPosition = p;
        });
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() {
          _isPlaying = state.playing &&
              state.processingState != ProcessingState.completed;
        });

        // When audio completes, auto-mark today's Juz as completed in Quran progress
        if (state.processingState == ProcessingState.completed) {
          _onAudioCompleted();
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _audioError = true;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  double get _audioProgress {
    if (_audioDuration.inMilliseconds == 0) return 0.0;
    final value = _audioPosition.inMilliseconds / _audioDuration.inMilliseconds;
    return value.clamp(0.0, 1.0);
  }

  Future<void> _togglePlayPause() async {
    if (_audioError) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> _onAudioCompleted() async {
    // Determine today's Ramadan day and Juz
    final todayRamadan = PrayerTimingsData.getTodayRamadanDay();
    if (todayRamadan == null) return;

    final juzNumber = todayRamadan.juzNumber;
    if (juzNumber <= 0 || juzNumber > 30) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('quran_juz_completed') ?? '';

    List<bool> flags = List<bool>.filled(30, false);
    if (raw.isNotEmpty) {
      final parts = raw.split(',');
      for (int i = 0; i < parts.length && i < 30; i++) {
        flags[i] = parts[i] == '1';
      }
    }

    // Mark this Juz as completed
    flags[juzNumber - 1] = true;

    final updated = flags.map((e) => e ? '1' : '0').join(',');
    await prefs.setString('quran_juz_completed', updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.name),
        backgroundColor: AppColors.darkBlack,
      ),
      backgroundColor: AppColors.darkBlack,
      body: FutureBuilder<List<QuranVerse>>(
        future: _futureVerses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load surah. Please check your internet connection.',
                style: const TextStyle(color: AppColors.white),
                textAlign: TextAlign.center,
              ),
            );
          }

          final verses = snapshot.data ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAudioSection(),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: verses.length,
                  itemBuilder: (context, index) {
                    final v = verses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${v.numberInSurah}. ${v.arabic}',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            v.translationEn,
                            style: const TextStyle(color: AppColors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            v.translationUr,
                            style: const TextStyle(color: AppColors.gold, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAudioSection() {
    final percent = (_audioProgress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlack,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Audio Recitation',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_audioError)
                const Icon(Icons.error_outline, color: Colors.redAccent)
              else
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: AppColors.gold,
                    size: 32,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _audioProgress,
              minHeight: 8,
              backgroundColor: AppColors.lightBlack,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Completed: $percent% of this Surah',
            style: const TextStyle(color: AppColors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
