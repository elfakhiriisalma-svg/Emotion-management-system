import 'package:flutter/material.dart';
import '../config/app_routes.dart';

/// Centralized navigation service for the application
/// Provides helper methods for navigation throughout the app
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current context
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate to a named route
  static Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  /// Navigate to a named route and replace current route
  static Future<dynamic>? navigateToReplacement(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Navigate to a named route and remove all previous routes
  static Future<dynamic>? navigateToAndRemoveUntil(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate back
  static void goBack([dynamic result]) {
    navigatorKey.currentState?.pop(result);
  }

  /// Navigate back until a specific route
  static void goBackUntil(String routeName) {
    navigatorKey.currentState?.popUntil((route) => route.settings.name == routeName);
  }

  /// Check if can go back
  static bool canGoBack() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  // ==================== Specific Navigation Methods ====================

  /// Navigate to Login Screen
  static Future<dynamic>? toLogin({bool replace = false}) {
    if (replace) {
      return navigateToAndRemoveUntil(AppRoutes.login);
    }
    return navigateToReplacement(AppRoutes.login);
  }

  /// Navigate to Register Screen
  static Future<dynamic>? toRegister() {
    return navigateTo(AppRoutes.register);
  }

  /// Navigate to Home Screen
  static Future<dynamic>? toHome({bool replace = false}) {
    if (replace) {
      return navigateToAndRemoveUntil(AppRoutes.home);
    }
    return navigateToReplacement(AppRoutes.home);
  }

  /// Navigate to Employee Dashboard
  static Future<dynamic>? toEmployeeDashboard({bool replace = false}) {
    if (replace) {
      return navigateToAndRemoveUntil(AppRoutes.employeeDashboard);
    }
    return navigateTo(AppRoutes.employeeDashboard);
  }

  /// Navigate to Manager Dashboard
  static Future<dynamic>? toManagerDashboard({bool replace = false}) {
    if (replace) {
      return navigateToAndRemoveUntil(AppRoutes.managerDashboard);
    }
    return navigateTo(AppRoutes.managerDashboard);
  }

  /// Navigate to Pre-Capture Questionnaire Screen
  static Future<dynamic>? toPreCaptureQuestionnaire() {
    return navigateTo(AppRoutes.preCaptureQuestionnaire);
  }

  /// Navigate to Emotion Capture Screen
  static Future<dynamic>? toEmotionCapture() {
    return navigateTo(AppRoutes.emotionCapture);
  }

  /// Navigate to Emotion History Screen
  static Future<dynamic>? toEmotionHistory() {
    return navigateTo(AppRoutes.emotionHistory);
  }

  /// Navigate to History Tab (within HomeScreen)
  static void toHistoryTab() {
    // This is handled by HomeScreen's tab navigation
    // Could emit an event or use a callback
  }

  /// Navigate to Profile Tab (within HomeScreen)
  static void toProfileTab() {
    // This is handled by HomeScreen's tab navigation
    // Could emit an event or use a callback
  }

  /// Logout and navigate to Login
  static Future<dynamic>? logout() {
    return navigateToAndRemoveUntil(AppRoutes.login);
  }
}

