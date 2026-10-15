import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/emotion_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/emotion_model.dart';

class EmotionsTab extends StatefulWidget {
  const EmotionsTab({super.key});

  @override
  State<EmotionsTab> createState() => _EmotionsTabState();
}

class _EmotionsTabState extends State<EmotionsTab> {
  final List<String> _emotionTypes = ['HAPPY', 'SAD', 'ANGRY', 'FEAR', 'NEUTRAL'];
  String? _selectedEmotion;
  double _confidence = 0.5;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null && mounted) {
      final emotionProvider = Provider.of<EmotionProvider>(context, listen: false);
      final success = await emotionProvider.detectEmotionFromImage(image);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Emotion détectée et enregistrée !',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '✅ Une alerte a été envoyée automatiquement à votre médecin',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(emotionProvider.errorMessage ?? 'Failed to detect emotion'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitEmotion() async {
    if (_selectedEmotion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an emotion type'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final emotionProvider = Provider.of<EmotionProvider>(context, listen: false);
    final success = await emotionProvider.createEmotion(_selectedEmotion!, _confidence);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emotion saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _selectedEmotion = null;
        _confidence = 0.5;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emotionProvider.errorMessage ?? 'Failed to save emotion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Record Emotion',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedEmotion,
                    decoration: const InputDecoration(
                      labelText: 'Emotion Type',
                      prefixIcon: Icon(Icons.mood),
                      border: OutlineInputBorder(),
                    ),
                    items: _emotionTypes.map((emotion) {
                      return DropdownMenuItem(
                        value: emotion,
                        child: Text(emotion),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEmotion = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Confidence: ${(_confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Slider(
                    value: _confidence,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: '${(_confidence * 100).toStringAsFixed(0)}%',
                    onChanged: (value) {
                      setState(() {
                        _confidence = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<EmotionProvider>(
                    builder: (context, emotionProvider, _) {
                      return ElevatedButton(
                        onPressed: emotionProvider.isLoading
                            ? null
                            : _submitEmotion,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: emotionProvider.isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Save Emotion'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Detect from Image',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Take a photo to automatically detect your emotion',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Consumer<EmotionProvider>(
                    builder: (context, emotionProvider, _) {
                      return ElevatedButton.icon(
                        onPressed: emotionProvider.isLoading ? null : _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Consumer<EmotionProvider>(
            builder: (context, emotionProvider, _) {
              if (emotionProvider.lastEmotion != null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Recorded Emotion',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildEmotionCard(emotionProvider.lastEmotion!),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionCard(EmotionModel emotion) {
    return ListTile(
      leading: _getEmotionIcon(emotion.emotionType),
      title: Text(
        emotion.emotionType,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Confidence: ${(emotion.confidence * 100).toStringAsFixed(1)}%',
      ),
      trailing: Text(
        _formatDateTime(emotion.timestamp),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }

  Widget _getEmotionIcon(String emotionType) {
    IconData icon;
    Color color;

    switch (emotionType) {
      case 'HAPPY':
        icon = Icons.sentiment_very_satisfied;
        color = Colors.green;
        break;
      case 'SAD':
        icon = Icons.sentiment_very_dissatisfied;
        color = Colors.blue;
        break;
      case 'ANGRY':
        icon = Icons.sentiment_very_dissatisfied;
        color = Colors.red;
        break;
      case 'FEAR':
        icon = Icons.sentiment_dissatisfied;
        color = Colors.orange;
        break;
      default:
        icon = Icons.sentiment_neutral;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 32);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

