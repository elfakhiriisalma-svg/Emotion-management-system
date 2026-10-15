import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/emotion_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/emotion_chart.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state_widget.dart';

class ChartsTab extends StatefulWidget {
  const ChartsTab({super.key});

  @override
  State<ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  ChartType _selectedChartType = ChartType.line;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final emotionProvider =
          Provider.of<EmotionProvider>(context, listen: false);
      await emotionProvider.loadEmotionHistory(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Consumer<EmotionProvider>(
          builder: (context, emotionProvider, _) {
            if (emotionProvider.isLoading) {
              return const LoadingWidget(message: 'Loading chart data...');
            }

            if (emotionProvider.emotions.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.bar_chart,
                title: 'No data available',
                message: 'Record some emotions to see charts here',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Chart Type Selector
                _buildChartTypeSelector(),
                const SizedBox(height: 20),

                // Selected Chart
                EmotionChart(
                  emotions: emotionProvider.emotions,
                  chartType: _selectedChartType,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chart Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildChartTypeButton(
                    ChartType.line,
                    Icons.show_chart,
                    'Trend',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildChartTypeButton(
                    ChartType.bar,
                    Icons.bar_chart,
                    'Distribution',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildChartTypeButton(
                    ChartType.pie,
                    Icons.pie_chart,
                    'Breakdown',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeButton(
    ChartType type,
    IconData icon,
    String label,
  ) {
    final isSelected = _selectedChartType == type;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedChartType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.grey[100],
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.primary : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

