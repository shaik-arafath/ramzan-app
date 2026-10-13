// Stub implementation for web
class PackageInfoService {
  static String? _packageName;

  static Future<String> getPackageName() async {
    return _packageName ?? 'com.example.ramzan_app';
  }
}
