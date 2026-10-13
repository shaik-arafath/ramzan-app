import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/prayer_timings_data.dart';
import '../models/prayer_timing.dart';
import '../theme/app_colors.dart';
import 'daily_quran_screen.dart';

class QuranProgressScreen extends StatefulWidget {
  const QuranProgressScreen({super.key});

  @override
  State<QuranProgressScreen> createState() => _QuranProgressScreenState();
}

class _QuranProgressScreenState extends State<QuranProgressScreen> {
  RamadanDay? _todayData;

  bool _loading = true;

  // Targets & state
  int _dailyTargetPages = 20; // default ~1 juz worth of pages (customizable)
  int _todayPagesRead = 0;
  int _streakDays = 0;
  List<bool> _juzCompleted = List<bool>.filled(30, false);
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final today = PrayerTimingsData.getTodayRamadanDay();
    final prefs = await SharedPreferences.getInstance();

    final dailyTarget = prefs.getInt('quran_daily_target_pages') ?? 20;
    final todayKey = _todayKey;

    final todayPages = prefs.getInt('quran_today_pages_$todayKey') ?? 0;
    final streak = prefs.getInt('quran_streak_days') ?? 0;

    final juzCompletedRaw = prefs.getString('quran_juz_completed') ?? '';
    List<bool> juzCompleted = List<bool>.filled(30, false);
    if (juzCompletedRaw.isNotEmpty) {
      final parts = juzCompletedRaw.split(',');
      for (int i = 0; i < parts.length && i < 30; i++) {
        juzCompleted[i] = parts[i] == '1';
      }
    }

    final historyRaw = prefs.getString('quran_reading_history') ?? '[]';
    List<Map<String, dynamic>> history = [];
    try {
      final decoded = jsonDecode(historyRaw);
      if (decoded is List) {
        history = decoded
            .whereType<Map>()
            .map<Map<String, dynamic>>((e) => e.map((key, value) => MapEntry(key.toString(), value)))
            .toList();
      }
    } catch (_) {
      history = [];
    }

    setState(() {
      _todayData = today;
      _dailyTargetPages = dailyTarget;
      _todayPagesRead = todayPages;
      _streakDays = streak;
      _juzCompleted = juzCompleted;
      _history = history;
      _loading = false;
    });
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int get _currentJuzIndex {
    if (_todayData == null) return 0;
    final n = _todayData!.juzNumber;
    if (n <= 0) return 0;
    if (n > 30) return 29;
    return n - 1;
  }

  int get _completedJuzCount => _juzCompleted.where((e) => e).length;

  double get _overallCompletionPercent => (_completedJuzCount / 30.0).clamp(0.0, 1.0);

