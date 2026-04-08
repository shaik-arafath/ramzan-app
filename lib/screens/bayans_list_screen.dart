import 'package:flutter/material.dart';

import '../models/bayan.dart';
import '../services/supabase_content_service.dart';
import '../theme/app_colors.dart';
import 'bayans_feed_screen.dart';

class BayansListScreen extends StatefulWidget {
  const BayansListScreen({super.key});

  @override
  State<BayansListScreen> createState() => _BayansListScreenState();
}

class _BayansListScreenState extends State<BayansListScreen> {
  final SupabaseContentService _contentService = SupabaseContentService();
  late Future<List<Bayan>> _futureBayans;

  @override
  void initState() {
    super.initState();
    _futureBayans = _contentService.fetchBayans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.skyDark,
        title: const Text('Bayans'),
      ),
      backgroundColor: AppColors.skyDark,
      body: FutureBuilder<List<Bayan>>(
        future: _futureBayans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load bayans. Please try again later.',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          }

          final bayans = snapshot.data ?? [];
          if (bayans.isEmpty) {
            return const Center(
              child: Text(
                'No bayans available yet.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.separated(
            itemCount: bayans.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white24, height: 1),
            itemBuilder: (context, index) {
              final bayan = bayans[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  bayan.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: bayan.description.isNotEmpty
                    ? Text(
                        bayan.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      )
                    : null,
                trailing: const Icon(Icons.play_circle_fill, color: AppColors.gold),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BayansFeedScreen(initialIndex: index),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
