/// Temporary placeholder service now that Firebase has been removed.
///
/// This keeps the rest of the app compiling while we migrate to Supabase.
class FirebaseContentService {
  /// Previously loaded global app configuration from Firestore.
  /// Now returns `null` so the UI falls back to local defaults.
  Future<Map<String, dynamic>?> fetchAppConfig() async {
    return null;
  }

  /// Previously loaded timetable overrides from Firestore.
  /// Now returns `null` so the app uses bundled Ramadan timings.
  Future<Map<String, dynamic>?> fetchTimetable() async {
    return null;
  }
}
