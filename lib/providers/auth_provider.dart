import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isAdmin = false;

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isAdmin => _isAdmin;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _user = _authService.currentUser;
    if (_user != null) {
      await _loadUserProfile();
    }
    notifyListeners();

    // Listen to auth state changes
    _authService.authState.listen((data) {
      _user = data.session?.user;
      if (_user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
        _isAdmin = false;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    try {
      _userProfile = await _authService.getUserProfile(_user!.id);
      _isAdmin = await _authService.isAdmin();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      // Fallback: create a basic profile from auth user data
      if (_user != null) {
        _userProfile = {
          'full_name': _user!.userMetadata?['full_name'] ?? 
                       _user!.email?.split('@')[0] ?? 'User',
          'email': _user!.email,
          'role': 'user',
        };
        _isAdmin = false;
        notifyListeners();
      }
    }
  }

  Future<void> reloadProfile() async {
    await _loadUserProfile();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signIn(email: email, password: password);
      _user = _authService.currentUser;
      await _loadUserProfile();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      return true;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userProfile = null;
    _isAdmin = false;
    notifyListeners();
  }
}
