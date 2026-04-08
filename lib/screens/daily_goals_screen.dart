import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/prayer_timings_data.dart';
import '../models/prayer_timing.dart';
import '../theme/app_colors.dart';

class DailyGoalsScreen extends StatefulWidget {
  const DailyGoalsScreen({super.key});

  @override
  State<DailyGoalsScreen> createState() => _DailyGoalsScreenState();
}

class _DailyGoalsScreenState extends State<DailyGoalsScreen> {
  RamadanDay? _todayData;
  bool _loading = true;

  // Quran goal
  int _quranPagesTarget = 20;
  int _quranPagesDone = 0;
  bool _quranCompleted = false;

  // Salah tracker
  final List<String> _prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  late Map<String, bool> _prayed;
  late Map<String, bool> _inMasjid;
  late Map<String, bool> _onTime;

  // Zikr goal
  int _zikrTarget = 100;
  int _zikrCurrent = 0;

  // Dua of the day
  String _duaArabic = 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ';
  String _duaMeaning = 'Our Lord, grant us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.';
  bool _duaMemorized = false;

  // Sunnah action
  String _sunnahTitle = 'Pray 2 Sunnah before Fajr';
  String _sunnahDescription = 'Guard the two Sunnah rakʿahs before Fajr; they are better than the world and what is in it.';
  bool _sunnahCompleted = false;

  // Fasting tracker
  bool _fastCompleted = false;
  int _fastRating = 3; // 1-5

  // Reflection
  String _reflection = '';

  // Streak & rewards
  int _streakDays = 0;
  int _longestStreak = 0;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _prayed = {for (final p in _prayerNames) p: false};
    _inMasjid = {for (final p in _prayerNames) p: false};
    _onTime = {for (final p in _prayerNames) p: false};
    _loadState();
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final today = PrayerTimingsData.getTodayRamadanDay();
    final key = _todayKey;

