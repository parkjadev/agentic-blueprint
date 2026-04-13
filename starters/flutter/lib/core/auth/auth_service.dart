import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service — handles login, register, logout via Supabase Auth.
/// Token management (storage, refresh) is handled automatically by the
/// Supabase Flutter SDK.
class AuthService {
  AuthService();

  SupabaseClient get _client => Supabase.instance.client;

  /// Login with email and password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null) {
      throw const AuthException('Login failed — no session returned.');
    }
  }

  /// Register a new account.
  /// Returns true if a confirmation email was sent (user must verify before
  /// signing in), or false if the session was created immediately.
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    if (response.user == null) {
      throw const AuthException('Registration failed — no user returned.');
    }

    // If email confirmation is enabled, Supabase returns a user but no session.
    return response.session == null;
  }

  /// Logout — clears the Supabase session.
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// Get the current access token (for attaching to Next.js API calls).
  /// Returns null if not authenticated.
  String? get currentAccessToken {
    return _client.auth.currentSession?.accessToken;
  }
}
