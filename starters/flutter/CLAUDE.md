# CLAUDE.md — Flutter Starter

This file provides guidance to Claude Code when working with the Flutter mobile companion.

## Stack

| Layer | Technology | Notes |
|---|---|---|
| Framework | Flutter 3.27+ | Material 3, Dart 3.6+ |
| State Management | Riverpod 2.x | flutter_riverpod + hooks_riverpod |
| Navigation | GoRouter 14.x | Declarative routing with auth guards |
| HTTP | Dio 5.x | Interceptors for auth, errors, logging |
| Auth | JWT (Bearer token) | Matches Next.js `signMobileJwt` / `verifyMobileJwt` |
| Storage | flutter_secure_storage | Encrypted token storage on device |
| Serialisation | freezed + json_serializable | Immutable models with code generation |
| Testing | flutter_test + mocktail | Unit and widget tests |
| Linting | flutter_lints | Strict: strict-casts, strict-inference, strict-raw-types |

## Project Structure

```
lib/
├── main.dart                      # Entry point, ProviderScope
├── app.dart                       # MaterialApp.router, theme, GoRouter
├── config/
│   ├── env.dart                   # API base URL per environment
│   ├── theme.dart                 # Material 3 theme (light + dark)
│   └── constants.dart             # App-wide constants, timeouts, keys
├── core/
│   ├── api/
│   │   ├── api_client.dart        # Dio HTTP client, Riverpod provider
│   │   ├── api_response.dart      # ApiResponse<T> matching Next.js envelope
│   │   ├── api_exceptions.dart    # Typed exceptions (401, 403, 404, 429)
│   │   └── api_interceptors.dart  # Auth token, error mapping, logging
│   ├── auth/
│   │   ├── auth_provider.dart     # AuthState notifier, isAuthenticated
│   │   ├── auth_service.dart      # Login, register, logout, refresh
│   │   └── auth_guard.dart        # GoRouter redirect guard
│   ├── router/
│   │   ├── app_router.dart        # GoRouter config with auth redirects
│   │   └── routes.dart            # Route path constants
│   └── storage/
│       └── secure_storage.dart    # JWT token storage wrapper
├── features/
│   ├── auth/                      # Login + register screens
│   ├── home/                      # Home screen
│   ├── profile/                   # Profile screen + repository
│   └── example/                   # Example CRUD (list, detail, model, repo, providers)
└── shared/
    ├── models/user.dart           # User model matching Next.js AuthUser
    ├── widgets/                   # Reusable widgets (scaffold, loading, error, forms)
    └── extensions/                # BuildContext extensions
```

## Hard Rules

1. **No `print()` statements** — use `debugPrint()` for debug logging only in development. `analysis_options.yaml` enforces `avoid_print`.

2. **All API responses use `ApiResponse<T>`** — every API call must return the typed envelope matching the Next.js `{ success, data }` / `{ success, error }` contract. Never access `response.data` directly from Dio.

3. **Riverpod for all state management** — no `setState()` for anything beyond local widget state (e.g., form fields). Business state, async data, and auth state all go through Riverpod providers.

4. **GoRouter for all navigation** — never use `Navigator.push()` directly. All routes are defined in `routes.dart` and configured in `app_router.dart`. Use `context.go()` for replacement navigation, `context.push()` for stack navigation.

5. **Typed exceptions** — never catch generic `Exception`. Use `ApiException` and its subclasses (`UnauthorisedException`, `ForbiddenException`, etc.). Handle each case explicitly in the UI.

6. **Feature-based folder structure** — each feature has `presentation/`, `data/`, and optionally `providers/` directories. Shared code lives in `shared/`. Core infrastructure lives in `core/`.

7. **Const constructors everywhere** — use `const` for widgets, values, and constructors wherever possible. The linter enforces `prefer_const_constructors`.

8. **Require trailing commas** — enforced by `require_trailing_commas` lint rule. This keeps diffs clean and formatting consistent.

9. **Models match the API contract** — `fromJson()` and `toJson()` methods must match the exact field names from the Next.js API. Don't rename fields between backend and frontend.

10. **Australian spelling** — favour, colour, organisation in all comments and string literals.

## Auth Flow

