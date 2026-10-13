import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user != null) {
      try {
        // Create user profile
        await _supabase.from('user_profiles').insert({
          'user_id': response.user!.id,
          'full_name': fullName,
          'email': email,
          'role': 'user',
        });
      } catch (e) {
        // If profile creation fails, log it but don't fail the signup
        print('Error creating user profile: $e');
      }
    }

    return response;
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Ensure user profile exists after sign in
    if (response.user != null) {
      try {
        final existingProfile = await _supabase
            .from('user_profiles')
            .select()
            .eq('user_id', response.user!.id)
            .maybeSingle();

        if (existingProfile == null) {
          // Create profile if it doesn't exist
          await _supabase.from('user_profiles').insert({
            'user_id': response.user!.id,
            'full_name': response.user!.userMetadata?['full_name'] ?? 
                         response.user!.email?.split('@')[0] ?? 'User',
            'email': response.user!.email,
            'role': 'user',
          });
        }
      } catch (e) {
        print('Error ensuring user profile: $e');
      }
    }

    return response;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .single();
    return response;
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    final user = currentUser;
    if (user == null) return false;

    final profile = await getUserProfile(user.id);
    return profile?['role'] == 'admin';
  }

  // Stream auth state changes
  Stream<AuthState> get authState => _supabase.auth.onAuthStateChange;
}
