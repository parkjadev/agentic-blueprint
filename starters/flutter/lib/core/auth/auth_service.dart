import 'package:dio/dio.dart';

import '../../config/env.dart';
import '../../config/constants.dart';
import '../api/api_exceptions.dart';
import '../storage/secure_storage.dart';

/// Authentication service — handles login, register, logout, and token refresh.
/// Communicates with the Next.js mobile auth endpoints.
class AuthService {
  AuthService({required this.secureStorage});

  final SecureStorage secureStorage;

  final _dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.current.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  /// Login with email and password.
  /// Returns the access token on success.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/mobile/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data!;
      final token = data['data']?['token'] as String?;

      if (token == null) {
        throw const ApiException(message: 'Invalid login response');
      }

      await secureStorage.setAccessToken(token);

      // Store refresh token if provided
      final refreshToken = data['data']?['refreshToken'] as String?;
      if (refreshToken != null) {
        await secureStorage.setRefreshToken(refreshToken);
      }

      return token;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Register a new account.
  /// Returns the access token on success.
  Future<String> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/mobile/register',
        data: {'email': email, 'password': password, 'name': name},
      );

      final data = response.data!;
      final token = data['data']?['token'] as String?;

      if (token == null) {
        throw const ApiException(message: 'Invalid registration response');
      }

      await secureStorage.setAccessToken(token);
      return token;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Refresh the access token using the stored refresh token.
  Future<String?> refreshToken() async {
    final currentRefresh = await secureStorage.getRefreshToken();
    if (currentRefresh == null) return null;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/mobile/refresh',
        data: {'refreshToken': currentRefresh},
      );

      final data = response.data!;
      final newToken = data['data']?['token'] as String?;

      if (newToken != null) {
        await secureStorage.setAccessToken(newToken);

        final newRefresh = data['data']?['refreshToken'] as String?;
        if (newRefresh != null) {
          await secureStorage.setRefreshToken(newRefresh);
        }
      }

      return newToken;
    } on DioException {
      // Refresh failed — user needs to re-authenticate
      await secureStorage.clearTokens();
      return null;
    }
  }

  /// Logout — clear stored tokens.
  Future<void> logout() async {
    await secureStorage.clearTokens();
  }
}