The app uses JWT authentication against the Next.js mobile auth endpoints:

```
Login / Register
  → POST /api/auth/mobile/login (or /register)
    → Backend verifies credentials, calls signMobileJwt()
      → Returns { token, refreshToken }
        → Store in flutter_secure_storage
          → AuthState becomes Authenticated(token)
            → GoRouter redirects to home

Authenticated API calls
  → AuthInterceptor reads token from secure storage
    → Attaches Authorization: Bearer <token> header
      → Backend verifyMobileJwt() validates token
        → Resolves to internal user via get-auth.ts

Token refresh
  → POST /api/auth/mobile/refresh
    → Old refresh token → new access + refresh tokens
      → Update secure storage

Logout
  → Clear tokens from secure storage
    → AuthState becomes Unauthenticated
      → GoRouter redirects to login
```

## Environment Configuration

Switch environments via `--dart-define`:

```bash
# Development (default)
flutter run

# Staging
flutter run --dart-define=ENV=staging

# Production
flutter run --dart-define=ENV=production
```

Environment URLs are configured in `lib/config/env.dart`. Update the staging and production URLs before deploying.

## Testing

**Commands:**

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run a specific test file
flutter test test/core/api/api_client_test.dart

# Run the analyser (lint check)
flutter analyze

# Full check (analyse + test)
flutter analyze && flutter test
```

**Conventions:**

- Test files mirror the source structure: `lib/core/api/` → `test/core/api/`
- Use `mocktail` for mocking — no `mockito` (mocktail has better null safety support)
- Unit test repositories and services against mock API responses
- Widget test screens with `ProviderScope.overrides` for dependency injection
- Name test files `*_test.dart`

## Key Patterns

### Riverpod Provider + Repository

```dart
// Provider
final exampleRepositoryProvider = Provider<ExampleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ExampleRepository(apiClient: apiClient);
});

// Async data provider
final exampleListProvider = FutureProvider.autoDispose.family<
    PaginatedResponse<ExampleProject>, int>((ref, page) {
  final repository = ref.watch(exampleRepositoryProvider);
  return repository.list(page: page);
});
```

### Screen with Async State

```dart
class ExampleScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(exampleListProvider(1));

    return dataAsync.when(
      loading: () => const LoadingIndicator(),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(exampleListProvider(1)),
      ),
      data: (response) => ListView(...),
    );
  }
}
```

### API Client Call

```dart
final response = await apiClient.get<User>(
  '/auth/me',
  fromData: (data) => User.fromJson(data as Map<String, dynamic>),
);

if (!response.success || response.data == null) {
  throw Exception(response.error?.message ?? 'Failed to get user');
}

return response.data!;
```

### GoRouter Auth Redirect

```dart
redirect: (context, state) {
  final isAuthenticated = authState is Authenticated;
  final isAuthRoute = state.matchedLocation == Routes.login;

  if (!isAuthenticated && !isAuthRoute) return Routes.login;
  if (isAuthenticated && isAuthRoute) return Routes.home;
  return null;
},
```

## Do NOT Touch Without Review

| File | Why |
|---|---|
| `lib/core/api/api_response.dart` | Defines the API contract. Changing this breaks all repositories. |
| `lib/core/auth/auth_provider.dart` | Auth state machine. Breaking this breaks the entire app. |
| `lib/core/router/app_router.dart` | Route config with auth guards. Wrong redirects = broken navigation. |
| `lib/core/api/api_interceptors.dart` | Token injection and error mapping. Affects every API call. |
| `pubspec.yaml` | Dependencies. Version conflicts can break the build. |
| `analysis_options.yaml` | Lint rules. Changing these affects code quality enforcement. |

## Data Models

```
User (shared/models/user.dart)
├── id (String)
├── email (String)
├── name (String?)
├── role (String) — 'admin' | 'user'
└── status (String) — 'active' | 'suspended' | 'deleted'

ExampleProject (features/example/data/example_model.dart)
├── id (String)
├── name (String)
├── description (String?)
├── ownerId (String?)
├── status (String) — 'active' | 'archived' | 'deleted'
├── createdAt (DateTime)
└── updatedAt (DateTime)
```

Both models match the Next.js API response shapes exactly.