    setState(() {
      _todayData = today;
      _quranPagesTarget = prefs.getInt('daily_quran_target') ?? 20;
      _quranPagesDone = prefs.getInt('daily_quran_done_$key') ?? 0;
      _quranCompleted = prefs.getBool('daily_quran_completed_$key') ?? false;

      for (final p in _prayerNames) {
        _prayed[p] = prefs.getBool('daily_prayed_${p}_$key') ?? false;
        _inMasjid[p] = prefs.getBool('daily_prayed_masjid_${p}_$key') ?? false;
        _onTime[p] = prefs.getBool('daily_prayed_ontime_${p}_$key') ?? false;
      }

      _zikrTarget = prefs.getInt('daily_zikr_target') ?? 100;
      _zikrCurrent = prefs.getInt('daily_zikr_current_$key') ?? 0;

      _duaMemorized = prefs.getBool('daily_dua_memorized_$key') ?? false;
      _sunnahCompleted = prefs.getBool('daily_sunnah_completed_$key') ?? false;

      _fastCompleted = prefs.getBool('daily_fast_completed_$key') ?? false;
      _fastRating = prefs.getInt('daily_fast_rating_$key') ?? 3;

      _reflection = prefs.getString('daily_reflection_$key') ?? '';

      _streakDays = prefs.getInt('daily_goals_streak') ?? 0;
      _longestStreak = prefs.getInt('daily_goals_longest_streak') ?? 0;
      _xp = prefs.getInt('daily_goals_xp_total') ?? 0;

      _loading = false;
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _todayKey;

    await prefs.setInt('daily_quran_target', _quranPagesTarget);
    await prefs.setInt('daily_quran_done_$key', _quranPagesDone);
    await prefs.setBool('daily_quran_completed_$key', _quranCompleted);

    for (final p in _prayerNames) {
      await prefs.setBool('daily_prayed_${p}_$key', _prayed[p] ?? false);
      await prefs.setBool('daily_prayed_masjid_${p}_$key', _inMasjid[p] ?? false);
      await prefs.setBool('daily_prayed_ontime_${p}_$key', _onTime[p] ?? false);
    }

    await prefs.setInt('daily_zikr_target', _zikrTarget);
    await prefs.setInt('daily_zikr_current_$key', _zikrCurrent);

    await prefs.setBool('daily_dua_memorized_$key', _duaMemorized);
    await prefs.setBool('daily_sunnah_completed_$key', _sunnahCompleted);

    await prefs.setBool('daily_fast_completed_$key', _fastCompleted);
    await prefs.setInt('daily_fast_rating_$key', _fastRating);

    await prefs.setString('daily_reflection_$key', _reflection);

    // Recompute goals, streak, and XP
    _updateStreakAndRewards(prefs, key);
  }

  void _updateStreakAndRewards(SharedPreferences prefs, String key) {
    final int totalGoals = 5; // Quran, Salah, Zikr, Dua, Sunnah

    int completedGoals = 0;
    if (_quranCompleted) completedGoals++;
    final allSalahPrayed = _prayerNames.every((p) => _prayed[p] == true);
    if (allSalahPrayed) completedGoals++;
    if (_zikrCurrent >= _zikrTarget) completedGoals++;
    if (_duaMemorized) completedGoals++;
    if (_sunnahCompleted) completedGoals++;

    // Base XP: 10 per completed goal
    int xpToday = completedGoals * 10;
    _xp = xpToday + (prefs.getInt('daily_goals_xp_total') ?? 0);
    prefs.setInt('daily_goals_xp_total', _xp);

    // Streak only if Quran and Salah and Fasting are done
    final dayCompleted = _quranCompleted && allSalahPrayed && _fastCompleted;
    final lastDateStr = prefs.getString('daily_goals_last_date');
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    int streak = _streakDays;
    if (dayCompleted) {
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
              // same day, keep
            } else {
              streak = 1;
            }
          }
        } catch (_) {
          streak = 1;
        }
      }

      _streakDays = streak;
      prefs.setInt('daily_goals_streak', _streakDays);
      prefs.setString('daily_goals_last_date', key);

      if (_streakDays > _longestStreak) {
        _longestStreak = _streakDays;
        prefs.setInt('daily_goals_longest_streak', _longestStreak);
      }
    }
  }

  double get _todayGoalsProgress {
    final int totalGoals = 5; // Quran, Salah, Zikr, Dua, Sunnah
    int completedGoals = 0;
    if (_quranCompleted) completedGoals++;
    if (_prayerNames.every((p) => _prayed[p] == true)) completedGoals++;
    if (_zikrCurrent >= _zikrTarget) completedGoals++;
    if (_duaMemorized) completedGoals++;
    if (_sunnahCompleted) completedGoals++;
    return (completedGoals / totalGoals).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _todayData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Daily Goals'),
          backgroundColor: AppColors.primaryGreen,
        ),
        backgroundColor: AppColors.skyDark,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Goals'),
        backgroundColor: AppColors.primaryGreen,
      ),
      backgroundColor: AppColors.skyDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTodayHeader(),
            const SizedBox(height: 16),
            _buildQuranGoalCard(),
            const SizedBox(height: 16),
            _buildSalahTracker(),
            const SizedBox(height: 16),
            _buildZikrGoal(),
            const SizedBox(height: 16),
            _buildDuaOfTheDay(),
            const SizedBox(height: 16),
            _buildSunnahAction(),
            const SizedBox(height: 16),
            _buildFastingTracker(),
            const SizedBox(height: 16),
            _buildReflectionSection(),
            const SizedBox(height: 16),
            _buildStreakAndRewards(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayHeader() {
    final day = _todayData!;
    final gregorian = DateFormat('d MMMM yyyy').format(day.date);
    final hijriDay = day.day; // Ramadan day number
    const hijriMonth = 'Ramadan';
    const hijriYear = '1447';

    final int totalGoals = 5;
    int completedGoals = 0;
    if (_quranCompleted) completedGoals++;
    if (_prayerNames.every((p) => _prayed[p] == true)) completedGoals++;
    if (_zikrCurrent >= _zikrTarget) completedGoals++;
    if (_duaMemorized) completedGoals++;
    if (_sunnahCompleted) completedGoals++;

    final progress = _todayGoalsProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
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
          Text(
            'Hijri: $hijriDay $hijriMonth $hijriYear',
            style: const TextStyle(color: AppColors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Gregorian: $gregorian',
            style: const TextStyle(color: AppColors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'Ramadan Day ${day.day} of 30',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$completedGoals of $totalGoals goals completed',
            style: const TextStyle(color: AppColors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.darkGreen,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranGoalCard() {
    final juz = _todayData!.juzNumber;
    final progress = _quranPagesTarget > 0
        ? (_quranPagesDone / _quranPagesTarget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quran Goal',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Today's Juz: Juz $juz",
            style: const TextStyle(color: AppColors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Target: $_quranPagesTarget pages',
            style: const TextStyle(color: AppColors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Read: $_quranPagesDone / $_quranPagesTarget pages',
            style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.darkGreen,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to Quran reading screen via home progress card; here just a hint
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Open Daily Quran from Home to start reading.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Start Reading'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: _quranCompleted,
                      onChanged: (v) {
                        setState(() {
                          _quranCompleted = v ?? false;
                        });
                        _saveState();
                      },
                      activeColor: AppColors.accentGreen,
                    ),
                    const Expanded(
                      child: Text(
                        'Mark as Completed',
                        style: TextStyle(color: AppColors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mic recitation tracking will be added with backend API.')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.gold),
                ),
                icon: const Icon(Icons.mic),
                label: const Text('Mic Recitation'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final controller = TextEditingController(text: _quranPagesTarget.toString());
                    final result = await showDialog<int?>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppColors.skyDark,
                          title: const Text('Change Quran pages target', style: TextStyle(color: AppColors.white)),
                          content: TextField(
                            controller: controller,
                            style: const TextStyle(color: AppColors.white),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 20',
                              hintStyle: TextStyle(color: AppColors.white70),
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
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

                    if (result != null && result > 0) {
                      setState(() {
                        _quranPagesTarget = result;
                      });
                      _saveState();
                    }
                  },
                  child: const Text('Change Target'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalahTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Salah Tracker',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._prayerNames.map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Checkbox(
                          value: _prayed[p] ?? false,
                          activeColor: AppColors.accentGreen,
                          onChanged: (v) {
                            setState(() {
                              _prayed[p] = v ?? false;
                            });
                            _saveState();
                          },
                        ),
                        const Text('Prayed', style: TextStyle(color: AppColors.white70, fontSize: 12)),
                        const SizedBox(width: 8),
                        Checkbox(
                          value: _inMasjid[p] ?? false,
                          activeColor: AppColors.gold,
                          onChanged: (v) {
                            setState(() {
                              _inMasjid[p] = v ?? false;
                            });
                            _saveState();
                          },
                        ),
                        const Text('Masjid', style: TextStyle(color: AppColors.white70, fontSize: 12)),
                        const SizedBox(width: 8),
                        Checkbox(
                          value: _onTime[p] ?? false,
                          activeColor: AppColors.accentGreen,
                          onChanged: (v) {
                            setState(() {
                              _onTime[p] = v ?? false;
                            });
                            _saveState();
                          },
                        ),
                        const Text('On time', style: TextStyle(color: AppColors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildZikrGoal() {
    final progress = _zikrTarget > 0
        ? (_zikrCurrent / _zikrTarget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zikr / Tasbeeh Goal',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Example: SubhanAllah – 33, Alhamdulillah – 33, Allahu Akbar – 34',
            style: TextStyle(color: AppColors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: AppColors.darkGreen,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_zikrCurrent',
                          style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'of $_zikrTarget',
                          style: const TextStyle(color: AppColors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _zikrCurrent++;
                        });
                        _saveState();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Counter'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final controller = TextEditingController(text: _zikrTarget.toString());
                        final result = await showDialog<int?>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: AppColors.skyDark,
                              title: const Text('Change Zikr target', style: TextStyle(color: AppColors.white)),
                              content: TextField(
                                controller: controller,
                                style: const TextStyle(color: AppColors.white),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 100',
                                  hintStyle: TextStyle(color: AppColors.white70),
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
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

                        if (result != null && result > 0) {
                          setState(() {
                            _zikrTarget = result;
                          });
                          _saveState();
                        }
                      },
                      child: const Text('Change Target'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDuaOfTheDay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dua of the Day',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _duaArabic,
            style: const TextStyle(color: AppColors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _duaMeaning,
            style: const TextStyle(color: AppColors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dua audio playback can be added later.')),
                  );
                },
                icon: const Icon(Icons.volume_up, color: AppColors.gold),
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: _duaMemorized,
                activeColor: AppColors.accentGreen,
                onChanged: (v) {
                  setState(() {
                    _duaMemorized = v ?? false;
                  });
                  _saveState();
                },
              ),
              const Text('Mark memorized', style: TextStyle(color: AppColors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSunnahAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sunnah Action',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _sunnahTitle,
            style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            _sunnahDescription,
            style: const TextStyle(color: AppColors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _sunnahCompleted = true;
                  });
                  _saveState();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Mark Completed'),
              ),
              const SizedBox(width: 12),
              if (_sunnahCompleted)
                const Text('Completed', style: TextStyle(color: AppColors.gold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFastingTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fasting Tracker',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Fast completed?', style: TextStyle(color: AppColors.white70, fontSize: 13)),
              const SizedBox(width: 8),
              Switch(
                value: _fastCompleted,
                activeColor: AppColors.accentGreen,
                onChanged: (v) {
                  setState(() {
                    _fastCompleted = v;
                  });
                  _saveState();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Rate your fast today (1–5):', style: TextStyle(color: AppColors.white70, fontSize: 13)),
          Row(
            children: List.generate(5, (index) {
              final rating = index + 1;
              final selected = rating <= _fastRating;
              return IconButton(
                onPressed: () {
                  setState(() {
                    _fastRating = rating;
                  });
                  _saveState();
                },
                icon: Icon(
                  Icons.star,
                  color: selected ? AppColors.gold : Colors.white24,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionSection() {
    final controller = TextEditingController(text: _reflection);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reflection',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Today I improved in…',
            style: TextStyle(color: AppColors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 3,
            style: const TextStyle(color: AppColors.white),
            decoration: const InputDecoration(
              hintText: 'Write a short reflection for today',
              hintStyle: TextStyle(color: AppColors.white70),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _reflection = value;
            },
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
              _saveState();
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _reflection = controller.text;
                _saveState();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reflection saved.')),
                );
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakAndRewards() {
    final List<String> badges = [];
    if (_streakDays >= 3) badges.add('3-day Consistency');
    if (_streakDays >= 7) badges.add('7-day Streak');
    if (_longestStreak >= 10) badges.add('10 Perfect Days');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Streak & Rewards',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orangeAccent),
              const SizedBox(width: 8),
              Text(
                '$_streakDays Day Streak',
                style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Longest streak: $_longestStreak days',
            style: const TextStyle(color: AppColors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'XP: $_xp',
            style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (badges.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: badges
                  .map(
                    (b) => Chip(
                      label: Text(b),
                      backgroundColor: AppColors.darkGreen,
                      labelStyle: const TextStyle(color: AppColors.white, fontSize: 12),
                    ),
                  )
                  .toList(),
            )
          else
            const Text(
              'Complete more days to unlock badges.',
              style: TextStyle(color: AppColors.white70, fontSize: 13),
            ),
        ],
      ),
    );
  }
}
