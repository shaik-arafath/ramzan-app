import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../theme/app_colors.dart';

class QiblaFinderScreen extends StatefulWidget {
  const QiblaFinderScreen({super.key});

  @override
  State<QiblaFinderScreen> createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends State<QiblaFinderScreen> {
  double? _qiblaDirection; // in degrees from North

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _qiblaDirection = _calculateQiblaDirection(
      position.latitude,
      position.longitude,
    );

    if (!mounted) return;
    setState(() {});
  }

  double _calculateQiblaDirection(double lat, double lon) {
    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;

    final latRad = lat * pi / 180;
    final kaabaLatRad = kaabaLat * pi / 180;
    final deltaLon = (kaabaLon - lon) * pi / 180;

    final y = sin(deltaLon);
    final x = cos(latRad) * tan(kaabaLatRad) -
        sin(latRad) * cos(deltaLon);

    final bearing = atan2(y, x);
    final bearingDeg = bearing * 180 / pi;

    return (bearingDeg + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Finder'),
        backgroundColor: AppColors.darkBlack,
      ),
      backgroundColor: AppColors.darkBlack,
      body: _qiblaDirection == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.heading == null) {
                  return const Center(
                    child: Text(
                      'Compass not available',
                      style: TextStyle(color: AppColors.white),
                    ),
                  );
                }

                final heading = snapshot.data!.heading!; // degrees from North
                final angle = (_qiblaDirection! - heading) * (pi / 180);

                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Qibla Direction',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: Transform.rotate(
                          angle: angle,
                          child: Image.asset(
                            'assets/compass_arrow.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
