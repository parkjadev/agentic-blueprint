/// API response envelope matching the Next.js backend contract.
///
/// Success: { "success": true, "data": T }
/// Error:   { "success": false, "error": { "message": "...", "code": "..." } }
/// Paginated: { "success": true, "data": [...], "pagination": { ... } }
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.error,
  });

  final bool success;
  final T? data;
  final ApiErrorBody? error;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromData,
  ) {
    final success = json['success'] as bool;

    if (success) {
      return ApiResponse(
        success: true,
        data: fromData(json['data']),
      );
    }

    final errorJson = json['error'] as Map<String, dynamic>?;
    return ApiResponse(
      success: false,
      error: errorJson != null ? ApiErrorBody.fromJson(errorJson) : null,
    );
  }
}

/// Paginated API response matching the Next.js pagination envelope.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.success,
    this.data,
    this.pagination,
    this.error,
  });

  final bool success;
  final List<T>? data;
  final Pagination? pagination;
  final ApiErrorBody? error;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final success = json['success'] as bool;

    if (success) {
      final dataJson = json['data'] as Map<String, dynamic>;
      final items = (dataJson['data'] as List<dynamic>)
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList();
      final paginationJson =
          dataJson['pagination'] as Map<String, dynamic>;

      return PaginatedResponse(
        success: true,
        data: items,
        pagination: Pagination.fromJson(paginationJson),
      );
    }

    final errorJson = json['error'] as Map<String, dynamic>?;
    return PaginatedResponse(
      success: false,
      error: errorJson != null ? ApiErrorBody.fromJson(errorJson) : null,
    );
  }
}

class Pagination {
  const Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}

class ApiErrorBody {
  const ApiErrorBody({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  factory ApiErrorBody.fromJson(Map<String, dynamic> json) {
    return ApiErrorBody(
      message: json['message'] as String,
      code: json['code'] as String?,
    );
  }
}
