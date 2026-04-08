import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SunnahCard extends StatelessWidget {
  final String sunnah;

  const SunnahCard({super.key, required this.sunnah});

  @override
  Widget build(BuildContext context) {
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
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.gold),
              const SizedBox(width: 8),
              const Text(
                'Daily Sunnah',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sunnah,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
