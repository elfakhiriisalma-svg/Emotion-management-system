import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/emotion_model.dart';
import '../config/app_theme.dart';
import 'modern_card.dart';

/// Minimalist emotion statistics widget
/// Clean charts with soft colors and thin lines
class EmotionStatisticsWidget extends StatelessWidget {
  final List<EmotionModel> emotions;

  const EmotionStatisticsWidget({
    super.key,
    required this.emotions,
  });

  @override
  Widget build(BuildContext context) {
    if (emotions.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    // Calculate emotion frequency
    final emotionFrequency = <String, int>{};
    for (var emotion in emotions) {
      emotionFrequency[emotion.emotionType] =
          (emotionFrequency[emotion.emotionType] ?? 0) + 1;
    }

    // Find most frequent emotion
    final mostFrequent = emotionFrequency.entries.isNotEmpty
        ? emotionFrequency.entries
            .reduce((a, b) => a.value > b.value ? a : b)
        : null;

    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Minimalist
          Text(
            'Emotion Frequency',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          
          // Most Frequent - Soft Design
          if (mostFrequent != null)
            _buildMostFrequentEmotion(mostFrequent.key, mostFrequent.value, theme),
          
          if (mostFrequent != null) const SizedBox(height: 32),
          
          // Chart - Clean and Minimal
          _buildFrequencyChart(emotionFrequency, theme),
        ],
      ),
    );
  }

  Widget _buildMostFrequentEmotion(String emotionType, int count, ThemeData theme) {
    final color = AppTheme.getEmotionColor(emotionType);
    final lightColor = AppTheme.getEmotionLightColor(emotionType);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Icon - Soft Circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getEmotionIcon(emotionType),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Text - Clean
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Most Detected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  emotionType,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Count - Large and Soft
          Text(
            '$count',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyChart(Map<String, int> frequency, ThemeData theme) {
    final emotionTypes = ['HAPPY', 'SAD', 'ANGRY', 'FEAR', 'NEUTRAL'];
    final bars = <BarChartGroupData>[];

    for (int i = 0; i < emotionTypes.length; i++) {
      final type = emotionTypes[i];
      final count = frequency[type] ?? 0;
      final color = AppTheme.getEmotionColor(type);
      
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: color,
              width: 16, // Thinner bars
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ],
        ),
      );
    }

    final maxValue = frequency.values.isEmpty
        ? 1
        : frequency.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 180, // Smaller height
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue > 0 ? (maxValue / 4).ceil().toDouble() : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.dividerColor.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < emotionTypes.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        emotionTypes[value.toInt()],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() == value && value.toInt() >= 0) {
                    return Text(
                      value.toInt().toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: bars,
          maxY: maxValue.toDouble() + (maxValue > 0 ? 1 : 0),
          barTouchData: BarTouchData(
            enabled: false,
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
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }
}
