import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/env.dart';
import '../storage/secure_storage.dart';
import 'api_exceptions.dart';
import 'api_interceptors.dart';
import 'api_response.dart';

/// Riverpod provider for the API client.
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage: secureStorage);
});

/// HTTP client for the Next.js API backend.
/// Uses Dio with auth, error, and logging interceptors.
class ApiClient {
  ApiClient({required SecureStorage secureStorage}) {
    _dio = Dio(
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

    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage: secureStorage),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  late final Dio _dio;

  /// GET request returning a typed ApiResponse.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromData,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data!, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// GET request returning a paginated response.
  Future<PaginatedResponse<T>> getList<T>(
    String path, {
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromItem,
  }) async {
    try {
      final params = {
        'page': page,
        'pageSize': pageSize,
        ...?queryParameters,
      };
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: params,
      );
      return PaginatedResponse.fromJson(response.data!, fromItem);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST request returning a typed ApiResponse.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) fromData,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
      );
      return ApiResponse.fromJson(response.data!, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// PUT request returning a typed ApiResponse.
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) fromData,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: data,
      );
      return ApiResponse.fromJson(response.data!, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// DELETE request — expects 204 No Content.
  Future<void> delete(String path) async {
    try {
      await _dio.delete<void>(path);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
