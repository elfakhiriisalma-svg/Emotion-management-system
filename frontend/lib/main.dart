import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/emotion_provider.dart';
import 'providers/alert_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/employee_note_provider.dart';
import 'providers/emotion_statistics_provider.dart';
import 'providers/employee_tag_provider.dart';
import 'providers/pre_capture_provider.dart';
import 'services/navigation_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/questionnaire/pre_capture_questionnaire_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/camera/camera_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/employee/employee_detail_screen.dart';
import 'models/user_model.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmotionProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeNoteProvider()),
        ChangeNotifierProvider(create: (_) => EmotionStatisticsProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeTagProvider()),
        ChangeNotifierProvider(create: (_) => PreCaptureProvider()),
      ],
      child: MaterialApp(
        title: 'Emotion Monitoring',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // No dark theme - light mode only
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: AppRoutes.splash,
        routes: _buildRoutes(),
        onGenerateRoute: _generateRoute,
        // Smooth page transitions
        themeAnimationDuration: const Duration(milliseconds: 300),
        themeAnimationCurve: Curves.easeInOut,
      ),
    );
  }

  /// Build all named routes
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      AppRoutes.splash: (context) => const SplashScreen(),
      AppRoutes.login: (context) => const LoginScreen(),
      AppRoutes.register: (context) => const RegisterScreen(),
      AppRoutes.home: (context) => const HomeScreen(),
      AppRoutes.preCaptureQuestionnaire: (context) => const PreCaptureQuestionnaireScreen(),
      AppRoutes.emotionCapture: (context) => const CameraScreen(),
      AppRoutes.editProfile: (context) => const EditProfileScreen(),
      AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
    };
  }

  /// Generate routes dynamically (for routes with arguments)
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.employeeDashboard:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              const HomeScreen(initialTab: 0),
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      case AppRoutes.managerDashboard:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              const HomeScreen(initialTab: 0),
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      case AppRoutes.emotionHistory:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              const HomeScreen(initialTab: 1),
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      case AppRoutes.employeeDetail:
        final employee = settings.arguments as UserModel;
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              EmployeeDetailScreen(employee: employee),
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
      default:
        return null;
    }
  }
}
