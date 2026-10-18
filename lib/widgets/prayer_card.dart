import 'package:flutter/material.dart';
import '../models/prayer_timing.dart';
import '../theme/app_colors.dart';

class PrayerCard extends StatelessWidget {
  final List<PrayerTiming> prayers;

  const PrayerCard({super.key, required this.prayers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chevron_right, color: Colors.black, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Prayer Times',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_left, color: Colors.black, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          ...prayers.map((prayer) => _buildPrayerItem(context, prayer)),
        ],
      ),
    );
  }

  Widget _buildPrayerItem(BuildContext context, PrayerTiming prayer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayer.arabicName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  prayer.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              prayer.time,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
