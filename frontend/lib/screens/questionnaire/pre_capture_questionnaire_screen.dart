import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pre_capture_provider.dart';
import '../../models/pre_capture_form.dart';
import '../../config/app_theme.dart';
import '../../services/navigation_service.dart';
import '../../config/app_routes.dart';

/// Pre-capture questionnaire screen
/// Collects user mood, sleep quality, stress level, and optional pain description
/// before opening the camera to capture emotion
class PreCaptureQuestionnaireScreen extends StatefulWidget {
  const PreCaptureQuestionnaireScreen({super.key});

  @override
  State<PreCaptureQuestionnaireScreen> createState() =>
      _PreCaptureQuestionnaireScreenState();
}

class _PreCaptureQuestionnaireScreenState
    extends State<PreCaptureQuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMood;
  double _sleepQuality = 3.0;
  bool _stressed = false;
  final TextEditingController _painController = TextEditingController();

  final List<String> _moodOptions = [
    'Happy',
    'Sad',
    'Angry',
    'Neutral',
    'Anxious',
  ];

  @override
  void dispose() {
    _painController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedMood == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your mood'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      // Save form to provider
      final provider = Provider.of<PreCaptureProvider>(context, listen: false);
      provider.setForm(
        PreCaptureForm(
          mood: _selectedMood!,
          sleepQuality: _sleepQuality,
          stressed: _stressed,
          painDescription: _painController.text.trim().isEmpty
              ? null
              : _painController.text.trim(),
        ),
      );

      // Navigate to camera screen and wait for result
      final result = await NavigationService.toEmotionCapture();
      
      // Return the result to the previous screen (dashboard)
      if (mounted) {
        NavigationService.goBack(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Before We Start'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Section
                _buildTitleSection(theme),
                const SizedBox(height: 32),

                // Mood Question
                _buildMoodQuestion(theme),
                const SizedBox(height: 24),

                // Sleep Quality Question
                _buildSleepQualityQuestion(theme),
                const SizedBox(height: 24),

                // Stress Question
                _buildStressQuestion(theme),
                const SizedBox(height: 24),

                // Pain Question
                _buildPainQuestion(theme),
                const SizedBox(height: 32),

                // Continue Button
                _buildContinueButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlueLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sentiment_satisfied_rounded,
            color: AppTheme.primaryBlue,
            size: 28,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'How are you feeling today?',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w400,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Help us understand your current state before capturing your emotion',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodQuestion(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your mood today?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedMood,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.backgroundWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryBlue,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: _moodOptions.map((mood) {
              return DropdownMenuItem<String>(
                value: mood,
                child: Text(mood),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMood = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your mood';
              }
              return null;
            },
            hint: const Text('Select your mood'),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepQualityQuestion(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'How well did you sleep?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _sleepQuality.toStringAsFixed(0),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _sleepQuality,
            min: 1.0,
            max: 5.0,
            divisions: 4,
            label: _sleepQuality.toStringAsFixed(0),
            activeColor: AppTheme.primaryBlue,
            inactiveColor: AppTheme.dividerColor,
            onChanged: (value) {
              setState(() {
                _sleepQuality = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Poor',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
              Text(
                'Excellent',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStressQuestion(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Are you feeling stressed?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: _stressed,
            onChanged: (value) {
              setState(() {
                _stressed = value;
              });
            },
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildPainQuestion(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you feel about your workload, energy level, and tasks?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '(Optional)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _painController,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.backgroundWhite,
              hintText: 'e.g. workload, fatigue, satisfaction with your current tasks...',
              hintStyle: TextStyle(color: AppTheme.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryBlue,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(ThemeData theme) {
    return FilledButton(
      onPressed: _onContinue,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppTheme.primaryBlue,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_rounded, size: 20),
          const SizedBox(width: 8),
          Text(
            'Continue to Camera',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}