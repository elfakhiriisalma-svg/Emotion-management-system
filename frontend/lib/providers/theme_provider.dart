import 'package:flutter/material.dart';

/// Simplified theme provider - light mode only
/// No dark mode support
class ThemeProvider with ChangeNotifier {
  // Always use light theme
  ThemeMode get themeMode => ThemeMode.light;
  bool get isDarkMode => false;
  bool get isLightMode => true;

  ThemeProvider() {
    // No initialization needed - always light
  }
}
