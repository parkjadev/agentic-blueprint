import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/routes.dart';
import 'auth_provider.dart';

/// GoRouter redirect guard — redirects unauthenticated users to login.
///
/// Usage in GoRouter config:
/// ```dart
/// GoRouter(
///   redirect: authGuard(ref),
///   ...
/// )
/// ```
String? Function(BuildContext, GoRouterState) authGuard(Ref ref) {
  return (BuildContext context, GoRouterState state) {
    final authState = ref.read(authStateProvider);
    final isAuthenticated = authState is Authenticated;
    final isAuthRoute = state.matchedLocation == Routes.login ||
        state.matchedLocation == Routes.register;

    // Not authenticated and trying to access a protected route
    if (!isAuthenticated && !isAuthRoute) {
      return Routes.login;
    }

    // Authenticated but trying to access an auth route
    if (isAuthenticated && isAuthRoute) {
      return Routes.home;
    }

    // No redirect needed
    return null;
  };
}

/// Placeholder for GoRouterState — the actual type comes from go_router.
/// This is used to avoid importing go_router in this file since the
/// actual redirect function signature uses go_router's GoRouterState.
typedef GoRouterState = dynamic;
