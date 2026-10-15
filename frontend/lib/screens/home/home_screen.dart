import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/emotion_provider.dart';
import '../../services/navigation_service.dart';
import 'tabs/employee_dashboard_tab.dart';
import 'tabs/manager_dashboard_tab.dart';
import 'tabs/emotions_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  final int? initialTab;
  
  const HomeScreen({super.key, this.initialTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  List<Widget>? _cachedTabs; // Cache des tabs pour éviter les recréations
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab ?? 0;
  }

  void switchToHistoryTab() {
    setState(() {
      _currentIndex = 1;
    });
  }

  List<Widget> _getTabs() {
    // Retourner les tabs en cache si disponibles
    if (_cachedTabs != null) {
      return _cachedTabs!;
    }
    
    // Check if user is employee or manager
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isEmployee = authProvider.currentUser?.role == 'EMPLOYEE';

    _cachedTabs = isEmployee
        ? [
            const EmployeeDashboardTab(),
            const HistoryTab(),
            const ProfileTab(),
          ]
        : [
            const ManagerDashboardTab(),
            const HistoryTab(),
            const ProfileTab(),
          ];
    
    return _cachedTabs!;
  }
  
  // Invalider le cache si nécessaire (par exemple, après logout/login)
  void _invalidateTabsCache() {
    _cachedTabs = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return Text(
              'Emotion Monitoring',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                NavigationService.logout();
              }
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: _getTabs(),
        ),
      ),
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final isEmployee = authProvider.currentUser?.role == 'EMPLOYEE';
          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: Icon(isEmployee ? Icons.dashboard_outlined : Icons.medical_services_outlined),
                selectedIcon: Icon(isEmployee ? Icons.dashboard_rounded : Icons.medical_services_rounded),
                label: 'Dashboard',
              ),
              const NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history_rounded),
                label: 'History',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}

