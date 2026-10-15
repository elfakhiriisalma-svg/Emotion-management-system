import 'package:flutter/material.dart';
import 'dart:math';
import '../config/app_theme.dart';
import 'modern_card.dart';

/// Minimalist tips widget
/// Clean design without gradients
class TipsWidget extends StatelessWidget {
  const TipsWidget({super.key});

  static final List<String> _tips = [
    'Take deep breaths when feeling stressed. Inhale for 4 counts, hold for 4, exhale for 4.',
    'Regular exercise can help improve your mood and reduce stress levels.',
    'Getting 7-9 hours of sleep each night is essential for emotional well-being.',
    'Practice mindfulness meditation for 10 minutes daily to improve emotional awareness.',
    'Stay connected with friends and family - social support is important for mental health.',
    'Keep a gratitude journal. Write down 3 things you\'re grateful for each day.',
    'Limit screen time before bed to improve sleep quality.',
    'Spend time in nature - even 20 minutes can boost your mood.',
    'Listen to calming music when feeling anxious or stressed.',
    'Practice self-compassion - be kind to yourself, especially during difficult times.',
  ];

  @override
  Widget build(BuildContext context) {
    final tip = _getTipForToday();
    final theme = Theme.of(context);
    final lightColor = AppTheme.primaryBlueLight;

    return ModernCard(
      padding: const EdgeInsets.all(24),
      backgroundColor: lightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Minimalist
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tip of the Day',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Tip Text - Clean
          Text(
            tip,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getTipForToday() {
    // Use day of year to get consistent tip for the day
    final dayOfYear = DateTime.now().difference(
      DateTime(DateTime.now().year, 1, 1),
    ).inDays;
    
    return _tips[dayOfYear % _tips.length];
  }
}
