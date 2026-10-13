import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ZikrCard extends StatelessWidget {
  final String zikr;

  const ZikrCard({super.key, required this.zikr});

  @override
  Widget build(BuildContext context) {
    final parts = zikr.split('\n');
    final arabic = parts.isNotEmpty ? parts[0] : '';
    final transliteration = parts.length > 1 ? parts[1] : '';
    final meaning = parts.length > 2 ? parts[2] : '';
    final count = parts.length > 3 ? parts[3] : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black,
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
              const Icon(Icons.favorite, color: AppColors.gold),
              const SizedBox(width: 8),
              const Text(
                'Zikr After Prayer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            arabic,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: AppColors.white,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            transliteration,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: AppColors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            meaning,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.silver,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
