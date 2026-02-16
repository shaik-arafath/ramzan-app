import 'package:flutter/material.dart';
import '../models/prayer_timing.dart';

class PrayerCard extends StatelessWidget {
  final List<PrayerTiming> prayers;

  const PrayerCard({super.key, required this.prayers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prayer Times',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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
                    color: Color(0xFF1F7B4F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  prayer.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F7B4F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              prayer.time,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F7B4F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
