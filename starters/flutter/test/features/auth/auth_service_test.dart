import 'package:app/core/auth/auth_provider.dart';
import 'package:app/core/auth/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  group('AuthState', () {
    test('initial state types are distinct', () {
      const initial = AuthInitial();
      const loading = AuthLoading();
      const authenticated = Authenticated(userId: 'user-123');
      const unauthenticated = Unauthenticated();
      const error = AuthError(message: 'Something failed');

      expect(initial, isA<AuthInitial>());
      expect(loading, isA<AuthLoading>());
      expect(authenticated, isA<Authenticated>());
      expect(unauthenticated, isA<Unauthenticated>());
      expect(error, isA<AuthError>());
    });

    test('Authenticated holds a userId', () {
      const state = Authenticated(userId: 'user-abc');

      expect(state.userId, equals('user-abc'));
    });

    test('AuthError holds a message', () {
      const state = AuthError(message: 'Invalid credentials');

      expect(state.message, equals('Invalid credentials'));
    });
  });

  group('AuthStateNotifier - login', () {
    test('transitions to AuthError on failure', () async {
      when(() => mockAuthService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),).thenThrow(Exception('Invalid credentials'));

      // Note: AuthStateNotifier now listens to Supabase onAuthStateChange.
      // In unit tests without Supabase initialised, we test the error path
      // by directly calling login on a notifier that catches exceptions.
      // Full integration testing requires a running Supabase instance.
      final notifier = AuthStateNotifier(
        authService: mockAuthService,
      );

      // Allow init to settle (will be Unauthenticated since no Supabase session)
      await Future<void>.delayed(Duration.zero);

      await notifier.login(email: 'test@example.com', password: 'wrong');

      expect(notifier.state, isA<AuthError>());
    });

    test('transitions to AuthError on register failure', () async {
      when(() => mockAuthService.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          ),).thenThrow(Exception('Email already taken'));

      final notifier = AuthStateNotifier(
        authService: mockAuthService,
      );
      await Future<void>.delayed(Duration.zero);

      await notifier.register(
        email: 'existing@example.com',
        password: 'password123',
        name: 'Test User',
      );

      expect(notifier.state, isA<AuthError>());
    });
  });
}
