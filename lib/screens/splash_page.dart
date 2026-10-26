import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/splash.png',
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Center(
            child: Text('IMAGE ERROR: $e',
                style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
