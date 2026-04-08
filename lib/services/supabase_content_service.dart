import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bayan.dart';

class SupabaseContentService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Placeholder for future header config stored in Supabase.
  /// Currently returns null so the HomeScreen header uses the static gradient.
  Future<Map<String, dynamic>?> fetchAppConfig() async {
    return null;
  }

  Future<List<Bayan>> fetchBayans() async {
    final response = await _client
        .from('bayans')
        .select('*')
        .eq('active', true)
        .order('published_at', ascending: false);

    final data = response as List<dynamic>;
    return data.map((row) => Bayan.fromMap(row as Map<String, dynamic>)).toList();
  }

  /// Fetches notification messages from the 'notifications' table.
  ///
  /// Expected columns (you can adjust to match your Supabase schema):
  ///   - title (text)
  ///   - message (text)
  ///   - created_at (timestamp)
  ///   - active (bool)
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final response = await _client
        .from('notifications')
        .select('*')
        .eq('active', true)
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;
    return data.map((row) => row as Map<String, dynamic>).toList();
  }

  /// Loads the generic timetable (sehri/iftar + prayer times) from Supabase.
  ///
  /// Expects a single row in the 'timetable' table with snake_case columns
  /// like sehri_time, iftar_time, fajr, dhuhr, asr, maghrib, isha.
  Future<Map<String, dynamic>?> fetchTimetable() async {
    final data = await _client
        .from('timetable')
        .select('*')
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return data as Map<String, dynamic>;
  }
}
