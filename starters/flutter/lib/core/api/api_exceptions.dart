import 'package:dio/dio.dart';

import 'api_response.dart';

/// Base exception for API errors.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Create from a Dio error response.
  factory ApiException.fromDioException(DioException error) {
    final response = error.response;

    if (response != null) {
      // Try to extract the API error envelope
      try {
        final json = response.data as Map<String, dynamic>;
        final apiError = ApiErrorBody.fromJson(
          json['error'] as Map<String, dynamic>,
        );
        return ApiException(
          message: apiError.message,
          statusCode: response.statusCode,
          code: apiError.code,
        );
      } catch (_) {
        // Response wasn't in our expected format
      }

      return ApiException(
        message: response.statusMessage ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }

    // No response — network or timeout error
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Request timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection. Please check your network.',
        );
      default:
        return ApiException(
          message: error.message ?? 'An unexpected error occurred',
        );
    }
  }
}

/// 401 — user needs to re-authenticate.
class UnauthorisedException extends ApiException {
  const UnauthorisedException({super.message = 'Session expired. Please sign in again.'})
      : super(statusCode: 401, code: 'UNAUTHENTICATED');
}

/// 403 — user lacks permission.
class ForbiddenException extends ApiException {
  const ForbiddenException({super.message = 'You do not have permission to do this.'})
      : super(statusCode: 403, code: 'FORBIDDEN');
}

/// 404 — resource not found.
class NotFoundException extends ApiException {
  const NotFoundException({super.message = 'Not found.'})
      : super(statusCode: 404, code: 'NOT_FOUND');
}

/// 429 — rate limited.
class RateLimitedException extends ApiException {
  const RateLimitedException({super.message = 'Too many requests. Please wait a moment.'})
      : super(statusCode: 429, code: 'RATE_LIMITED');
}
