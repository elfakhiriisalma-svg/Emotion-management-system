import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/emotion_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/emotion_model.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/emotion_card.dart';
import '../../../widgets/emotion_chart.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
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
    return Consumer<EmotionProvider>(
      builder: (context, emotionProvider, _) {
        if (emotionProvider.isLoading) {
          return const LoadingWidget(message: 'Loading emotions...');
        }

        if (emotionProvider.emotions.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.history,
            title: 'No emotions recorded yet',
            message: 'Start recording your emotions to see them here',
          );
        }

        return RefreshIndicator(
          onRefresh: _loadHistory,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Chart Section
              EmotionChart(
                emotions: emotionProvider.emotions,
                chartType: ChartType.line,
              ),
              const SizedBox(height: 20),
              
              // List Header
              const Text(
                'Recent Emotions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Emotion List
              ...emotionProvider.emotions.map((emotion) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EmotionCard(emotion: emotion),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

