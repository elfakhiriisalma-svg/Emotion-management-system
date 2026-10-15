import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

/// Secure storage service for sensitive data like JWT tokens
/// Uses flutter_secure_storage which encrypts data using platform-specific secure storage
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Store JWT token securely
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(
        key: AppConfig.tokenKey,
        value: token,
      );
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }

  /// Retrieve JWT token
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConfig.tokenKey);
    } catch (e) {
      throw Exception('Failed to read token: $e');
    }
  }

  /// Delete JWT token
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: AppConfig.tokenKey);
    } catch (e) {
      throw Exception('Failed to delete token: $e');
    }
  }

  /// Store user data securely (as JSON string)
  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      final userJson = jsonEncode(userData);
      await _storage.write(
        key: AppConfig.userKey,
        value: userJson,
      );
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Retrieve user data
  Future<Map<String, dynamic>?> getUser() async {
    try {
      final userJson = await _storage.read(key: AppConfig.userKey);
      if (userJson != null) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to read user data: $e');
    }
  }

  /// Delete user data
  Future<void> deleteUser() async {
    try {
      await _storage.delete(key: AppConfig.userKey);
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  /// Clear all stored data (token and user)
  Future<void> clearAll() async {
    try {
      await Future.wait([
        deleteToken(),
        deleteUser(),
      ]);
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if user data exists
  Future<bool> hasUser() async {
    try {
      final user = await getUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }
}

