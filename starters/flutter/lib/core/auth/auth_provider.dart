import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

/// Auth service provider.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth state — tracks whether the user is authenticated.
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService: authService);
});

/// Whether the user is currently authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider) is Authenticated;
});

/// Auth state — sealed class pattern.
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  const Authenticated({required this.userId});
  final String userId;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;
}

/// Auth state notifier — listens to Supabase auth state changes.
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier({
    required this.authService,
  }) : super(const AuthInitial()) {
    _init();
  }

  final AuthService authService;
  StreamSubscription<AuthState>? _authSubscription;

  void _init() {
    final SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      // Supabase not initialised (e.g. in unit tests) — default to unauthenticated.
      state = const Unauthenticated();
      return;
    }

    // Check current session
    final session = client.auth.currentSession;
    if (session != null) {
      state = Authenticated(userId: session.user.id);
    } else {
      state = const Unauthenticated();
    }

    // Listen for auth state changes (sign-in, sign-out, token refresh)
    _authSubscription = client.auth.onAuthStateChange
        .map((data) {
          final session = data.session;
          if (session != null) {
            return Authenticated(userId: session.user.id) as AuthState;
          }
          return const Unauthenticated();
        })
        .listen((authState) {
          state = authState;
        });
  }

  /// Login with email and password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      await authService.login(email: email, password: password);
      // State will be updated by the onAuthStateChange listener
    } catch (e) {
      state = AuthError(message: e.toString());
    }
  }

  /// Register a new account.
  /// Returns true if email confirmation is required (user must check email).
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AuthLoading();
    try {
      final confirmationRequired = await authService.register(
        email: email,
        password: password,
        name: name,
      );
      if (confirmationRequired) {
        state = const Unauthenticated();
      }
      // Otherwise, state will be updated by the onAuthStateChange listener
      return confirmationRequired;
    } catch (e) {
      state = AuthError(message: e.toString());
      return false;
    }
  }

  /// Logout.
  Future<void> logout() async {
    await authService.logout();
    // State will be updated by the onAuthStateChange listener
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
