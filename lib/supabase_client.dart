import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabase {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://epwhtdzdokrzrpwltvir.supabase.co',
      anonKey: 'sb_publishable_9vCD3TjH-9bESl5A4edMtw_qnCbHLE4',
    );
  }
}

