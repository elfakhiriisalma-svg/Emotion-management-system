import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/api_exception.dart';
import '../services/api_response.dart';
import '../services/secure_storage_service.dart';
import '../config/app_config.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SecureStorageService _secureStorage = SecureStorageService();
  
  bool _isLoading = false;
  bool _isInitializing = true; // Track initialization state
  String? _errorMessage;
  UserModel? _currentUser;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _currentUser != null;

  AuthProvider() {
    _initialize();
  }

  /// Initialize and load stored authentication
  Future<void> _initialize() async {
    _isInitializing = true;
    notifyListeners();
    
    try {
      await _loadStoredAuth();
    } catch (e) {
      // Silently handle initialization errors
      if (AppConfig.debugMode) {
        print('Error initializing auth: $e');
      }
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Load stored authentication from secure storage
  Future<void> _loadStoredAuth() async {
    try {
      final token = await _secureStorage.getToken();
      final userData = await _secureStorage.getUser();

      if (token != null && token.isNotEmpty && userData != null) {
        _token = token;
        _currentUser = UserModel.fromJson(
          Map<String, dynamic>.from(userData),
        );
        notifyListeners();
      }
    } catch (e) {
      // Silently handle errors during load
      if (AppConfig.debugMode) {
        print('Error loading stored auth: $e');
      }
    }
  }

  /// Validate token with backend
  Future<bool> validateToken() async {
    if (_token == null) {
      return false;
    }

    try {
      final response = await _apiService.validateToken();
      
      if (response.isSuccess) {
        return true;
      } else {
        // Token is invalid, clear stored auth
        if (response.error?.isUnauthorized == true) {
          await logout();
        }
        return false;
      }
    } catch (e) {
      // Network error or other issues
      // Don't clear token on network errors, might be temporary
      return false;
    }
  }

  /// Auto-login: Check stored token and validate it
  Future<bool> autoLogin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First, try to load stored auth
      await _loadStoredAuth();

      if (!isAuthenticated) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate token with backend
      final isValid = await validateToken();

      if (isValid) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Token is invalid, clear auth
        await logout();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Auto-login failed. Please login again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password, {String? role}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(fullName, email, password, role: role);
      
      if (response.isSuccess && response.data != null) {
        final authResponse = AuthResponseModel.fromJson(response.data!);
        await _saveAuth(authResponse);
        return true;
      } else {
        _errorMessage = _extractErrorMessage(response) ?? 'Registration failed';
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString().contains('Email already exists')
          ? 'Email already exists'
          : 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      
      if (response.isSuccess && response.data != null) {
        final authResponse = AuthResponseModel.fromJson(response.data!);
        await _saveAuth(authResponse);
        return true;
      } else {
        _errorMessage = _extractErrorMessage(response) ?? 'Invalid email or password';
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Invalid email or password';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save authentication data securely
  Future<void> _saveAuth(AuthResponseModel authResponse) async {
    try {
      // Save token securely
      await _secureStorage.saveToken(authResponse.token);
      
      // Update in-memory state
      _token = authResponse.token;
      _currentUser = UserModel(
        id: authResponse.id,
        fullName: authResponse.fullName,
        email: authResponse.email,
        role: authResponse.role,
      );
      
      // Save user data securely
      await _secureStorage.saveUser(_currentUser!.toJson());
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to save authentication: $e');
    }
  }

  /// Logout and clear all stored data
  Future<void> logout() async {
    try {
      // Clear secure storage
      await _secureStorage.clearAll();
      
      // Clear in-memory state
      _token = null;
      _currentUser = null;
      _errorMessage = null;
      
      notifyListeners();
    } catch (e) {
      // Even if clearing fails, clear in-memory state
      _token = null;
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile(
    String fullName,
    String email, {
    int? age,
    String? gender,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiResponse = await _apiService.updateProfile(
        fullName,
        email,
        age: age,
        gender: gender,
      );
      
      if (apiResponse.isSuccess && apiResponse.data != null) {
        // Update current user with new data
        final userData = apiResponse.data as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(userData);
        
        // Save updated user data
        await _secureStorage.saveUser(_currentUser!.toJson());
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = apiResponse.errorMessage ?? 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update profile. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiResponse = await _apiService.changePassword(currentPassword, newPassword);
      
      if (apiResponse.isSuccess) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = apiResponse.errorMessage ?? 'Failed to change password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to change password. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Extract error message from API response
  String? _extractErrorMessage(ApiResponse response) {
    if (response.error != null) {
      return response.error!.message;
    }
    return null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
