import 'package:flutter/material.dart';
import '../models/emotion_model.dart';
import '../config/app_theme.dart';
import 'modern_card.dart';

/// Minimalist stress indicator widget
/// Clean design with soft colors
class StressIndicatorWidget extends StatelessWidget {
  final List<EmotionModel> emotions;

  const StressIndicatorWidget({
    super.key,
    required this.emotions,
  });

  @override
  Widget build(BuildContext context) {
    if (emotions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate stress level based on negative emotions (SAD, ANGRY, FEAR)
    final negativeEmotions = emotions.where((e) =>
        e.emotionType == 'SAD' ||
        e.emotionType == 'ANGRY' ||
        e.emotionType == 'FEAR').length;
    
    final stressLevel = (negativeEmotions / emotions.length * 100).round();
    
    Color stressColor;
    String stressLabel;
    
    if (stressLevel < 30) {
      stressColor = AppTheme.emotionHappy;
      stressLabel = 'Low';
    } else if (stressLevel < 50) {
      stressColor = AppTheme.emotionSurprise;
      stressLabel = 'Moderate';
    } else if (stressLevel < 70) {
      stressColor = AppTheme.emotionFear;
      stressLabel = 'High';
    } else {
      stressColor = AppTheme.emotionAngry;
      stressLabel = 'Very High';
    }

    final theme = Theme.of(context);
    final lightColor = stressColor.withOpacity(0.1);

    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Minimalist
          Text(
            'Stress Level',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          
          // Level Display - Clean
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stressLabel,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: stressColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$stressLevel%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Icon - Soft Circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: lightColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStressIcon(stressLevel),
                  color: stressColor,
                  size: 28,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress Bar - Thin and Clean
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stressLevel / 100,
              minHeight: 8,
              backgroundColor: AppTheme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(stressColor),
            ),
          ),
          
          // Recommendation - Only if high stress
          if (stressLevel >= 50) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: stressColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Consider taking a break or speaking with your manager',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: stressColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStressIcon(int level) {
    if (level < 30) {
      return Icons.sentiment_very_satisfied_rounded;
    } else if (level < 50) {
      return Icons.sentiment_neutral_rounded;
    } else if (level < 70) {
      return Icons.sentiment_dissatisfied_rounded;
    } else {
      return Icons.sentiment_very_dissatisfied_rounded;
    }
  }
}
