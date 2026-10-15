/// Model for pre-capture questionnaire form
class PreCaptureForm {
  final String mood;
  final double sleepQuality;
  final bool stressed;
  final String? painDescription;
  final DateTime timestamp;

  PreCaptureForm({
    required this.mood,
    required this.sleepQuality,
    required this.stressed,
    this.painDescription,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create an empty form
  factory PreCaptureForm.empty() {
    return PreCaptureForm(
      mood: '',
      sleepQuality: 3.0,
      stressed: false,
      painDescription: null,
    );
  }

  /// Check if the form is valid
  bool get isValid => mood.isNotEmpty;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'sleepQuality': sleepQuality,
      'stressed': stressed,
      'painDescription': painDescription,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory PreCaptureForm.fromJson(Map<String, dynamic> json) {
    return PreCaptureForm(
      mood: json['mood'] as String,
      sleepQuality: (json['sleepQuality'] as num).toDouble(),
      stressed: json['stressed'] as bool,
      painDescription: json['painDescription'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  PreCaptureForm copyWith({
    String? mood,
    double? sleepQuality,
    bool? stressed,
    String? painDescription,
    DateTime? timestamp,
  }) {
    return PreCaptureForm(
      mood: mood ?? this.mood,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stressed: stressed ?? this.stressed,
      painDescription: painDescription ?? this.painDescription,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}


