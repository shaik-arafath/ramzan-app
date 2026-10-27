import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';

class SplashPage extends StatefulWidget {
  final NotificationService notificationService;
  const SplashPage({super.key, required this.notificationService});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      _initApp(),
    ]);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _initApp() async {
    try {
      await widget.notificationService
          .initialize()
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/splash.png',
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Center(
            child: Text('$e', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
