import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/emotion_model.dart';

class EmotionChart extends StatelessWidget {
  final List<EmotionModel> emotions;
  final ChartType chartType;

  const EmotionChart({
    super.key,
    required this.emotions,
    this.chartType = ChartType.line,
  });

  @override
  Widget build(BuildContext context) {
    if (emotions.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (chartType) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.pie:
        return _buildPieChart();
    }
  }

  Widget _buildLineChart() {
    // Group emotions by date and calculate average confidence per day
    final Map<String, List<EmotionModel>> groupedByDate = {};
    
    for (var emotion in emotions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(emotion.timestamp);
      groupedByDate.putIfAbsent(dateKey, () => []).add(emotion);
    }

    // Sort by date
    final sortedDates = groupedByDate.keys.toList()..sort();
    
    // Create spots for the line chart
    final spots = <FlSpot>[];
    final bottomTitles = <String>[];
    
    for (int i = 0; i < sortedDates.length; i++) {
      final dateKey = sortedDates[i];
      final dayEmotions = groupedByDate[dateKey]!;
      
      // Calculate average confidence for the day
      final avgConfidence = dayEmotions
          .map((e) => e.confidence)
          .reduce((a, b) => a + b) / dayEmotions.length;
      
      spots.add(FlSpot(i.toDouble(), avgConfidence * 100));
      
      // Format date for display
      final date = DateTime.parse(dateKey);
      bottomTitles.add(DateFormat('MM/dd').format(date));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emotion Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < bottomTitles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                bottomTitles[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
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
                        reservedSize: 40,
                        interval: 25,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.blue,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    // Count emotions by type
    final Map<String, int> emotionCounts = {};
    
    for (var emotion in emotions) {
      emotionCounts[emotion.emotionType] = 
          (emotionCounts[emotion.emotionType] ?? 0) + 1;
    }

    final emotionTypes = ['HAPPY', 'SAD', 'ANGRY', 'FEAR', 'NEUTRAL'];
    final bars = <BarChartGroupData>[];
    final bottomTitles = <String>[];

    for (int i = 0; i < emotionTypes.length; i++) {
      final type = emotionTypes[i];
      final count = emotionCounts[type] ?? 0;
      
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: _getEmotionColor(type),
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
      
      bottomTitles.add(type);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emotion Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < bottomTitles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                bottomTitles[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
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
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() == value) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  barGroups: bars,
                  maxY: emotionCounts.values.isEmpty 
                      ? 1 
                      : emotionCounts.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    // Count emotions by type
    final Map<String, int> emotionCounts = {};
    
    for (var emotion in emotions) {
      emotionCounts[emotion.emotionType] = 
          (emotionCounts[emotion.emotionType] ?? 0) + 1;
    }

    if (emotionCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = emotionCounts.values.reduce((a, b) => a + b);
    final pieSections = <PieChartSectionData>[];
    final emotionTypes = ['HAPPY', 'SAD', 'ANGRY', 'FEAR', 'NEUTRAL'];

    int index = 0;
    for (var type in emotionTypes) {
      final count = emotionCounts[type] ?? 0;
      if (count > 0) {
        final percentage = (count / total) * 100;
        pieSections.add(
          PieChartSectionData(
            value: count.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            color: _getEmotionColor(type),
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
      index++;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emotion Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: pieSections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLegend(emotionCounts),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Map<String, int> emotionCounts) {
    final emotionTypes = ['HAPPY', 'SAD', 'ANGRY', 'FEAR', 'NEUTRAL'];
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: emotionTypes.map((type) {
        final count = emotionCounts[type] ?? 0;
        if (count == 0) return const SizedBox.shrink();
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getEmotionColor(type),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  type,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
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

enum ChartType {
  line,
  bar,
  pie,
}