  Future<void> _saveState({bool updateStreak = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey;

    await prefs.setInt('quran_daily_target_pages', _dailyTargetPages);
    await prefs.setInt('quran_today_pages_$todayKey', _todayPagesRead);

    // Save juz completion flags
    final flags = _juzCompleted.map((e) => e ? '1' : '0').join(',');
    await prefs.setString('quran_juz_completed', flags);

    // Streak
    if (updateStreak && _todayPagesRead > 0) {
      final lastDateStr = prefs.getString('quran_last_read_date');
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      int streak = _streakDays;

      if (lastDateStr == null || lastDateStr.isEmpty) {
        streak = 1;
      } else {
        try {
          final parts = lastDateStr.split('-');
          if (parts.length == 3) {
            final ldYear = int.parse(parts[0]);
            final ldMonth = int.parse(parts[1]);
            final ldDay = int.parse(parts[2]);
            final lastDate = DateTime(ldYear, ldMonth, ldDay);
            final diff = todayDate.difference(lastDate).inDays;
            if (diff == 1) {
              streak = _streakDays + 1;
            } else if (diff == 0) {
              // same day, keep streak
            } else {
              streak = 1;
            }
          }
        } catch (_) {
          streak = 1;
        }
      }

      _streakDays = streak;
      await prefs.setInt('quran_streak_days', _streakDays);
      await prefs.setString('quran_last_read_date', todayKey);
    }

    // Update history entry
    List<Map<String, dynamic>> history = List<Map<String, dynamic>>.from(_history);
    final existingIndex = history.indexWhere((e) => e['date'] == todayKey);
    if (existingIndex >= 0) {
      history[existingIndex]['pages'] = _todayPagesRead;
    } else {
      history.add({'date': todayKey, 'pages': _todayPagesRead});
    }

    // Keep latest first when displaying; store as-is
    await prefs.setString('quran_reading_history', jsonEncode(history));

    setState(() {
      _history = history;
    });
  }

  Future<void> _addPages() async {
    final controller = TextEditingController();
    final result = await showDialog<int?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBlack,
          title: const Text(
            'Add pages',
            style: TextStyle(color: AppColors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.white),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'How many pages did you read?',
              hintStyle: TextStyle(color: AppColors.white70),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final v = int.tryParse(controller.text.trim());
                Navigator.of(context).pop(v);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == null || result <= 0) return;

    setState(() {
      _todayPagesRead += result;
      if (_todayPagesRead < 0) _todayPagesRead = 0;
    });

    await _saveState(updateStreak: true);
  }

  Future<void> _markTodayCompleted() async {
    final idx = _currentJuzIndex;
    setState(() {
      _juzCompleted[idx] = true;
      if (_todayPagesRead < _dailyTargetPages) {
        _todayPagesRead = _dailyTargetPages;
      }
    });

    await _saveState(updateStreak: true);
  }

  Future<void> _changeTarget() async {
    final controller = TextEditingController(text: _dailyTargetPages.toString());
    final result = await showDialog<int?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBlack,
          title: const Text(
            'Change daily target',
            style: TextStyle(color: AppColors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Set pages per day (approx. 20 pages ≈ 1 Juz):',
                  style: TextStyle(color: AppColors.white70, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: AppColors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'e.g. 20',
                  hintStyle: TextStyle(color: AppColors.white70),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(20);
                    },
                    child: const Text('1 Juz (20 pages)'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(10);
                    },
                    child: const Text('10 pages'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final v = int.tryParse(controller.text.trim());
                Navigator.of(context).pop(v);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null || result <= 0) return;

    setState(() {
      _dailyTargetPages = result;
    });

    await _saveState(updateStreak: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _todayData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quran Progress'),
          backgroundColor: AppColors.darkBlack,
        ),
        backgroundColor: AppColors.darkBlack,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    final overallPercent = (_overallCompletionPercent * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Progress'),
        backgroundColor: AppColors.darkBlack,
      ),
      backgroundColor: AppColors.darkBlack,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOverallCircle(overallPercent),
            const SizedBox(height: 24),
            _buildTodayCard(),
            const SizedBox(height: 24),
            _buildJuzGrid(),
            const SizedBox(height: 24),
            _buildStreakSection(),
            const SizedBox(height: 16),
            _buildHistorySection(),
            const SizedBox(height: 16),
            _buildTargetSettingsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallCircle(int percent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Ramadan Completion',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _overallCompletionPercent,
                  strokeWidth: 8,
                  backgroundColor: AppColors.lightBlack,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_completedJuzCount of 30 Juz completed',
                      style: const TextStyle(
                        color: AppColors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DailyQuranScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.menu_book),
            label: const Text('Read Quran'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard() {
    final target = _dailyTargetPages;
    final read = _todayPagesRead;
    final progress = target > 0 ? (read / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Goal",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Target: $target pages',
            style: const TextStyle(color: AppColors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Read today: $read / $target pages',
            style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.lightBlack,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _markTodayCompleted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark as Completed'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addPages,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(color: AppColors.gold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Pages'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJuzGrid() {
    final current = _currentJuzIndex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Juz Tracker',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final completed = _juzCompleted[index];
              final isCurrent = index == current;
              Color bg;
              Color borderColor = Colors.transparent;
              Color textColor;

              if (completed) {
                bg = AppColors.gold;
                textColor = AppColors.white;
              } else if (isCurrent) {
                bg = AppColors.mediumBlack;
                textColor = AppColors.white;
                borderColor = AppColors.gold;
              } else {
                bg = AppColors.lightBlack;
                textColor = AppColors.white70;
              }

              return Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_streakDays Day Streak',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Keep your daily Quran habit alive.',
                style: TextStyle(color: AppColors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withOpacity(0.5)),
        ),
        child: const Text(
          'No reading history yet.',
          style: TextStyle(color: AppColors.white70),
        ),
      );
    }

    final sorted = List<Map<String, dynamic>>.from(_history)
      ..sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reading History',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...sorted.take(10).map((item) {
            final date = item['date']?.toString() ?? '';
            final pages = (item['pages'] ?? 0) as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: const TextStyle(color: AppColors.white70, fontSize: 13),
                  ),
                  Text(
                    '$pages pages',
                    style: const TextStyle(color: AppColors.gold, fontSize: 13),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTargetSettingsRow() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: _changeTarget,
        icon: const Icon(Icons.settings, color: AppColors.gold),
        label: const Text(
          'Change Target',
          style: TextStyle(color: AppColors.gold),
        ),
      ),
    );
  }
}
