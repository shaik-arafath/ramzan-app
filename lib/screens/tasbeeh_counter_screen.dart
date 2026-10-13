import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';

class TasbeehCounterScreen extends StatefulWidget {
  const TasbeehCounterScreen({super.key});

  @override
  State<TasbeehCounterScreen> createState() => _TasbeehCounterScreenState();
}

class _TasbeehCounterScreenState extends State<TasbeehCounterScreen> {
  final Map<String, int> _dhikrTargets = const {
    'SubhanAllah': 33,
    'Alhamdulillah': 33,
    'Allahu Akbar': 34,
    'La ilaha illallah': 100,
    'Astaghfirullah': 100,
  };

  String _selectedDhikr = 'SubhanAllah';
  int _currentCount = 0;
  bool _vibrateOnTap = true;
  bool _soundOnTap = false;
  bool _autoResetOnComplete = true;
  int _dailyGoal = 500;
  int _todayTotal = 0;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey;

    setState(() {
      _selectedDhikr = prefs.getString('tasbeeh_selected_dhikr') ?? _selectedDhikr;
      _currentCount = prefs.getInt('tasbeeh_current_count_${_selectedDhikr}') ?? 0;
      _vibrateOnTap = prefs.getBool('tasbeeh_vibrate') ?? true;
      _soundOnTap = prefs.getBool('tasbeeh_sound') ?? false;
      _autoResetOnComplete = prefs.getBool('tasbeeh_auto_reset') ?? true;
      _dailyGoal = prefs.getInt('tasbeeh_daily_goal') ?? 500;
      _todayTotal = prefs.getInt('tasbeeh_total_$todayKey') ?? 0;
      _loading = false;
    });
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int get _currentTarget => _dhikrTargets[_selectedDhikr] ?? 0;

  Future<void> _saveState(int deltaForSelectedDhikr) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey;

    await prefs.setString('tasbeeh_selected_dhikr', _selectedDhikr);
    await prefs.setInt('tasbeeh_current_count_$_selectedDhikr', _currentCount);
    await prefs.setBool('tasbeeh_vibrate', _vibrateOnTap);
    await prefs.setBool('tasbeeh_sound', _soundOnTap);
    await prefs.setBool('tasbeeh_auto_reset', _autoResetOnComplete);
    await prefs.setInt('tasbeeh_daily_goal', _dailyGoal);
    await prefs.setInt('tasbeeh_total_$todayKey', _todayTotal);

    // Update history: store per-day per-dhikr totals
    final historyRaw = prefs.getString('tasbeeh_history') ?? '[]';
    final List<dynamic> historyList = jsonDecode(historyRaw);
    final existingIndex = historyList.indexWhere((e) => e['date'] == todayKey);

    Map<String, dynamic> dayEntry;
    if (existingIndex >= 0) {
      dayEntry = Map<String, dynamic>.from(historyList[existingIndex]);
    } else {
      dayEntry = {'date': todayKey, 'byDhikr': <String, int>{}};
      historyList.add(dayEntry);
    }

    final Map<String, dynamic> byDhikrDynamic =
        Map<String, dynamic>.from(dayEntry['byDhikr'] ?? <String, int>{});
    final currentForDhikr = (byDhikrDynamic[_selectedDhikr] ?? 0) as int;
    final updatedForDhikr = (currentForDhikr + deltaForSelectedDhikr).clamp(0, 1 << 31);
    byDhikrDynamic[_selectedDhikr] = updatedForDhikr;

    // Recompute total for the day from all dhikr types
    int newTotal = 0;
    for (final v in byDhikrDynamic.values) {
      newTotal += (v as int);
    }

    dayEntry['byDhikr'] = byDhikrDynamic;
    dayEntry['total'] = newTotal;

    if (existingIndex >= 0) {
      historyList[existingIndex] = dayEntry;
    }

