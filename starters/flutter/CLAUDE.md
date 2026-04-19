# CLAUDE.md — Flutter starter

Starter-specific guidance. The framework-wide principles (Hard Rules
1–9) live in the parent repo; read those first:

- Parent primitive map — [`/CLAUDE.md`](../../CLAUDE.md)
- Hard Rules — [`/docs/principles/`](../../docs/principles/)

This file captures what's specific to **this starter**.

## Stack

| Layer | Technology | Notes |
|---|---|---|
| Framework | Flutter 3.27+, Dart 3.6+ | Material 3 |
| State | Riverpod 2.x | `flutter_riverpod` + `hooks_riverpod` |
| Navigation | GoRouter 14.x | Declarative, with auth guards |
| HTTP | Dio 5.x | Auth, error, logging interceptors |
| Auth | `supabase_flutter` | Unified web + mobile auth |
| Serialisation | `freezed` + `json_serializable` | Immutable models, codegen |
| Testing | `flutter_test` + `mocktail` | Unit and widget tests |
| Linting | `flutter_lints` strict | strict-casts, strict-inference, strict-raw-types |

## Project structure

```
lib/
├── main.dart                      # entry, ProviderScope
├── app.dart                       # MaterialApp.router, theme, GoRouter
├── config/                        # env, theme, constants
├── core/
│   ├── api/                       # api_client, api_response (ApiResponse<T>), interceptors, exceptions
│   ├── auth/                      # auth_provider, auth_service
│   ├── router/                    # app_router (auth redirects), routes (path constants)
│   └── storage/                   # supabase_provider
├── features/
│   ├── auth/                      # login + register screens
│   ├── home/
│   ├── profile/
│   └── example/                   # reference CRUD — list, detail, model, repo, providers
└── shared/
    ├── models/                    # User (matches Next.js AuthUser)
    ├── widgets/                   # scaffold, loading, error, forms
    └── extensions/                # BuildContext helpers
```

## Starter-specific conventions

These complement the parent Hard Rules; they're Flutter-only concerns.

1. **No `print()`.** Use `debugPrint()` for dev-only logging. `analysis_options.yaml` enforces `avoid_print`.
2. **Every API call returns `ApiResponse<T>`.** Matches the Next.js `{ success, data }` / `{ success, error }` envelope. Never return `response.data` from Dio directly.
3. **Riverpod owns all non-local state.** `setState()` is allowed only for pure UI concerns (form fields, animation controllers). Business state, async data, and auth state go through providers.
4. **Navigation via GoRouter only.** Never call `Navigator.push()` directly. Routes defined in `core/router/routes.dart`. Use `context.go()` for replacement, `context.push()` for stack.
5. **Typed exceptions.** Never `catch (Exception)`. Use `ApiException` and subclasses (`UnauthorisedException`, `ForbiddenException`, `RateLimitedException`, …). Handle each in the UI.
6. **Feature-based folders.** Each feature has `presentation/`, `data/`, and optionally `providers/`. Shared code → `shared/`. Core infra → `core/`.
7. **`const` everywhere possible.** `prefer_const_constructors` is enforced.
8. **Trailing commas required.** `require_trailing_commas` is enforced — keeps diffs clean and formatting stable.
9. **Models mirror the API contract.** `fromJson`/`toJson` match the Next.js API field names exactly. Never rename across the boundary.

## Auth flow (supabase_flutter)

- `supabase.auth.signInWithPassword(...)` → session (access + refresh tokens) → persisted by the SDK.
- `onAuthStateChange` → `AuthState` becomes `Authenticated(userId)` → GoRouter redirects to home.
- Authenticated API calls: `AuthInterceptor` reads the token from
  `Supabase.instance.client.auth.currentSession` and attaches
  `Authorization: Bearer <accessToken>`.
- Next.js backend validates via `supabase.auth.getUser()` and resolves
  the internal user via `get-auth.ts`.
- Token refresh: automatic via SDK.
- Logout: `supabase.auth.signOut()` → `AuthState` → `Unauthenticated` → redirect to login.

## Clean-boot contract (Hard Rule 3)

The starter must pass both commands with zero errors:

```bash
flutter analyze
flutter test
```

Use `/check` (see `.claude/commands/check.md`) to run both in sequence.

## Environment switching

```bash
flutter run                                        # dev (default)
flutter run --dart-define=ENV=staging              # staging
flutter run --dart-define=ENV=production           # prod
```

URLs are resolved in `lib/config/env.dart` — update staging / production
before deploying.

## Common tasks

| Task | Do this |
|---|---|
| Add a freezed model | Edit `*.dart`, then run `/generate` (delegates to `dart run build_runner build`) |
| Add an API method | Extend the relevant repository; add a typed exception if it's a new failure mode |
| Add a screen | Create under `features/<name>/presentation/`, register route in `core/router/routes.dart` |
| Update lint rules | Edit `analysis_options.yaml` (do not touch without review) |

## Do NOT touch without review

| File | Why |
|---|---|
| `lib/core/api/api_response.dart` | Defines the API contract. Changing this breaks every repository. |
| `lib/core/auth/auth_provider.dart` | Auth state machine. Breaking this breaks the entire app. |
| `lib/core/router/app_router.dart` | Auth guards and redirects. Wrong logic here silently locks users out. |
| `lib/core/api/api_interceptors.dart` | Token injection and error mapping. Affects every API call. |
| `pubspec.yaml` | Dependency versions. Conflicts break the build. |
| `analysis_options.yaml` | Lint rules. Changing these changes enforcement. |

## Data models

```
User (shared/models/user.dart)
  id: String
  email: String
  name: String?
  role: String       // 'admin' | 'user'
  status: String     // 'active' | 'suspended' | 'deleted'

ExampleProject (features/example/data/example_model.dart)
  id: String
  name: String
  description: String?
  ownerId: String?
  status: String     // 'active' | 'archived' | 'deleted'
  createdAt: DateTime
  updatedAt: DateTime
```

Both shapes match the Next.js API response exactly — if one side
changes, the other changes in the same PR.
