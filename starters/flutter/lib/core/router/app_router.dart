import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
        // TODO: Replace with LoginScreen from features/auth/
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Register'),
        // TODO: Replace with RegisterScreen from features/auth/
      ),

      // Main routes
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
        // TODO: Replace with HomeScreen from features/home/
      ),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Profile'),
        // TODO: Replace with ProfileScreen from features/profile/
      ),

      // Example CRUD routes
      GoRoute(
        path: Routes.examples,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Examples'),
        // TODO: Replace with ExampleListScreen from features/example/
      ),
      GoRoute(
        path: '/examples/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _PlaceholderScreen(title: 'Example $id');
          // TODO: Replace with ExampleDetailScreen
        },
      ),
    ],
  );
});

/// Placeholder screen — replace with actual feature screens.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title screen — replace with your implementation',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
