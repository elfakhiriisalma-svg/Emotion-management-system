class EmotionModel {
  final int? id;
  final String emotionType;
  final double confidence;
  final DateTime timestamp;
  final int? employeeId;
  final String? employeeName;

  EmotionModel({
    this.id,
    required this.emotionType,
    required this.confidence,
    required this.timestamp,
    this.employeeId,
    this.employeeName,
  });

  factory EmotionModel.fromJson(Map<String, dynamic> json) {
    // Handle emotionType - could be String or enum object
    String emotionTypeStr;
    if (json['emotionType'] is String) {
      emotionTypeStr = json['emotionType'] as String;
    } else {
      // If it's an object, try to get the name
      emotionTypeStr = json['emotionType']?.toString() ?? 'NEUTRAL';
    }
    
    // Handle timestamp - could be String or already DateTime
    DateTime timestamp;
    if (json['timestamp'] is String) {
      timestamp = DateTime.parse(json['timestamp'] as String);
    } else if (json['timestamp'] is Map) {
      // Handle LocalDateTime from Java (if serialized as object)
      final timestampMap = json['timestamp'] as Map<String, dynamic>;
      timestamp = DateTime(
        timestampMap['year'] as int? ?? DateTime.now().year,
        timestampMap['monthValue'] as int? ?? DateTime.now().month,
        timestampMap['dayOfMonth'] as int? ?? DateTime.now().day,
        timestampMap['hour'] as int? ?? 0,
        timestampMap['minute'] as int? ?? 0,
        timestampMap['second'] as int? ?? 0,
      );
    } else {
      timestamp = DateTime.now();
    }
    
    return EmotionModel(
      id: json['id'] as int?,
      emotionType: emotionTypeStr,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      timestamp: timestamp,
      employeeId: json['employeeId'] as int?,
      employeeName: json['employeeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emotionType': emotionType,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'employeeId': employeeId,
      'employeeName': employeeName,
    };
  }
}

