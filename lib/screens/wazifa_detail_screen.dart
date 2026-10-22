import 'package:flutter/material.dart';
import '../models/wazifa.dart';
import '../theme/app_colors.dart';

class WazifaDetailScreen extends StatelessWidget {
  final Wazifa wazifa;

  const WazifaDetailScreen({super.key, required this.wazifa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      appBar: AppBar(
        backgroundColor: AppColors.mediumBlack,
        title: Text(
          wazifa.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold),
              ),
              child: Text(
                wazifa.category,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Description
            const Text(
              'Description',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              wazifa.description,
              style: TextStyle(
                color: AppColors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Time
            if (wazifa.time != null) ...[
              _buildSectionCard(
                icon: Icons.access_time,
                title: 'Time',
                content: wazifa.time!,
              ),
              const SizedBox(height: 16),
            ],
            // Namaz
            if (wazifa.namaz != null) ...[
              _buildSectionCard(
                icon: Icons.mosque,
                title: 'Namaz',
                content: wazifa.namaz!,
              ),
              const SizedBox(height: 16),
            ],
            // Dua
            if (wazifa.dua != null) ...[
              _buildSectionCard(
                icon: Icons.menu_book,
                title: 'Dua',
                content: wazifa.dua!,
              ),
              const SizedBox(height: 16),
            ],
            // Ziker
            if (wazifa.ziker != null) ...[
              _buildSectionCard(
                icon: Icons.psychology,
                title: 'Ziker',
                content: wazifa.ziker!,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mediumBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: AppColors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
