import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/prayer_timing.dart';
import '../services/prayer_time_service.dart';
import '../data/prayer_timings_data.dart';
import '../widgets/prayer_card.dart';
import '../widgets/quran_progress_card.dart';
import '../widgets/zikr_card.dart';
import '../widgets/sunnah_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RamadanDay? _todayData;

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  void _loadTodayData() {
    setState(() {
      _todayData = PrayerTimingsData.getTodayRamadanDay();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_todayData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ramadan Planner'),
          backgroundColor: const Color(0xFF1F7B4F),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Ramadan data not available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ramadan Planner'),
        backgroundColor: const Color(0xFF1F7B4F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadTodayData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(_todayData!),
              const SizedBox(height: 20),
              _buildTimingCard(_todayData!),
              const SizedBox(height: 20),
              PrayerCard(prayers: _todayData!.prayers),
              const SizedBox(height: 20),
              QuranProgressCard(day: _todayData!.day, juzNumber: _todayData!.juzNumber),
              const SizedBox(height: 20),
              ZikrCard(zikr: _todayData!.zikr),
              const SizedBox(height: 20),
              SunnahCard(sunnah: _todayData!.sunnah),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(RamadanDay day) {
    final formatter = DateFormat('EEEE, MMMM d, yyyy');
    final formattedDate = formatter.format(day.date);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F7B4F), Color(0xFF2A9D5D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Day ${day.day} of Ramadan',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingCard(RamadanDay day) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade300, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.wb_sunny, color: Color(0xFF1F7B4F), size: 40),
                const SizedBox(height: 8),
                const Text(
                  'Sehri Ends',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day.sehriTime,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F7B4F),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 80,
            color: Colors.amber.shade300,
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.nightlight_round, color: Color(0xFF1F7B4F), size: 40),
                const SizedBox(height: 8),
                const Text(
                  'Iftar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day.iftarTime,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F7B4F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
