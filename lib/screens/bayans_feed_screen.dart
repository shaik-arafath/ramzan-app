import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_colors.dart';
import '../services/supabase_content_service.dart';
import '../models/bayan.dart';

class BayansFeedScreen extends StatefulWidget {
  final int initialIndex;

  const BayansFeedScreen({super.key, this.initialIndex = 0});

  @override
  State<BayansFeedScreen> createState() => _BayansFeedScreenState();
}

class _BayansFeedScreenState extends State<BayansFeedScreen> {
  final SupabaseContentService _contentService = SupabaseContentService();
  late Future<List<Bayan>> _futureBayans;

  // Map from bayan ID to its video controller.
  final Map<String, VideoPlayerController> _controllers = {};
  late PageController _pageController;
  int _currentIndex = 0;
  final Set<int> _liked = {};
  final Set<int> _saved = {};

  @override
  void initState() {
    super.initState();
    _futureBayans = _contentService.fetchBayans();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  Future<void> _initControllerForDoc(String id, String videoUrl) async {
    if (_controllers.containsKey(id)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _controllers[id] = controller;
    await controller.initialize();
    controller.setLooping(true);
    await controller.play();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _disposeController(String id) async {
    final c = _controllers.remove(id);
    await c?.dispose();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _togglePlayPause(String id) {
    final controller = _controllers[id];
    if (controller == null) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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

          // Use the list as-is so order stays stable and controllers line up with items.
          final bayans = List<Bayan>.from(snapshot.data ?? []);
          if (bayans.isEmpty) {
            return const Center(
              child: Text(
                'No bayans available yet.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: bayans.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final bayan = bayans[index];
              final id = bayan.id;
              final title = bayan.title;
              final description = bayan.description;
              final videoUrl = bayan.videoUrl;

              if (videoUrl.isNotEmpty) {
                _initControllerForDoc(id, videoUrl);
              }
              final controller = _controllers[id];

              // Ensure only the currently visible page's video is playing to
              // avoid overlapping audio or mismatched sound.
              if (controller != null && controller.value.isInitialized) {
                if (index == _currentIndex) {
                  if (!controller.value.isPlaying) {
                    controller.play();
                  }
                } else {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  }
                }
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () => _togglePlayPause(id),
                    child: controller != null && controller.value.isInitialized
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: controller.value.size.width,
                              height: controller.value.size.height,
                              child: VideoPlayer(controller),
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator(color: AppColors.gold),
                          ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 32,
                    right: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (description.isNotEmpty)
                          Text(
                            description,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          const Text(
                            'Swipe up for next, tap to pause/play.',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 32,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (_liked.contains(index)) {
                                _liked.remove(index);
                              } else {
                                _liked.add(index);
                              }
                            });
                          },
                          icon: Icon(
                            Icons.favorite,
                            color: _liked.contains(index) ? Colors.redAccent : Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (_saved.contains(index)) {
                                _saved.remove(index);
                              } else {
                                _saved.add(index);
                              }
                            });
                          },
                          icon: Icon(
                            Icons.bookmark,
                            color: _saved.contains(index) ? AppColors.gold : Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Share coming soon')),
                            );
                          },
                          icon: const Icon(Icons.share, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
