import 'package:flutter/material.dart';

/// Modern, minimalist light theme inspired by Calm, Apple Health, and Google Fit
/// No dark mode - light theme only
class AppTheme {
  // Soft Pastel Color Palette
  static const Color primaryBlue = Color(0xFF6B9BD2); // Soft blue
  static const Color primaryBlueLight = Color(0xFFE8F0F8); // Very light blue
  static const Color secondaryTeal = Color(0xFF7BC4C4); // Soft teal
  static const Color accentGreen = Color(0xFF9BC89B); // Soft green
  static const Color accentCoral = Color(0xFFE8A5A5); // Soft coral
  static const Color accentLavender = Color(0xFFC4A8E8); // Soft lavender
  
  // Neutral Colors
  static const Color backgroundWhite = Color(0xFFFAFAFA); // Off-white background
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Pure white surface
  static const Color textPrimary = Color(0xFF1A1A1A); // Almost black
  static const Color textSecondary = Color(0xFF6B6B6B); // Medium gray
  static const Color textTertiary = Color(0xFF9B9B9B); // Light gray
  static const Color dividerColor = Color(0xFFE5E5E5); // Very light gray
  
  // Emotion Colors (Soft Pastels)
  static const Color emotionHappy = Color(0xFF9BC89B); // Soft green
  static const Color emotionSad = Color(0xFF9BB4D4); // Soft blue
  static const Color emotionAngry = Color(0xFFE8A5A5); // Soft coral
  static const Color emotionFear = Color(0xFFE8C4A5); // Soft orange
  static const Color emotionSurprise = Color(0xFFE8D4A5); // Soft yellow
  static const Color emotionNeutral = Color(0xFFC4C4C4); // Soft gray
  
  // Status Colors
  static const Color successColor = Color(0xFF9BC89B);
  static const Color errorColor = Color(0xFFE8A5A5);
  static const Color warningColor = Color(0xFFE8C4A5);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        onPrimary: surfaceWhite,
        primaryContainer: primaryBlueLight,
        onPrimaryContainer: primaryBlue,
        secondary: secondaryTeal,
        onSecondary: surfaceWhite,
        surface: surfaceWhite,
        onSurface: textPrimary,
        surfaceContainerHighest: Color(0xFFF5F5F5),
        outline: dividerColor,
        outlineVariant: Color(0xFFF0F0F0),
      ),
      
      // Scaffold
      scaffoldBackgroundColor: backgroundWhite,
      
      // Typography - Clean and Modern
      textTheme: _buildTextTheme(),
      
      // AppBar - Minimalist
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surfaceWhite,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: textPrimary,
          size: 24,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      
      // Cards - Soft and Rounded
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: surfaceWhite,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      
      // Input Fields - Clean
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dividerColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      
      // Buttons - Soft and Rounded
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: primaryBlue,
          foregroundColor: surfaceWhite,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: primaryBlue,
          foregroundColor: surfaceWhite,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: dividerColor, width: 1),
          foregroundColor: textPrimary,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: primaryBlue,
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        shape: CircleBorder(),
        backgroundColor: primaryBlue,
        foregroundColor: surfaceWhite,
      ),
      
      // Navigation Bar - Clean
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: surfaceWhite,
        indicatorColor: primaryBlueLight,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: primaryBlue,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryBlue, size: 24);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
        height: 70,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5F5F5),
        selectedColor: primaryBlueLight,
        labelStyle: const TextStyle(color: textPrimary),
        secondaryLabelStyle: const TextStyle(color: primaryBlue),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
    );
  }
  
  // Clean Typography - Regular weights, good spacing
  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Display
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
        color: textPrimary,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
        color: textPrimary,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textPrimary,
        height: 1.3,
      ),
      
      // Headline
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
        color: textPrimary,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: textPrimary,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: textPrimary,
        height: 1.4,
      ),
      
      // Title
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: textPrimary,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: textPrimary,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textPrimary,
        height: 1.4,
      ),
      
      // Label
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textPrimary,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textSecondary,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textSecondary,
        height: 1.4,
      ),
      
      // Body
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textPrimary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: textSecondary,
        height: 1.5,
      ),
    );
  }
  
  // Emotion Colors Helper
  static Color getEmotionColor(String emotionType) {
    switch (emotionType.toUpperCase()) {
      case 'HAPPY':
        return emotionHappy;
      case 'SAD':
        return emotionSad;
      case 'ANGRY':
        return emotionAngry;
      case 'FEAR':
        return emotionFear;
      case 'SURPRISE':
        return emotionSurprise;
      case 'NEUTRAL':
        return emotionNeutral;
      default:
        return emotionNeutral;
    }
  }
  
  // Emotion Light Colors (for backgrounds)
  static Color getEmotionLightColor(String emotionType) {
    switch (emotionType.toUpperCase()) {
      case 'HAPPY':
        return const Color(0xFFF0F7F0);
      case 'SAD':
        return const Color(0xFFF0F4F8);
      case 'ANGRY':
        return const Color(0xFFF7F0F0);
      case 'FEAR':
        return const Color(0xFFF7F4F0);
      case 'SURPRISE':
        return const Color(0xFFF7F7F0);
      case 'NEUTRAL':
        return const Color(0xFFF5F5F5);
      default:
        return const Color(0xFFF5F5F5);
    }
  }
}
