import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuranProgressCard extends StatelessWidget {
  final int day;
  final int juzNumber;

  const QuranProgressCard({super.key, required this.day, required this.juzNumber});

  @override
  Widget build(BuildContext context) {
    final progress = (day / 29) * 100;

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
            offset: const Offset(0, 2),
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
                'Quran Reading Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 12,
              backgroundColor: AppColors.darkGreen,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day $day of 29',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.white70,
                ),
              ),
              Text(
                'Juz $juzNumber',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
