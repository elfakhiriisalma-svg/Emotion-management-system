/// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;

  /// Factory constructor for network errors
  factory ApiException.network(String message, [dynamic error]) {
    return ApiException(
      message: message,
      originalError: error,
    );
  }

  /// Factory constructor for HTTP errors
  factory ApiException.http(int statusCode, String message, [dynamic error]) {
    return ApiException(
      message: message,
      statusCode: statusCode,
      originalError: error,
    );
  }

  /// Factory constructor for timeout errors
  factory ApiException.timeout([dynamic error]) {
    return ApiException(
      message: 'Request timeout. Please check your connection and try again.',
      originalError: error,
    );
  }

  /// Factory constructor for unknown errors
  factory ApiException.unknown([dynamic error]) {
    return ApiException(
      message: 'An unexpected error occurred. Please try again.',
      originalError: error,
    );
  }

  /// Check if error is due to authentication
  bool get isUnauthorized => statusCode == 401;

  /// Check if error is due to forbidden access
  bool get isForbidden => statusCode == 403;

  /// Check if error is due to not found
  bool get isNotFound => statusCode == 404;

  /// Check if error is a server error
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Check if error is a client error
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
}

