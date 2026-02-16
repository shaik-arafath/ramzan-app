import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package_info_service.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSiren() async {
    try {
      if (Platform.isAndroid) {
        // Try multiple Android resource path formats
        final packageName = await PackageInfoService.getPackageName();
        
        // Method 1: android.resource:// URI
        try {
          await _player.setUrl('android.resource://$packageName/raw/siren');
          await _player.setVolume(1.0);
          await _player.play();
          return;
        } catch (e) {
          print('Method 1 failed: $e');
        }
        
        // Method 2: asset:// URI
        try {
          await _player.setUrl('asset:///android_asset/res/raw/siren.mp3');
          await _player.setVolume(1.0);
          await _player.play();
          return;
        } catch (e) {
          print('Method 2 failed: $e');
        }
      } else {
        // For other platforms
        await _player.setAsset('assets/siren.mp3');
        await _player.setVolume(1.0);
        await _player.play();
      }
    } catch (e) {
      print('Error playing siren: $e');
    }
  }

  Future<void> playAdhan() async {
    try {
      if (Platform.isAndroid) {
        // Try multiple Android resource path formats
        final packageName = await PackageInfoService.getPackageName();
        
        // Method 1: android.resource:// URI
        try {
          await _player.setUrl('android.resource://$packageName/raw/azan');
          await _player.setVolume(1.0);
          await _player.play();
          return;
        } catch (e) {
          print('Method 1 failed: $e');
        }
        
        // Method 2: asset:// URI
        try {
          await _player.setUrl('asset:///android_asset/res/raw/azan.mp3');
          await _player.setVolume(1.0);
          await _player.play();
          return;
        } catch (e) {
          print('Method 2 failed: $e');
        }
      } else {
        // For other platforms
        await _player.setAsset('assets/azan.mp3');
        await _player.setVolume(1.0);
        await _player.play();
      }
    } catch (e) {
      print('Error playing adhan: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
