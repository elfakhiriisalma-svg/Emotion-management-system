import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/emotion_model.dart';
import '../config/app_theme.dart';

/// Minimalist emotion card widget
/// Clean design with soft colors and rounded corners
class EmotionCard extends StatelessWidget {
  final EmotionModel emotion;
  final VoidCallback? onTap;

  const EmotionCard({
    super.key,
    required this.emotion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emotionColor = AppTheme.getEmotionColor(emotion.emotionType);
    final lightColor = AppTheme.getEmotionLightColor(emotion.emotionType);
    final confidence = (emotion.confidence * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon - Soft Circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: lightColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getEmotionIcon(emotion.emotionType),
                    color: emotionColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content - Clean
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emotion.emotionType,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(emotion.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Confidence - Minimalist Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$confidence%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: emotionColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
