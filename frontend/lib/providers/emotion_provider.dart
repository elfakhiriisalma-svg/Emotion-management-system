import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/emotion_model.dart';
import '../services/api_service.dart';

class EmotionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  List<EmotionModel> _emotions = [];
  EmotionModel? _lastEmotion;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EmotionModel> get emotions => _emotions;
  EmotionModel? get lastEmotion => _lastEmotion;

  Future<bool> createEmotion(String emotionType, double confidence) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.createEmotion(emotionType, confidence);
      
      if (response.statusCode == 201 && response.data != null) {
        final emotion = EmotionModel.fromJson(response.data as Map<String, dynamic>);
        _emotions.insert(0, emotion);
        _lastEmotion = emotion;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = (response.data as Map<String, dynamic>?)?['message'] ?? 'Failed to create emotion';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to create emotion. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> detectEmotionFromImage(XFile imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.detectEmotionFromImage(imageFile.path);
      
      if (response.statusCode == 201 && response.data != null) {
        final emotion = EmotionModel.fromJson(response.data as Map<String, dynamic>);
        _emotions.insert(0, emotion);
        _lastEmotion = emotion;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = (response.data as Map<String, dynamic>?)?['message'] ?? 'Failed to detect emotion';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to detect emotion from image. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> detectEmotionFromBase64(String base64Image) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.detectEmotionFromBase64(base64Image);
      
      if (response.statusCode == 201 && response.data != null) {
        final emotion = EmotionModel.fromJson(response.data as Map<String, dynamic>);
        _emotions.insert(0, emotion);
        _lastEmotion = emotion;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = (response.data as Map<String, dynamic>?)?['message'] ?? 'Failed to detect emotion';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to detect emotion from image. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadEmotionHistory(int employeeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getEmotionHistory(employeeId);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        _emotions = data.map((json) => EmotionModel.fromJson(json as Map<String, dynamic>)).toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to load emotion history';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to load emotion history. Please try again.';
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

