import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/emotion_model.dart';
import '../config/app_theme.dart';
import 'modern_card.dart';

/// Minimalist weekly statistics widget
/// Clean line chart with soft colors and thin lines
class WeeklyStatisticsWidget extends StatelessWidget {
  final List<EmotionModel> emotions;

  const WeeklyStatisticsWidget({
    super.key,
    required this.emotions,
  });

  @override
  Widget build(BuildContext context) {
    if (emotions.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    // Get emotions from last 7 days
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weeklyEmotions = emotions
        .where((e) => e.timestamp.isAfter(weekAgo))
        .toList();

    if (weeklyEmotions.isEmpty) {
      return ModernCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 40,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No emotions this week',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Group by day
    final dailyCounts = <String, int>{};
    for (var emotion in weeklyEmotions) {
      final dayKey = DateFormat('EEE').format(emotion.timestamp);
      dailyCounts[dayKey] = (dailyCounts[dayKey] ?? 0) + 1;
    }

    // Create spots for line chart
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final spots = <FlSpot>[];
    for (int i = 0; i < days.length; i++) {
      final count = dailyCounts[days[i]] ?? 0;
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }

    final maxValue = dailyCounts.values.isEmpty
        ? 1
        : dailyCounts.values.reduce((a, b) => a > b ? a : b);

    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Minimalist
          Text(
            'Weekly Trend',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          
          // Chart - Clean Line
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
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
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
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
                minX: 0,
                maxX: (days.length - 1).toDouble(),
                minY: 0,
                maxY: maxValue.toDouble() + (maxValue > 0 ? 1 : 0),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryBlue,
                    barWidth: 2.5, // Thinner line
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryBlue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryBlue.withOpacity(0.08), // Very subtle gradient
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Stats - Clean Layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'This Week',
                weeklyEmotions.length.toString(),
                Icons.calendar_today_rounded,
              ),
              _buildStatItem(
                context,
                'Avg/Day',
                (weeklyEmotions.length / 7).toStringAsFixed(1),
                Icons.trending_up_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.textTertiary,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w400,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
