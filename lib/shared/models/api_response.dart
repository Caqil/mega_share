
import 'base_model.dart';
import 'pagination_model.dart';

/// Generic API response wrapper
class ApiResponse<T> extends BaseModel {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
    this.meta,
  });

  /// Create success response
  factory ApiResponse.success({
    required T data,
    String? message,
    int? statusCode,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
      meta: meta,
    );
  }

  /// Create error response
  factory ApiResponse.error({
    required String error,
    String? message,
    int? statusCode,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      success: false,
      error: error,
      message: message,
      statusCode: statusCode,
      meta: meta,
    );
  }

  /// Create from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      error: json['error'],
      statusCode: json['statusCode'],
      meta: json['meta'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'error': error,
      'statusCode': statusCode,
      'meta': meta,
    };
  }

  /// Check if response has data
  bool get hasData => data != null;

  /// Check if response is successful
  bool get isSuccessful => success && error == null;

  /// Get error message
  String get errorMessage => error ?? message ?? 'Unknown error';

  @override
  List<Object?> get props => [success, data, message, error, statusCode, meta];
}

/// Paginated API response
class PaginatedResponse<T> extends ApiResponse<List<T>> {
  final PaginationMeta pagination;

  const PaginatedResponse({
    required super.success,
    required super.data,
    required this.pagination,
    super.message,
    super.error,
    super.statusCode,
    super.meta,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items = json['data'] as List?;
    final data = items?.map((item) => fromJsonT(item)).toList();

    return PaginatedResponse<T>(
      success: json['success'] ?? false,
      data: data,
      pagination: PaginationMeta.fromJson(json['pagination'] ?? {}),
      message: json['message'],
      error: json['error'],
      statusCode: json['statusCode'],
      meta: json['meta'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['pagination'] = pagination.toJson();
    return json;
  }

  /// Check if there are more pages
  bool get hasNextPage => pagination.hasNextPage;

  /// Check if there are previous pages
  bool get hasPreviousPage => pagination.hasPreviousPage;

  /// Get total items count
  int get totalItems => pagination.totalItems;

  /// Get current page number
  int get currentPage => pagination.currentPage;

  @override
  List<Object?> get props => [...super.props, pagination];
}
