/// Centralized route definitions for the application
class AppRoutes {
  // Root
  static const String splash = '/';
  
  // Authentication
  static const String login = '/login';
  static const String register = '/register';
  
  // Main
  static const String home = '/home';
  
  // Employee Screens
  static const String employeeDashboard = '/home/employee-dashboard';
  
  // Manager Screens
  static const String managerDashboard = '/home/manager-dashboard';
  
  // Emotion
  static const String preCaptureQuestionnaire = '/questionnaire/pre-capture';
  static const String emotionCapture = '/emotion/capture';
  static const String emotionHistory = '/emotion/history';
  
  // Home Tabs (internal navigation)
  static const String historyTab = '/home/history';
  static const String profileTab = '/home/profile';
  
  // Profile routes
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  
  // Employee detail route (for managers)
  static const String employeeDetail = '/employee/detail';
}
