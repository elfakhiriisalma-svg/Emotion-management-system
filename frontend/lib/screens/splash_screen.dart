import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/navigation_service.dart';
import '../config/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app and check authentication
  Future<void> _initializeApp() async {
    // Wait for auth provider to initialize
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Wait until initialization is complete
    while (authProvider.isInitializing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Small delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Try auto-login if token exists
    final isAuthenticated = await authProvider.autoLogin();

    if (!mounted) return;

    // Navigate based on authentication status
    if (isAuthenticated) {
      NavigationService.toHome(replace: true);
    } else {
      NavigationService.toLogin(replace: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite,
                size: 80,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            
            // App Name
            Text(
              'Emotion Monitoring',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Monitor your emotional well-being',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading Indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 24),
            
            // Loading Text
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.isInitializing) {
                  return Text(
                    'Initializing...',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  );
                } else if (authProvider.isLoading) {
                  return Text(
                    'Checking authentication...',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
