import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/example/presentation/example_detail_screen.dart';
import '../../features/example/presentation/example_list_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../auth/auth_provider.dart';
import 'routes.dart';

/// GoRouter provider — watches auth state for reactive redirects.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState is Authenticated;
      final isAuthRoute = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.register;

      // Still loading — don't redirect
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      // Not authenticated and not on an auth route → go to login
      if (!isAuthenticated && !isAuthRoute) {
        return Routes.login;
      }

      // Authenticated but on an auth route → go to home
      if (isAuthenticated && isAuthRoute) {
        return Routes.home;
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main routes
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Example CRUD routes
      GoRoute(
        path: Routes.examples,
        builder: (context, state) => const ExampleListScreen(),
      ),
      GoRoute(
        path: '/examples/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ExampleDetailScreen(id: id);
        },
      ),
    ],
  );
});
