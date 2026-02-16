import 'package:flutter/material.dart';

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
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
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
              const Icon(Icons.favorite, color: Color(0xFF1F7B4F)),
              const SizedBox(width: 8),
              const Text(
                'Zikr After Prayer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            transliteration,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            meaning,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F7B4F),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1F7B4F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: const TextStyle(
                fontSize: 14,
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
