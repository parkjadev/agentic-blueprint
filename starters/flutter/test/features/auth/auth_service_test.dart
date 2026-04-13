import 'package:app/core/auth/auth_provider.dart';
import 'package:app/core/auth/auth_service.dart';
import 'package:app/core/storage/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockSecureStorage mockStorage;
  late MockAuthService mockAuthService;

  setUp(() {
    mockStorage = MockSecureStorage();
    mockAuthService = MockAuthService();
  });

  group('AuthState', () {
    test('initial state types are distinct', () {
      const initial = AuthInitial();
      const loading = AuthLoading();
      const authenticated = Authenticated(token: 'test-token');
      const unauthenticated = Unauthenticated();
      const error = AuthError(message: 'Something failed');

      expect(initial, isA<AuthInitial>());
      expect(loading, isA<AuthLoading>());
      expect(authenticated, isA<Authenticated>());
      expect(unauthenticated, isA<Unauthenticated>());
      expect(error, isA<AuthError>());
    });

    test('Authenticated holds a token', () {
      const state = Authenticated(token: 'my-jwt-token');

      expect(state.token, equals('my-jwt-token'));
    });

    test('AuthError holds a message', () {
      const state = AuthError(message: 'Invalid credentials');

      expect(state.message, equals('Invalid credentials'));
    });
  });

  group('AuthStateNotifier', () {
    test('starts with AuthInitial', () {
      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => null);

      final notifier = AuthStateNotifier(
        secureStorage: mockStorage,
        authService: mockAuthService,
      );

      // Immediately after creation, state is AuthInitial
      // (before the async _checkStoredToken completes)
      expect(notifier.state, isA<AuthInitial>());
    });

    test('transitions to Authenticated when token exists', () async {
      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => 'stored-token');

      final notifier = AuthStateNotifier(
        secureStorage: mockStorage,
        authService: mockAuthService,
      );

      // Wait for the async check to complete
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, isA<Authenticated>());
      expect((notifier.state as Authenticated).token, equals('stored-token'));
    });

    test('transitions to Unauthenticated when no token', () async {
      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => null);

      final notifier = AuthStateNotifier(
        secureStorage: mockStorage,
        authService: mockAuthService,
      );

      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, isA<Unauthenticated>());
    });

    test('login transitions through Loading to Authenticated', () async {
      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => null);
      when(() => mockAuthService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),).thenAnswer((_) async => 'new-token');

      final notifier = AuthStateNotifier(
        secureStorage: mockStorage,
        authService: mockAuthService,
      );

      await Future<void>.delayed(Duration.zero);
      expect(notifier.state, isA<Unauthenticated>());

      // Start login
      await notifier.login(email: 'test@example.com', password: 'password123');

      expect(notifier.state, isA<Authenticated>());
      expect(
        (notifier.state as Authenticated).token,
        equals('new-token'),
      );
    });

    test('login transitions to AuthError on failure', () async {
      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => null);
      when(() => mockAuthService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),).thenThrow(Exception('Invalid credentials'));

      final notifier = AuthStateNotifier(
        secureStorage: mockStorage,
        authService: mockAuthService,
      );

      await Future<void>.delayed(Duration.zero);

      await notifier.login(email: 'test@example.com', password: 'wrong');

      expect(notifier.state, isA<AuthError>());
    });

    test('logout clears state to Unauthenticated', () async {
      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => 'existing-token');
      when(() => mockAuthService.logout())
          .thenAnswer((_) async {});

      final notifier = AuthStateNotifier(
        secureStorage: mockStorage,
        authService: mockAuthService,
      );

      await Future<void>.delayed(Duration.zero);
      expect(notifier.state, isA<Authenticated>());

      await notifier.logout();

      expect(notifier.state, isA<Unauthenticated>());
      verify(() => mockAuthService.logout()).called(1);
    });
  });
}
