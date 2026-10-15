import 'api_exception.dart';

/// Wrapper class for API responses with error handling
class ApiResponse<T> {
  final T? data;
  final ApiException? error;
  final int? statusCode;
  final bool isSuccess;

  ApiResponse({
    this.data,
    this.error,
    this.statusCode,
    required this.isSuccess,
  });

  /// Create a successful response
  factory ApiResponse.success(T data, [int? statusCode]) {
    return ApiResponse<T>(
      data: data,
      statusCode: statusCode,
      isSuccess: true,
    );
  }

  /// Create an error response
  factory ApiResponse.failure(ApiException error, [int? statusCode]) {
    return ApiResponse<T>(
      error: error,
      statusCode: statusCode,
      isSuccess: false,
    );
  }

  /// Get data or throw error
  T getDataOrThrow() {
    if (isSuccess && data != null) {
      return data!;
    }
    throw error ?? ApiException.unknown();
  }

  /// Get data or return null
  T? getDataOrNull() => isSuccess ? data : null;

  /// Get error message
  String get errorMessage => error?.message ?? 'Unknown error occurred';
}

