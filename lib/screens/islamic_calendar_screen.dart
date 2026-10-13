import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  bool _loading = true;
  String? _error;

  String? _hijriDate; // e.g. 10 Ramadan 1446
  String? _hijriWeekday;
  String? _gregorianDate; // e.g. 19 February 2026
  String? _hijriYear; // e.g. 1446
  int? _hijriMonthNumber; // 1-12
  String? _hijriMonthName;
  int? _hijriDayNumber; // today's day in month
  int? _firstWeekdayOfMonth; // 0=Sun..6=Sat

  // Currently displayed month in the grid (can differ from today's month)
  int? _displayMonthNumber;
  String? _displayMonthName;
  String? _displayYear;
  int? _displayFirstWeekday;

  @override
  void initState() {
    super.initState();
    _loadTodayHijri();
  }

  Future<void> _loadTodayHijri() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final day = now.day.toString().padLeft(2, '0');
      final month = now.month.toString().padLeft(2, '0');
      final year = now.year.toString();

      // AlAdhan gToH API: https://api.aladhan.com/v1/gToH?date=DD-MM-YYYY
      final uri = Uri.parse('https://api.aladhan.com/v1/gToH?date=$day-$month-$year');
      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        throw Exception('Failed to fetch Hijri date');
      }

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      final hijri = data['hijri'] as Map<String, dynamic>;
      final gregorian = data['gregorian'] as Map<String, dynamic>;

      final hijriDay = hijri['day']?.toString() ?? '';
      final hijriMonth = (hijri['month']?['en'] ?? '').toString();
      final hijriMonthNumber = (hijri['month']?['number'] ?? 0) as int;
      final hijriYear = hijri['year']?.toString() ?? '';
      final hijriWeekday = (hijri['weekday']?['en'] ?? '').toString();

      final gregDay = gregorian['day']?.toString() ?? '';
      final gregMonth = (gregorian['month']?['en'] ?? '').toString();
      final gregYear = gregorian['year']?.toString() ?? '';

      final int hijriDayNum = int.tryParse(hijriDay) ?? 1;
      final int weekdayIndex = _weekdayIndexFromName(hijriWeekday);
      // Compute first day of Hijri month weekday (0=Sun..6=Sat)
      final int firstWeekday = (weekdayIndex - ((hijriDayNum - 1) % 7) + 7) % 7;

      setState(() {
        _hijriDate = '$hijriDay $hijriMonth $hijriYear AH';
        _hijriWeekday = hijriWeekday;
        _gregorianDate = '$gregDay $gregMonth $gregYear';
        _hijriYear = hijriYear;
        _hijriMonthNumber = hijriMonthNumber;
        _hijriMonthName = hijriMonth;
        _hijriDayNumber = hijriDayNum;
        _firstWeekdayOfMonth = firstWeekday;
        // Initialize display month to today's month
        _displayMonthNumber = hijriMonthNumber;
        _displayMonthName = hijriMonth;
        _displayYear = hijriYear;
        _displayFirstWeekday = firstWeekday;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load Islamic date. Please check your internet.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Calendar'),
        backgroundColor: AppColors.darkBlack,
      ),
      backgroundColor: AppColors.darkBlack,
      body: Padding
        (
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.gold, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadTodayHijri,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBlack,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Today header
                      Text(
                        _hijriWeekday ?? '',
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Today',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Hijri date card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.darkBlack,
                              AppColors.lightBlack,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hijri Date',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _hijriDate ?? '',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _gregorianDate ?? '',
                              style: const TextStyle(
                                color: AppColors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Note',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Islamic (Hijri) dates are based on lunar months and may differ by a day depending on local moon sighting. This date is provided for general reference.',
                        style: TextStyle(
                          color: AppColors.white70,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Month view calendar with navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _goToPreviousMonth,
                            icon: const Icon(Icons.chevron_left, color: AppColors.white70),
                          ),
                          Column(
                            children: [
                              Text(
                                '${_displayMonthName ?? ''} ${_displayYear ?? ''}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_displayMonthNumber == _hijriMonthNumber &&
                                  _displayYear == _hijriYear)
                                const Text(
                                  '(current month)',
                                  style: TextStyle(
                                    color: AppColors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          IconButton(
                            onPressed: _goToNextMonth,
                            icon: const Icon(Icons.chevron_right, color: AppColors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _buildMonthGrid(),
                      ),
                    ],
                  ),
      ),
    );
  }
  Widget _buildMonthGrid() {
    if (_displayMonthNumber == null || _displayFirstWeekday == null) {
      return const SizedBox.shrink();
    }

    final int daysInMonth = _daysInHijriMonth(_displayMonthNumber!);
    final int firstWeekday = _displayFirstWeekday!; // 0=Sun..6=Sat

    // Build rows: header row + day rows
    final List<TableRow> rows = [];

    // Header: Sun..Sat
    rows.add(
      const TableRow(
        children: [
          _WeekdayCell('Sun'),
          _WeekdayCell('Mon'),
          _WeekdayCell('Tue'),
          _WeekdayCell('Wed'),
          _WeekdayCell('Thu'),
          _WeekdayCell('Fri'),
          _WeekdayCell('Sat'),
        ],
      ),
    );

    int day = 1;
    // First week row
    List<Widget> firstWeekCells = [];
    for (int i = 0; i < 7; i++) {
      if (i < firstWeekday) {
        firstWeekCells.add(const _EmptyDayCell());
      } else {
        firstWeekCells.add(_DayCell(
          day: day,
          isToday: _isTodayInDisplayedMonth(day),
        ));
        day++;
      }
    }
    rows.add(TableRow(children: firstWeekCells));

    // Remaining weeks
    while (day <= daysInMonth) {
      List<Widget> weekCells = [];
      for (int i = 0; i < 7; i++) {
        if (day <= daysInMonth) {
          weekCells.add(_DayCell(
            day: day,
            isToday: _isTodayInDisplayedMonth(day),
          ));
          day++;
        } else {
          weekCells.add(const _EmptyDayCell());
        }
      }
      rows.add(TableRow(children: weekCells));
    }

    return SingleChildScrollView(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: rows,
      ),
    );
  }

  bool _isTodayInDisplayedMonth(int day) {
    if (_hijriDayNumber == null ||
        _hijriMonthNumber == null ||
        _hijriYear == null ||
        _displayMonthNumber == null ||
        _displayYear == null) {
      return false;
    }

    final bool sameMonth =
        _hijriMonthNumber == _displayMonthNumber && _hijriYear == _displayYear;
    return sameMonth && _hijriDayNumber == day;
  }

  void _goToPreviousMonth() {
    if (_displayMonthNumber == null || _displayFirstWeekday == null) return;

    int month = _displayMonthNumber!;
    int year = int.tryParse(_displayYear ?? _hijriYear ?? '') ?? 1440;
    int firstWeekday = _displayFirstWeekday!;

    // Move to previous month
    month -= 1;
    if (month < 1) {
      month = 12;
      year -= 1;
    }

    final int prevMonthDays = _daysInHijriMonth(month);
    // First weekday of previous month = firstWeekday - (prevDays % 7)
    final int prevFirstWeekday =
        (firstWeekday - (prevMonthDays % 7) + 7) % 7; // 0=Sun..6=Sat

    setState(() {
      _displayMonthNumber = month;
      _displayYear = year.toString();
      _displayMonthName = _hijriMonthNameForNumber(month);
      _displayFirstWeekday = prevFirstWeekday;
    });
  }

  void _goToNextMonth() {
    if (_displayMonthNumber == null || _displayFirstWeekday == null) return;

    int month = _displayMonthNumber!;
    int year = int.tryParse(_displayYear ?? _hijriYear ?? '') ?? 1440;
    int firstWeekday = _displayFirstWeekday!;

    final int currentDays = _daysInHijriMonth(month);

    // Move to next month
    month += 1;
    if (month > 12) {
      month = 1;
      year += 1;
    }

    // First weekday of next month = firstWeekday + (currentDays % 7)
    final int nextFirstWeekday = (firstWeekday + (currentDays % 7)) % 7;

    setState(() {
      _displayMonthNumber = month;
      _displayYear = year.toString();
      _displayMonthName = _hijriMonthNameForNumber(month);
      _displayFirstWeekday = nextFirstWeekday;
    });
  }
}

int _weekdayIndexFromName(String name) {
  switch (name.toLowerCase()) {
    case 'sunday':
      return 0;
    case 'monday':
      return 1;
    case 'tuesday':
      return 2;
    case 'wednesday':
      return 3;
    case 'thursday':
      return 4;
    case 'friday':
      return 5;
    case 'saturday':
      return 6;
    default:
      return 0;
  }
}

int _daysInHijriMonth(int monthNumber) {
  // Approximate lengths; real months depend on moon sighting.
  const List<int> monthLengths = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];
  if (monthNumber < 1 || monthNumber > 12) return 30;
  return monthLengths[monthNumber - 1];
}

String _hijriMonthNameForNumber(int monthNumber) {
  switch (monthNumber) {
    case 1:
      return 'Muharram';
    case 2:
      return 'Safar';
    case 3:
      return "Rabi' al-awwal";
    case 4:
      return "Rabi' al-thani";
    case 5:
      return 'Jumada al-ula';
    case 6:
      return 'Jumada al-akhirah';
    case 7:
      return 'Rajab';
    case 8:
      return "Sha'ban";
    case 9:
      return 'Ramadan';
    case 10:
      return 'Shawwal';
    case 11:
      return "Dhul-Qa'dah";
    case 12:
      return 'Dhul-Hijjah';
    default:
      return '';
  }
}

class _WeekdayCell extends StatelessWidget {
  final String label;

  const _WeekdayCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;

  const _DayCell({required this.day, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.gold
              : AppColors.darkBlack.withOpacity(0.8),
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: AppColors.white, width: 1.5)
              : null,
        ),
        child: Text(
          '$day',
          style: TextStyle(
            color: isToday ? AppColors.darkBlack : AppColors.white,
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _EmptyDayCell extends StatelessWidget {
  const _EmptyDayCell();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 32);
  }
}
