import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  // Map from bayan ID to webview controller
  final Map<String, WebViewController> _webControllers = {};
  // Map from bayan ID to error message
  final Map<String, String> _errors = {};
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

  bool _isInstagramUrl(String url) {
    return url.contains('instagram.com') || url.contains('instagr.am');
  }

  Future<void> _initControllerForDoc(String id, String videoUrl) async {
    if (_isInstagramUrl(videoUrl)) {
      // Use WebView for Instagram
      if (_webControllers.containsKey(id)) return;
      print('Initializing WebView for Instagram URL: $videoUrl');
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              print('Page started loading: $url');
            },
            onPageFinished: (String url) {
              print('Page finished loading: $url');
            },
          ),
        )
        ..loadRequest(Uri.parse(videoUrl));
      _webControllers[id] = controller;
      _errors.remove(id);
      if (mounted) {
        setState(() {});
      }
      return;
    }

    // Use VideoPlayer for direct video URLs
    if (_controllers.containsKey(id)) return;

    print('Initializing video controller for $id with URL: $videoUrl');
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _controllers[id] = controller;

      // Add timeout to prevent indefinite loading
      await controller.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Video initialization timeout');
        },
      );

      controller.setLooping(true);
      await controller.play();
      print('Video initialized and playing for $id');
      _errors.remove(id);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing video for $id: $e');
      _controllers.remove(id);
      _errors[id] = e.toString();
      if (mounted) {
        setState(() {});
      }
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
    for (final c in _webControllers.values) {
      // WebViewController doesn't need explicit disposal
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
              if (!_isInstagramUrl(videoUrl) && controller != null && controller.value.isInitialized) {
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
                  _isInstagramUrl(videoUrl)
                      ? _webControllers.containsKey(id)
                          ? WebViewWidget(controller: _webControllers[id]!)
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: AppColors.gold),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading Instagram...',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            )
                      : GestureDetector(
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
                              : _errors.containsKey(id)
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Error loading video',
                                              style: const TextStyle(color: Colors.white, fontSize: 16),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _errors[id]!,
                                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'URL: $videoUrl',
                                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const CircularProgressIndicator(color: AppColors.gold),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Loading video...',
                                              style: TextStyle(color: Colors.white70),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'URL: $videoUrl',
                                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
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
                        const SizedBox(height: 8),
                        if (_isInstagramUrl(videoUrl))
                          IconButton(
                            onPressed: () async {
                              final uri = Uri.parse(videoUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not open $videoUrl')),
                                );
                              }
                            },
                            icon: const Icon(Icons.open_in_new, color: Colors.white, size: 28),
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
