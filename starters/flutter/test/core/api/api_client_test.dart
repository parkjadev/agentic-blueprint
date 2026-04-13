import 'package:app/core/api/api_exceptions.dart';
import 'package:app/core/api/api_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponse', () {
    test('parses a successful response', () {
      final json = {
        'success': true,
        'data': {'id': '123', 'name': 'Test'},
      };

      final response = ApiResponse.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );

      expect(response.success, isTrue);
      expect(response.data, isNotNull);
      expect(response.data!['id'], equals('123'));
      expect(response.data!['name'], equals('Test'));
      expect(response.error, isNull);
    });

    test('parses an error response', () {
      final json = {
        'success': false,
        'error': {
          'message': 'Not found',
          'code': 'NOT_FOUND',
        },
      };

      final response = ApiResponse.fromJson(
        json,
        (data) => data,
      );

      expect(response.success, isFalse);
      expect(response.data, isNull);
      expect(response.error, isNotNull);
      expect(response.error!.message, equals('Not found'));
      expect(response.error!.code, equals('NOT_FOUND'));
    });
  });

  group('PaginatedResponse', () {
    test('parses a paginated response', () {
      final json = {
        'success': true,
        'data': {
          'data': [
            {'id': '1', 'name': 'First'},
            {'id': '2', 'name': 'Second'},
          ],
          'pagination': {
            'page': 1,
            'pageSize': 20,
            'total': 2,
            'totalPages': 1,
          },
        },
      };

      final response = PaginatedResponse<Map<String, dynamic>>.fromJson(
        json,
        (item) => item,
      );

      expect(response.success, isTrue);
      expect(response.data, isNotNull);
      expect(response.data!.length, equals(2));
      expect(response.pagination, isNotNull);
      expect(response.pagination!.page, equals(1));
      expect(response.pagination!.total, equals(2));
      expect(response.pagination!.hasNextPage, isFalse);
    });

    test('pagination knows when there are more pages', () {
      const pagination = Pagination(
        page: 1,
        pageSize: 20,
        total: 50,
        totalPages: 3,
      );

      expect(pagination.hasNextPage, isTrue);
      expect(pagination.hasPreviousPage, isFalse);
    });
  });

  group('ApiException', () {
    test('creates from a DioException with API error body', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {
            'success': false,
            'error': {
              'message': 'Validation failed',
              'code': 'VALIDATION_ERROR',
            },
          },
        ),
      );

      final exception = ApiException.fromDioException(dioError);

      expect(exception.message, equals('Validation failed'));
      expect(exception.statusCode, equals(400));
      expect(exception.code, equals('VALIDATION_ERROR'));
    });

    test('creates from a connection timeout', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final exception = ApiException.fromDioException(dioError);

      expect(exception.message, contains('timed out'));
    });

    test('creates from a connection error', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      final exception = ApiException.fromDioException(dioError);

      expect(exception.message, contains('internet connection'));
    });
  });

  group('ApiErrorBody', () {
    test('parses from JSON', () {
      final body = ApiErrorBody.fromJson({
        'message': 'Something went wrong',
        'code': 'INTERNAL_ERROR',
      });

      expect(body.message, equals('Something went wrong'));
      expect(body.code, equals('INTERNAL_ERROR'));
    });

    test('handles missing code', () {
      final body = ApiErrorBody.fromJson({
        'message': 'Error without code',
      });

      expect(body.message, equals('Error without code'));
      expect(body.code, isNull);
    });
  });
}
