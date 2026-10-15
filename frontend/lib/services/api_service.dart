import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'secure_storage_service.dart';

/// Centralized API service for handling all HTTP requests
/// - Automatically attaches JWT token
/// - Comprehensive error handling
/// - Request/response logging
class ApiService {
  static const String baseUrl = AppConfig.baseUrl;
  late Dio _dio;
  final SecureStorageService _secureStorage = SecureStorageService();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        // Don't throw exception for status codes
        return status! < 500;
      },
    ));

    // Add interceptors
    _setupInterceptors();
  }

  /// Setup request and response interceptors
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Automatically attach JWT token
        await _attachToken(options);
        
        // Log request (optional, for debugging)
        if (AppConfig.debugMode) {
          print('🚀 REQUEST: ${options.method} ${options.path}');
          print('Headers: ${options.headers}');
          if (options.data != null) {
            print('Data: ${options.data}');
          }
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response (optional, for debugging)
        if (AppConfig.debugMode) {
          print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          print('Data: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        // Log error (optional, for debugging)
        if (AppConfig.debugMode) {
          print('❌ ERROR: ${error.type} ${error.message}');
          if (error.response != null) {
            print('Status: ${error.response?.statusCode}');
            print('Data: ${error.response?.data}');
          }
        }
        
        // Handle 401 Unauthorized - clear token
        if (error.response?.statusCode == 401) {
          _clearToken();
        }
        
        return handler.next(error);
      },
    ));
  }

  /// Attach JWT token to request headers
  Future<void> _attachToken(RequestOptions options) async {
    try {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Silently fail if token cannot be retrieved
      if (AppConfig.debugMode) {
        print('Warning: Could not attach token: $e');
      }
    }
  }

  /// Clear stored token and user data
  Future<void> _clearToken() async {
    try {
      await _secureStorage.clearAll();
    } catch (e) {
      // Silently fail
      if (AppConfig.debugMode) {
        print('Warning: Could not clear token: $e');
      }
    }
  }

  /// Handle Dio errors and convert to ApiException
  ApiException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException.timeout(error);

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = _extractErrorMessage(error.response?.data) ??
              _getDefaultErrorMessage(statusCode);
          return ApiException.http(statusCode ?? 0, message, error);

        case DioExceptionType.cancel:
          return ApiException.network('Request was cancelled', error);

        case DioExceptionType.connectionError:
          return ApiException.network(
            'No internet connection. Please check your network and try again.',
            error,
          );

        case DioExceptionType.badCertificate:
          return ApiException.network('SSL certificate error', error);

        case DioExceptionType.unknown:
        default:
          if (error.message?.toString().contains('SocketException') == true ||
              error.message?.toString().contains('Failed host lookup') == true) {
            return ApiException.network(
              'No internet connection. Please check your network and try again.',
              error,
            );
          }
          return ApiException.unknown(error);
      }
    }
    return ApiException.unknown(error);
  }

  /// Extract error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    
    if (data is Map<String, dynamic>) {
      // Try common error message fields
      return data['message'] as String? ??
          data['error'] as String? ??
          data['Message'] as String? ??
          data['Error'] as String?;
    }
    
    if (data is String) {
      return data;
    }
    
    return null;
  }

  /// Get default error message based on status code
  String _getDefaultErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. This resource already exists.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // ==================== Generic HTTP Methods ====================

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = parser != null ? parser(response.data) : response.data as T;
        return ApiResponse.success(data, response.statusCode);
      } else {
        final error = _handleError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
        return ApiResponse.failure(error, response.statusCode);
      }
    } catch (e) {
      return ApiResponse.failure(_handleError(e));
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final responseData = parser != null ? parser(response.data) : response.data as T;
        return ApiResponse.success(responseData, response.statusCode);
      } else {
        final error = _handleError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
        return ApiResponse.failure(error, response.statusCode);
      }
    } catch (e) {
      return ApiResponse.failure(_handleError(e));
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final responseData = parser != null ? parser(response.data) : response.data as T;
        return ApiResponse.success(responseData, response.statusCode);
      } else {
        final error = _handleError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
        return ApiResponse.failure(error, response.statusCode);
      }
    } catch (e) {
      return ApiResponse.failure(_handleError(e));
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final responseData = parser != null ? parser(response.data) : response.data as T;
        return ApiResponse.success(responseData, response.statusCode);
      } else {
        final error = _handleError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
        return ApiResponse.failure(error, response.statusCode);
      }
    } catch (e) {
      return ApiResponse.failure(_handleError(e));
    }
  }

  // ==================== Auth Endpoints ====================

  Future<ApiResponse<Map<String, dynamic>>> register(
    String fullName,
    String email,
    String password, {
    String? role,
  }) async {
    return post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        if (role != null) 'role': role,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    return post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> validateToken() async {
    return get<Map<String, dynamic>>('/auth/validate');
  }

  // ==================== Emotion Endpoints ====================

  Future<ApiResponse<Map<String, dynamic>>> createEmotion(
    String emotionType,
    double confidence,
  ) async {
    return post<Map<String, dynamic>>(
      '/emotions',
      data: {
        'emotionType': emotionType,
        'confidence': confidence,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> detectEmotionFromImage(
    String imagePath,
  ) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });
    return post<Map<String, dynamic>>(
      '/emotions/detect',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> detectEmotionFromBase64(
    String base64Image,
  ) async {
    final bytes = base64Decode(base64Image);
    final multipartFile = MultipartFile.fromBytes(
      bytes,
      filename: 'face_image.jpg',
    );

    final formData = FormData.fromMap({
      'image': multipartFile,
    });

    return post<Map<String, dynamic>>(
      '/emotions/detect',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getEmotionById(int id) async {
    return get<Map<String, dynamic>>('/emotions/$id');
  }

  Future<ApiResponse<List<dynamic>>> getEmotionHistory(int employeeId) async {
    return get<List<dynamic>>('/emotions/employee/$employeeId');
  }

  // ==================== User Endpoints ====================

  Future<ApiResponse<Map<String, dynamic>>> getUserById(int id) async {
    return get<Map<String, dynamic>>('/users/$id');
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserByEmail(String email) async {
    return get<Map<String, dynamic>>('/users/email/$email');
  }

  Future<ApiResponse<List<dynamic>>> getEmployees() async {
    return get<List<dynamic>>('/users/employees');
  }

  // ==================== Alert Endpoints ====================

  Future<ApiResponse<List<dynamic>>> getAlertsByManagerId(int managerId) async {
    return get<List<dynamic>>('/alerts/manager/$managerId');
  }

  Future<ApiResponse<List<dynamic>>> getUnreadAlertsByManagerId(int managerId) async {
    return get<List<dynamic>>('/alerts/manager/$managerId/unread');
  }

  Future<ApiResponse<void>> markAlertAsRead(int alertId) async {
    return put<void>('/alerts/$alertId/read');
  }

  // User Profile endpoints
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    return get<Map<String, dynamic>>('/users/me');
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile(
    String fullName,
    String email, {
    int? age,
    String? gender,
  }) async {
    return put<Map<String, dynamic>>('/users/me', data: {
      'fullName': fullName,
      'email': email,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> changePassword(String currentPassword, String newPassword) async {
    return put<Map<String, dynamic>>('/users/me/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  // Emotion Statistics endpoints
  Future<ApiResponse<Map<String, dynamic>>> getEmployeeStatistics(int employeeId) async {
    return get<Map<String, dynamic>>('/emotions/employee/$employeeId/statistics');
  }

  // Employee Notes endpoints
  Future<ApiResponse<Map<String, dynamic>>> createEmployeeNote(int employeeId, String note) async {
    return post<Map<String, dynamic>>('/employee-notes/employee/$employeeId', data: {
      'note': note,
    });
  }

  Future<ApiResponse<List<dynamic>>> getEmployeeNotes(int employeeId) async {
    return get<List<dynamic>>('/employee-notes/employee/$employeeId');
  }

  Future<ApiResponse<List<dynamic>>> getManagerNotes(int managerId) async {
    return get<List<dynamic>>('/employee-notes/manager/$managerId');
  }

  Future<ApiResponse<Map<String, dynamic>>> updateEmployeeNote(int noteId, String note) async {
    return put<Map<String, dynamic>>('/employee-notes/$noteId', data: {
      'note': note,
    });
  }

  Future<ApiResponse<void>> deleteEmployeeNote(int noteId) async {
    return delete<void>('/employee-notes/$noteId');
  }

  // Employee Tags endpoints
  Future<ApiResponse<Map<String, dynamic>>> addEmployeeTag(int employeeId, String tag) async {
    return post<Map<String, dynamic>>('/employee-tags/employee/$employeeId', data: {
      'tag': tag,
    });
  }

  Future<ApiResponse<List<dynamic>>> getEmployeeTags(int employeeId) async {
    return get<List<dynamic>>('/employee-tags/employee/$employeeId');
  }

  Future<ApiResponse<void>> removeEmployeeTag(int employeeId, String tag) async {
    return delete<void>('/employee-tags/employee/$employeeId/tag/$tag');
  }

  Future<ApiResponse<void>> removeEmployeeTagById(int tagId) async {
    return delete<void>('/employee-tags/$tagId');
  }

  // Update Employee Info endpoint (for managers)
  // Note: Managers can only update name and email, not age and gender
  // Age and gender can only be modified by the employee themselves
  Future<ApiResponse<Map<String, dynamic>>> updateEmployeeInfo(
    int employeeId,
    String fullName,
    String email,
  ) async {
    return put<Map<String, dynamic>>('/users/employees/$employeeId', data: {
      'fullName': fullName,
      'email': email,
      // Age and gender are intentionally excluded - managers cannot modify these fields
    });
  }

  // ==================== Legacy Methods (for backward compatibility) ====================

  /// Legacy method - returns raw Dio Response
  /// Use the new ApiResponse methods instead
  @Deprecated('Use get() method instead')
  Future<Response> getLegacy(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  /// Legacy method - returns raw Dio Response
  /// Use the new ApiResponse methods instead
  @Deprecated('Use post() method instead')
  Future<Response> postLegacy(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }
}
