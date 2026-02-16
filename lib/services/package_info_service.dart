import 'package:flutter/services.dart';
import 'dart:io';

class PackageInfoService {
  static String? _packageName;

  static Future<String> getPackageName() async {
    if (_packageName != null) return _packageName!;
    
    if (Platform.isAndroid) {
      try {
        const platform = MethodChannel('com.ramzan_app/package_info');
        _packageName = await platform.invokeMethod('getPackageName') as String?;
      } catch (e) {
        print('Error getting package name: $e');
      }
    }
    
    // Fallback to default package name
    return _packageName ?? 'com.example.ramzan_app';
  }
}
