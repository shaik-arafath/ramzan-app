import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PackageInfoService {
  static String? _packageName;

  static Future<String> getPackageName() async {
    if (_packageName != null) return _packageName!;
    
    // MethodChannel is only available on native platforms
    // For web, we skip this and use the fallback
    if (!kIsWeb && Platform.isAndroid) {
      try {
        // Use dart:mirrors or conditional compilation
        // For now, just skip on web
        final platform = const MethodChannel('com.ramzan_app/package_info');
        _packageName = await platform.invokeMethod('getPackageName') as String?;
      } catch (e) {
        print('Error getting package name: $e');
      }
    }
    
    // Fallback to default package name
    return _packageName ?? 'com.example.ramzan_app';
  }
}

// Stub for web compilation
class MethodChannel {
  final String name;
  const MethodChannel(this.name);
  Future<T?> invokeMethod<T>(String method) async => null;
}
