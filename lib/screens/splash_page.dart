import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
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
    try {
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)),
        _initApp(),
      ]).timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Startup error: $e');
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _initApp() async {
    // Put your old startup code here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset('assets/splash.png', fit: BoxFit.cover),
      ),
    );
  }
}
