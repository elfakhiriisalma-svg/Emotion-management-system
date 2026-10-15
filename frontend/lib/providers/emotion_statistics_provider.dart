import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/api_exception.dart';

class EmotionStatisticsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _statistics;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get statistics => _statistics;

  String? get mostFrequentEmotion => _statistics?['mostFrequentEmotion'] as String?;
  int? get mostFrequentEmotionCount => _statistics?['mostFrequentEmotionCount'] as int?;
  Map<String, int>? get emotionFrequency {
    if (_statistics?['emotionFrequency'] != null) {
      final map = _statistics!['emotionFrequency'] as Map<String, dynamic>;
      return map.map((key, value) => MapEntry(key, value as int));
    }
    return null;
  }
  int? get stressLevel => _statistics?['stressLevel'] as int?;
  double? get averageConfidence => _statistics?['averageConfidence'] as double?;
  int? get totalEmotions => _statistics?['totalEmotions'] as int?;

  Future<bool> loadStatistics(int employeeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getEmployeeStatistics(employeeId);
      
      if (response.statusCode == 200 && response.data != null) {
        _statistics = response.data as Map<String, dynamic>;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to load statistics';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to load statistics. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


