import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_storage.dart';
import 'api_exceptions.dart';

/// Attaches the JWT Bearer token to every request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.secureStorage});

  final SecureStorage secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Converts Dio errors into typed API exceptions.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;

    switch (statusCode) {
      case 401:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorisedException(),
            type: err.type,
            response: err.response,
          ),
        );
        return;
      case 403:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const ForbiddenException(),
            type: err.type,
            response: err.response,
          ),
        );
        return;
      case 404:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const NotFoundException(),
            type: err.type,
            response: err.response,
          ),
        );
        return;
      case 429:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const RateLimitedException(),
            type: err.type,
            response: err.response,
          ),
        );
        return;
      default:
        handler.next(err);
    }
  }
}

/// Logs requests and responses in debug mode.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('→ ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('✗ ${err.response?.statusCode ?? 'NETWORK'} ${err.requestOptions.uri}');
    }
    handler.next(err);
  }
}
