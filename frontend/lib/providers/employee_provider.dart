import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/emotion_model.dart';
import '../services/api_service.dart';

class EmployeeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  List<UserModel> _employees = [];
  Map<int, EmotionModel?> _employeeLatestEmotions = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UserModel> get employees => _employees;
  Map<int, EmotionModel?> get employeeLatestEmotions => _employeeLatestEmotions;

  EmotionModel? getLatestEmotionForEmployee(int employeeId) {
    return _employeeLatestEmotions[employeeId];
  }

  Future<bool> loadEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getEmployees();
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        _employees = data
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .where((user) => user.role == 'EMPLOYEE')
            .toList();
        
        // Load latest emotion for each employee
        await _loadLatestEmotionsForEmployees();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to load employees';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to load employees. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadLatestEmotionsForEmployees() async {
    _employeeLatestEmotions.clear();
    
    for (var employee in _employees) {
      try {
        final response = await _apiService.getEmotionHistory(employee.id);
        if (response.statusCode == 200 && response.data != null) {
          final List<dynamic> data = response.data as List<dynamic>;
          if (data.isNotEmpty) {
            final emotions = data.map((json) => EmotionModel.fromJson(json as Map<String, dynamic>)).toList();
            // Get the most recent emotion (first in the list if sorted by date desc)
            _employeeLatestEmotions[employee.id] = emotions.first;
          }
        }
      } catch (e) {
        // Continue if error loading emotion for one employee
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

