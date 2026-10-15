import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../config/app_routes.dart';
import '../../../models/user_model.dart';
import '../../../providers/employee_provider.dart';
import '../../../providers/alert_provider.dart';
import '../../../providers/emotion_provider.dart';
import '../../../models/user_model.dart';
import '../../../models/emotion_model.dart';
import '../../../models/alert_model.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/emotion_chart.dart';
import '../../../widgets/employee_search_bar.dart';
import '../../../widgets/employee_filters_widget.dart';
import '../../../widgets/modern_card.dart';
import '../../../widgets/animated_fade_in.dart';
import '../../../providers/employee_note_provider.dart';
import '../../../models/employee_note_model.dart';

class ManagerDashboardTab extends StatefulWidget {
  const ManagerDashboardTab({super.key});

  @override
  State<ManagerDashboardTab> createState() => _ManagerDashboardTabState();
}

class _ManagerDashboardTabState extends State<ManagerDashboardTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  FilterPeriod _selectedFilter = FilterPeriod.all;
  String? _sortBy = 'recent';
  List<UserModel> _filteredEmployees = [];
  String _searchQuery = '';

  // Flags pour éviter les chargements multiples
  bool _isLoading = false;
  bool _hasInitialized = false;
  Timer? _searchDebounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized && mounted) {
        _hasInitialized = true;
        _loadData();
        _startRealTimePolling();
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _stopRealTimePolling();
    super.dispose();
  }

  void _startRealTimePolling() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null &&
        authProvider.currentUser!.isManager) {
      final alertProvider = Provider.of<AlertProvider>(context, listen: false);
      alertProvider.startRealTimePolling(authProvider.currentUser!.id);
    }
  }

  void _stopRealTimePolling() {
    final alertProvider = Provider.of<AlertProvider>(context, listen: false);
    alertProvider.stopPolling();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
        });
        _applyFilters();
      }
    });
  }

  void _applyFilters() {
    final employeeProvider =
        Provider.of<EmployeeProvider>(context, listen: false);
    List<UserModel> filtered = List.from(employeeProvider.employees);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((employee) {
        return employee.fullName.toLowerCase().contains(_searchQuery) ||
            employee.email.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply date filter
    final now = DateTime.now();
    switch (_selectedFilter) {
      case FilterPeriod.today:
        filtered = filtered.where((employee) {
          final latestEmotion =
              employeeProvider.getLatestEmotionForEmployee(employee.id);
          if (latestEmotion == null) return false;
          return latestEmotion.timestamp.day == now.day &&
              latestEmotion.timestamp.month == now.month &&
              latestEmotion.timestamp.year == now.year;
        }).toList();
        break;
      case FilterPeriod.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        filtered = filtered.where((employee) {
          final latestEmotion =
              employeeProvider.getLatestEmotionForEmployee(employee.id);
          if (latestEmotion == null) return false;
          return latestEmotion.timestamp.isAfter(weekAgo);
        }).toList();
        break;
      case FilterPeriod.month:
        final monthAgo = now.subtract(const Duration(days: 30));
        filtered = filtered.where((employee) {
          final latestEmotion =
              employeeProvider.getLatestEmotionForEmployee(employee.id);
          if (latestEmotion == null) return false;
          return latestEmotion.timestamp.isAfter(monthAgo);
        }).toList();
        break;
      case FilterPeriod.all:
        break;
    }

    // Apply sorting
    switch (_sortBy) {
      case 'recent':
        filtered.sort((a, b) {
          final emotionA = employeeProvider.getLatestEmotionForEmployee(a.id);
          final emotionB = employeeProvider.getLatestEmotionForEmployee(b.id);
          if (emotionA == null && emotionB == null) return 0;
          if (emotionA == null) return 1;
          if (emotionB == null) return -1;
          return emotionB.timestamp.compareTo(emotionA.timestamp);
        });
        break;
      case 'critical':
        filtered.sort((a, b) {
          final emotionA = employeeProvider.getLatestEmotionForEmployee(a.id);
          final emotionB = employeeProvider.getLatestEmotionForEmployee(b.id);
          if (emotionA == null && emotionB == null) return 0;
          if (emotionA == null) return 1;
          if (emotionB == null) return -1;

          // Critical emotions: SAD, ANGRY, FEAR
          final criticalA = emotionA.emotionType == 'SAD' ||
              emotionA.emotionType == 'ANGRY' ||
              emotionA.emotionType == 'FEAR';
          final criticalB = emotionB.emotionType == 'SAD' ||
              emotionB.emotionType == 'ANGRY' ||
              emotionB.emotionType == 'FEAR';

          if (criticalA && !criticalB) return -1;
          if (!criticalA && criticalB) return 1;
          return emotionB.timestamp.compareTo(emotionA.timestamp);
        });
        break;
      case 'name':
        filtered.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'date':
        filtered.sort((a, b) {
          final dateA = a.createdAt ?? DateTime(1970);
          final dateB = b.createdAt ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });
        break;
    }

    setState(() {
      _filteredEmployees = filtered;
    });
  }

  Future<void> _loadData() async {
    if (_isLoading) return; // Éviter les chargements simultanés

    _isLoading = true;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final managerId = authProvider.currentUser!.id;

      final employeeProvider =
          Provider.of<EmployeeProvider>(context, listen: false);
      final alertProvider = Provider.of<AlertProvider>(context, listen: false);

      try {
        await Future.wait([
          employeeProvider.loadEmployees(),
          alertProvider.loadAlertsByManagerId(managerId),
          alertProvider.loadUnreadAlertsByManagerId(managerId),
        ]);

        if (mounted) {
          _applyFilters();

          // Ensure real-time polling is active
          if (!alertProvider.isPolling) {
            alertProvider.startRealTimePolling(managerId);
          }
        }
      } finally {
        if (mounted) {
          _isLoading = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Nécessaire avec AutomaticKeepAliveClientMixin

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Section
            _buildWelcomeSection(colorScheme),
            const SizedBox(height: 20),

            // Alerts Section
            Consumer<AlertProvider>(
              builder: (context, alertProvider, _) {
                return _buildAlertsSection(alertProvider, colorScheme, theme);
              },
            ),
            const SizedBox(height: 20),

            // Statistics Overview
            Consumer<EmployeeProvider>(
              builder: (context, employeeProvider, _) {
                return _buildStatisticsOverview(
                    employeeProvider, colorScheme, theme);
              },
            ),
            const SizedBox(height: 20),

            // Search and Filters
            _buildSearchAndFilters(colorScheme),
            const SizedBox(height: 20),

            // Employees List
            _buildEmployeesSection(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userName = authProvider.currentUser?.fullName ?? 'Manager';
        return ModernCard(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer.withOpacity(0.6),
                  colorScheme.secondaryContainer.withOpacity(0.4),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    size: 36,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, Manager ${userName.split(' ').first}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Monitor your employees\' emotional well-being',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertsSection(
      AlertProvider alertProvider, ColorScheme colorScheme, ThemeData theme) {
    if (alertProvider.isLoading && alertProvider.unreadAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text(
                      'Alerts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (alertProvider.unreadCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${alertProvider.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (alertProvider.unreadAlerts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No new alerts',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...alertProvider.unreadAlerts.take(3).map((alert) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildAlertCard(alert, colorScheme, theme),
                );
              }).toList(),
            if (alertProvider.unreadAlerts.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to full alerts screen
                  },
                  child: const Text('View all alerts'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(
      AlertModel alert, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.errorContainer.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_rounded,
            color: colorScheme.onErrorContainer,
            size: 22,
          ),
        ),
        title: Text(
          alert.employeeName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              alert.message,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('MMM dd, yyyy HH:mm').format(alert.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () async {
            final alertProvider =
                Provider.of<AlertProvider>(context, listen: false);
            await alertProvider.markAlertAsRead(alert.id);
          },
        ),
      ),
    );
  }

  Widget _buildStatisticsOverview(EmployeeProvider employeeProvider,
      ColorScheme colorScheme, ThemeData theme) {
    final totalEmployees = employeeProvider.employees.length;
    final employeesWithEmotions =
        employeeProvider.employeeLatestEmotions.keys.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Employees',
                    totalEmployees.toString(),
                    Icons.people,
                    colorScheme.primary,
                    theme,
                    colorScheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    employeesWithEmotions.toString(),
                    Icons.favorite,
                    Colors.green,
                    theme,
                    colorScheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color,
      ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmployeeSearchBar(
          controller: _searchController,
          onChanged: (_) => _applyFilters(),
          onClear: _applyFilters,
        ),
        const SizedBox(height: 12),
        EmployeeFiltersWidget(
          selectedFilter: _selectedFilter,
          onFilterChanged: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
            _applyFilters();
          },
          sortBy: _sortBy,
          onSortChanged: (sort) {
            setState(() {
              _sortBy = sort;
            });
            _applyFilters();
          },
        ),
      ],
    );
  }

  Widget _buildEmployeesSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Employees',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Consumer<EmployeeProvider>(
              builder: (context, employeeProvider, _) {
                return Text(
                  '${_filteredEmployees.length} ${_filteredEmployees.length == 1 ? 'employee' : 'employees'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<EmployeeProvider>(
          builder: (context, employeeProvider, _) {
            if (employeeProvider.isLoading) {
              return const LoadingWidget(message: 'Loading employees...');
            }

            if (_filteredEmployees.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.people_outline,
                title: 'No employees found',
                message: _searchQuery.isNotEmpty
                    ? 'Try adjusting your search or filters'
                    : 'Employees will appear here once they register',
              );
            }

            return Column(
              children: _filteredEmployees.map((employee) {
                return AnimatedFadeIn(
                  child: _buildEmployeeCard(
                      employee, employeeProvider, colorScheme),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(
    UserModel employee,
    EmployeeProvider employeeProvider,
    ColorScheme colorScheme,
  ) {
    final latestEmotion =
        employeeProvider.getLatestEmotionForEmployee(employee.id);
    final isCritical = latestEmotion != null &&
        (latestEmotion.emotionType == 'SAD' ||
            latestEmotion.emotionType == 'ANGRY' ||
            latestEmotion.emotionType == 'FEAR');

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.employeeDetail,
          arguments: employee,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Text(
                  employee.fullName.isNotEmpty
                      ? employee.fullName[0].toUpperCase()
                      : 'P',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isCritical)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning,
                                    size: 14, color: Colors.red),
                                const SizedBox(width: 4),
                                Text(
                                  'Critical',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (latestEmotion != null) _buildEmotionBadge(latestEmotion),
            ],
          ),
          if (latestEmotion != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getEmotionColor(latestEmotion.emotionType)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getEmotionIcon(latestEmotion.emotionType),
                    color: _getEmotionColor(latestEmotion.emotionType),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latest: ${latestEmotion.emotionType}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getEmotionColor(latestEmotion.emotionType),
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy HH:mm')
                              .format(latestEmotion.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(latestEmotion.confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getEmotionColor(latestEmotion.emotionType),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'No emotions recorded yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Notes preview - Utiliser Selector pour éviter les rebuilds
          const SizedBox(height: 12),
          Selector<EmployeeNoteProvider, int>(
            selector: (_, provider) {
              return provider.notes
                  .where((n) => n.employeeId == employee.id)
                  .length;
            },
            builder: (context, notesCount, _) {
              if (notesCount > 0) {
                return Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$notesCount ${notesCount == 1 ? 'note' : 'notes'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionBadge(EmotionModel emotion) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getEmotionColor(emotion.emotionType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getEmotionIcon(emotion.emotionType),
            size: 16,
            color: _getEmotionColor(emotion.emotionType),
          ),
          const SizedBox(width: 4),
          Text(
            emotion.emotionType,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getEmotionColor(emotion.emotionType),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEmotionIcon(String emotionType) {
    switch (emotionType) {
      case 'HAPPY':
        return Icons.sentiment_very_satisfied;
      case 'SAD':
        return Icons.sentiment_very_dissatisfied;
      case 'ANGRY':
        return Icons.sentiment_very_dissatisfied;
      case 'FEAR':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _getEmotionColor(String emotionType) {
    switch (emotionType) {
      case 'HAPPY':
        return Colors.green;
      case 'SAD':
        return Colors.blue;
      case 'ANGRY':
        return Colors.red;
      case 'FEAR':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
