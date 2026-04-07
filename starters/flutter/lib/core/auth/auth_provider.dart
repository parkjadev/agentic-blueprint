import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage.dart';
import 'auth_service.dart';

/// Auth service provider.
final authServiceProvider = Provider<AuthService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthService(secureStorage: secureStorage);
});

/// Auth state — tracks whether the user is authenticated.
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(
    secureStorage: secureStorage,
    authService: authService,
  );
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
  const Authenticated({required this.token});
  final String token;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;
}

/// Auth state notifier — manages authentication lifecycle.
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier({
    required this.secureStorage,
    required this.authService,
  }) : super(const AuthInitial()) {
    _checkStoredToken();
  }

  final SecureStorage secureStorage;
  final AuthService authService;

  /// Check for a stored token on startup.
  Future<void> _checkStoredToken() async {
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      state = Authenticated(token: token);
    } else {
      state = const Unauthenticated();
    }
  }

  /// Login with email and password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final token = await authService.login(
        email: email,
        password: password,
      );
      state = Authenticated(token: token);
    } catch (e) {
      state = AuthError(message: e.toString());
    }
  }

  /// Register a new account.
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AuthLoading();
    try {
      final token = await authService.register(
        email: email,
        password: password,
        name: name,
      );
      state = Authenticated(token: token);
    } catch (e) {
      state = AuthError(message: e.toString());
    }
  }

  /// Logout.
  Future<void> logout() async {
    await authService.logout();
    state = const Unauthenticated();
  }
}
