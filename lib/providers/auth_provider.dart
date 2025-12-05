import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Authentication state enum
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication provider for user login/signup functionality.
/// This is a scaffold implementation that can be extended with
/// actual authentication services (Firebase, Supabase, etc.)
class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  String? _userId;
  String? _userEmail;
  String? _error;

  // Email validation pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Getters
  AuthState get state => _state;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  /// Validate email format
  bool _isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

  /// Initialize auth provider - check for existing session
  Future<void> init() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('auth_user_id');
      final storedEmail = prefs.getString('auth_user_email');

      if (storedUserId != null && storedEmail != null) {
        _userId = storedUserId;
        _userEmail = storedEmail;
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
    }

    notifyListeners();
  }

  /// Sign in with email and password
  /// This is a scaffold that simulates authentication
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Basic validation
      if (email.isEmpty || !_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }
      if (password.isEmpty || password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Generate a unique user ID using UUID
      const uuid = Uuid();
      _userId = 'user_${uuid.v4()}';
      _userEmail = email;

      // Persist auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_id', _userId!);
      await prefs.setString('auth_user_email', _userEmail!);

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email and password
  /// This is a scaffold that simulates account creation
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Basic validation
      if (email.isEmpty || !_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }
      if (password.isEmpty || password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Generate a unique user ID using UUID
      const uuid = Uuid();
      _userId = 'user_${uuid.v4()}';
      _userEmail = email;

      // Persist auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_id', _userId!);
      await prefs.setString('auth_user_email', _userEmail!);
      if (displayName != null) {
        await prefs.setString('user_name', displayName);
      }

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_user_id');
      await prefs.remove('auth_user_email');
      await prefs.remove('user_name');

      _userId = null;
      _userEmail = null;
      _state = AuthState.unauthenticated;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
    }

    notifyListeners();
  }

  /// Clear any error state
  void clearError() {
    _error = null;
    if (_state == AuthState.error) {
      _state = _userId != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Skip authentication (continue as guest)
  Future<void> continueAsGuest() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      // Generate a guest user ID
      _userId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      _userEmail = null;

      // Persist guest state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_id', _userId!);

      _state = AuthState.authenticated;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
    }

    notifyListeners();
  }

  /// Send password reset email
  /// This is a scaffold that simulates sending a reset email
  Future<bool> forgotPassword({required String email}) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1200));

      // Basic validation
      if (email.isEmpty || !_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      // Scaffold: In a real app, this would send a password reset email
      // For now, we just simulate success
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google
  /// This is a scaffold for future Google Sign-In integration
  Future<bool> signInWithGoogle() async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Scaffold: In a real app, this would use google_sign_in package
      // For now, we simulate a successful sign in with a unique email
      const uuid = Uuid();
      final generatedUuid = uuid.v4();
      _userId = 'google_$generatedUuid';
      _userEmail = 'user_${generatedUuid.substring(0, 8)}@gmail.com';

      // Persist auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_id', _userId!);
      await prefs.setString('auth_user_email', _userEmail!);

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Apple
  /// This is a scaffold for future Apple Sign-In integration
  Future<bool> signInWithApple() async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Scaffold: In a real app, this would use sign_in_with_apple package
      // For now, we simulate a successful sign in with a unique email
      const uuid = Uuid();
      final generatedUuid = uuid.v4();
      _userId = 'apple_$generatedUuid';
      _userEmail = 'user_${generatedUuid.substring(0, 8)}@privaterelay.appleid.com';

      // Persist auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_id', _userId!);
      await prefs.setString('auth_user_email', _userEmail!);

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }
}
