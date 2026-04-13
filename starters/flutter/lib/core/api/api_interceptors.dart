import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_exceptions.dart';

/// Attaches the Supabase Auth access token to every API request.
/// The token is read directly from the Supabase session — no manual
/// storage management required.
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
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