    await prefs.setString('tasbeeh_history', jsonEncode(historyList));
  }

  Future<void> _changeDhikr(String dhikr) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCount = prefs.getInt('tasbeeh_current_count_$dhikr') ?? 0;
    setState(() {
      _selectedDhikr = dhikr;
      _currentCount = savedCount;
    });
    await _saveState(0);
  }

  Future<void> _increment(int amount) async {
    setState(() {
      _currentCount += amount;
      if (_currentCount < 0) _currentCount = 0;
      _todayTotal += amount;
      if (_todayTotal < 0) _todayTotal = 0;

      if (_autoResetOnComplete && _currentTarget > 0 && _currentCount >= _currentTarget) {
        _currentCount = 0;
      }
    });

    if (_vibrateOnTap) {
      HapticFeedback.lightImpact();
    }
    if (_soundOnTap) {
      await SystemSound.play(SystemSoundType.click);
    }

    await _saveState(amount);
  }

  Future<void> _confirmReset() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBlack,
          title: const Text(
            'Reset counter?',
            style: TextStyle(color: AppColors.silver),
          ),
          content: const Text(
            'This will reset the current dhikr count to 0.',
            style: TextStyle(color: AppColors.silver70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() {
        _currentCount = 0;
      });
      // Reset just clears current dhikr count; no change in totals.
      await _saveState(0);
    }
  }

  double get _targetProgress {
    if (_currentTarget <= 0) return 0;
    return (_currentCount / _currentTarget).clamp(0.0, 1.0);
  }

  double get _dailyGoalProgress {
    if (_dailyGoal <= 0) return 0;
    return (_todayTotal / _dailyGoal).clamp(0.0, 1.0);
  }

  Future<void> _openHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyRaw = prefs.getString('tasbeeh_history') ?? '[]';
    final List<dynamic> historyList = jsonDecode(historyRaw);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TasbeehHistoryScreen(history: historyList),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tasbeeh Counter'),
          backgroundColor: AppColors.darkBlack,
        ),
        backgroundColor: AppColors.darkBlack,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbeeh Counter'),
        backgroundColor: AppColors.darkBlack,
        actions: [
          IconButton(
            onPressed: _openHistory,
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      backgroundColor: AppColors.darkBlack,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dhikr presets
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _dhikrTargets.keys.map((dhikr) {
                  final selected = dhikr == _selectedDhikr;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(dhikr),
                      selected: selected,
                      labelStyle: TextStyle(
                        color: selected ? AppColors.darkBlack : AppColors.silver,
                      ),
                      selectedColor: AppColors.gold,
                      backgroundColor: AppColors.darkBlack,
                      onSelected: (_) => _changeDhikr(dhikr),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Target progress
            Text(
              '$_selectedDhikr',
              style: const TextStyle(
                color: AppColors.silver,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_currentCount / $_currentTarget',
              style: const TextStyle(color: AppColors.silver70),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _targetProgress,
                minHeight: 8,
                backgroundColor: AppColors.darkBlack,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),

            const SizedBox(height: 24),

            // Daily goal ring + toggles
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _dailyGoalProgress,
                        strokeWidth: 6,
                        backgroundColor: AppColors.darkBlack,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _todayTotal.toString(),
                            style: const TextStyle(
                              color: AppColors.silver,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Today',
                            style: TextStyle(
                              color: AppColors.silver70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Daily goal:',
                            style: TextStyle(color: AppColors.silver70),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Slider(
                              value: _dailyGoal.toDouble().clamp(100, 2000),
                              min: 100,
                              max: 2000,
                              divisions: 19,
                              label: '$_dailyGoal',
                              onChanged: (v) {
                                setState(() {
                                  _dailyGoal = v.round();
                                });
                                _saveState(0);
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Switch(
                            value: _vibrateOnTap,
                            onChanged: (v) {
                              setState(() => _vibrateOnTap = v);
                              _saveState(0);
                            },
                          ),
                          const Text(
                            'Vibrate on tap',
                            style: TextStyle(color: AppColors.silver70),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Switch(
                            value: _soundOnTap,
                            onChanged: (v) {
                              setState(() => _soundOnTap = v);
                              _saveState(0);
                            },
                          ),
                          const Text(
                            'Sound on tap',
                            style: TextStyle(color: AppColors.silver70),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Switch(
                            value: _autoResetOnComplete,
                            onChanged: (v) {
                              setState(() => _autoResetOnComplete = v);
                              _saveState(0);
                            },
                          ),
                          const Text(
                            'Auto reset when complete',
                            style: TextStyle(color: AppColors.silver70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Big digital counter with gestures
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => _increment(1),
                  onLongPress: () => _increment(10),
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                      _increment(-1);
                    }
                  },
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.darkBlack.withOpacity(0.8),
                          AppColors.darkBlack,
                        ],
                        center: Alignment.topLeft,
                        radius: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_currentCount',
                        style: const TextStyle(
                          color: AppColors.silver,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Reset button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _confirmReset,
                  icon: const Icon(Icons.refresh, color: AppColors.silver70),
                  label: const Text(
                    'Reset',
                    style: TextStyle(color: AppColors.silver70),
                  ),
                ),
                Text(
                  'Swipe right: -1, Long press: +10',
                  style: const TextStyle(color: AppColors.silver70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TasbeehHistoryScreen extends StatelessWidget {
  final List<dynamic> history;

  const TasbeehHistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final sorted = history
        .map<Map<String, dynamic>>((e) => {
              'date': e['date'],
              'total': e['total'],
              'byDhikr': e['byDhikr'] ?? <String, dynamic>{},
            })
        .toList()
      ..sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhikr History'),
        backgroundColor: AppColors.darkBlack,
      ),
      backgroundColor: AppColors.darkBlack,
      body: sorted.isEmpty
          ? const Center(
              child: Text(
                'No history yet',
                style: TextStyle(color: AppColors.silver70),
              ),
            )
          : ListView.separated(
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final item = sorted[index];
                final String date = item['date'] ?? '';
                final int total = (item['total'] ?? 0) as int;
                final Map<String, dynamic> byDhikrDynamic =
                    Map<String, dynamic>.from(item['byDhikr'] ?? <String, dynamic>{});

                final entries = byDhikrDynamic.entries
                    .where((e) => (e.value ?? 0) is int && (e.value as int) > 0)
                    .toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return ListTile(
                  title: Text(
                    date,
                    style: const TextStyle(color: AppColors.silver),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$total dhikr',
                        style: const TextStyle(color: AppColors.silver70),
                      ),
                      const SizedBox(height: 4),
                      if (entries.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: entries
                              .map(
                                (e) => Text(
                                  '${e.key}: ${e.value}',
                                  style: const TextStyle(
                                    color: AppColors.silver70,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
