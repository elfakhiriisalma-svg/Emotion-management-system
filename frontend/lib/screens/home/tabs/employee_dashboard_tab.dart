import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/emotion_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/emotion_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/emotion_statistics_widget.dart';
import '../../../widgets/weekly_statistics_widget.dart';
import '../../../widgets/stress_indicator_widget.dart';
import '../../../widgets/tips_widget.dart';
import '../../../widgets/modern_card.dart';
import '../../../config/app_theme.dart';
import '../../../screens/camera/camera_screen.dart';
import '../../../services/navigation_service.dart';

/// Minimalist employee dashboard
/// Clean design with soft colors and breathing room
class EmployeeDashboardTab extends StatefulWidget {
  const EmployeeDashboardTab({super.key});

  @override
  State<EmployeeDashboardTab> createState() => _EmployeeDashboardTabState();
}

class _EmployeeDashboardTabState extends State<EmployeeDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentEmotion();
    });
  }

  Future<void> _loadCurrentEmotion() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final emotionProvider =
          Provider.of<EmotionProvider>(context, listen: false);
      await emotionProvider.loadEmotionHistory(authProvider.currentUser!.id);
    }
  }

  Future<void> _captureEmotionFromCamera() async {
    // Open pre-capture questionnaire first
    final result = await NavigationService.toPreCaptureQuestionnaire();
    // The questionnaire will navigate to camera screen after completion
    // Reload emotions when returning from camera
    if (result == true && mounted) {
      await _loadCurrentEmotion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _loadCurrentEmotion,
      color: AppTheme.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Section - Minimalist
            _buildWelcomeSection(theme),
            const SizedBox(height: 32),

            // Current Emotion Card
            Consumer<EmotionProvider>(
              builder: (context, emotionProvider, _) {
                if (emotionProvider.isLoading && emotionProvider.lastEmotion == null) {
                  return const LoadingWidget(message: 'Loading...');
                }

                if (emotionProvider.lastEmotion == null) {
                  return _buildNoEmotionCard(theme);
                }

                return _buildCurrentEmotionCard(
                  emotionProvider.lastEmotion!,
                  theme,
                );
              },
            ),
            const SizedBox(height: 24),

            // Action Button - Clean
            _buildActionButton(theme),
            const SizedBox(height: 32),

            // Statistics Widgets
            Consumer<EmotionProvider>(
              builder: (context, emotionProvider, _) {
                if (emotionProvider.emotions.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    EmotionStatisticsWidget(emotions: emotionProvider.emotions),
                    const SizedBox(height: 16),
                    WeeklyStatisticsWidget(emotions: emotionProvider.emotions),
                    const SizedBox(height: 16),
                    StressIndicatorWidget(emotions: emotionProvider.emotions),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            
            // Tips Widget
            const TipsWidget(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userName = authProvider.currentUser?.fullName ?? 'Employee';
        final firstName = userName.split(' ').first;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              firstName,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrentEmotionCard(EmotionModel emotion, ThemeData theme) {
    final emotionColor = AppTheme.getEmotionColor(emotion.emotionType);
    final lightColor = AppTheme.getEmotionLightColor(emotion.emotionType);
    final confidence = (emotion.confidence * 100).toStringAsFixed(0);

    return ModernCard(
      padding: const EdgeInsets.all(32),
      backgroundColor: lightColor,
      child: Column(
        children: [
          // Icon - Large and Soft
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: emotionColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getEmotionIcon(emotion.emotionType),
              size: 48,
              color: emotionColor,
            ),
          ),
          const SizedBox(height: 24),

          // Emotion Type - Clean
          Text(
            emotion.emotionType,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: emotionColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),

          // Confidence - Minimalist Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: emotionColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$confidence% confidence',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: emotionColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Timestamp - Subtle
          Text(
            _formatDateTime(emotion.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEmotionCard(ThemeData theme) {
    return ModernCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sentiment_neutral_rounded,
              size: 36,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No emotion detected yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Capture your first emotion to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    return Consumer<EmotionProvider>(
      builder: (context, emotionProvider, _) {
        return FilledButton.icon(
          onPressed: emotionProvider.isLoading ? null : _captureEmotionFromCamera,
          icon: const Icon(Icons.camera_alt_rounded, size: 20),
          label: const Text('Capture New Emotion'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  IconData _getEmotionIcon(String emotionType) {
    switch (emotionType) {
      case 'HAPPY':
        return Icons.sentiment_very_satisfied_rounded;
      case 'SAD':
        return Icons.sentiment_very_dissatisfied_rounded;
      case 'ANGRY':
        return Icons.sentiment_very_dissatisfied_rounded;
      case 'FEAR':
        return Icons.sentiment_dissatisfied_rounded;
      case 'SURPRISE':
        return Icons.sentiment_satisfied_rounded;
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }
}
