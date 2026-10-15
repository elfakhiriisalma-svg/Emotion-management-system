import 'package:flutter/foundation.dart';
import '../models/employee_tag_model.dart';
import '../services/api_service.dart';

class EmployeeTagProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  List<EmployeeTagModel> _tags = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EmployeeTagModel> get tags => _tags;

  List<EmployeeTagModel> getTagsByEmployeeId(int employeeId) {
    return _tags.where((tag) => tag.employeeId == employeeId).toList();
  }

  Future<bool> loadTagsByEmployeeId(int employeeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getEmployeeTags(employeeId);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        _tags = data.map((json) => EmployeeTagModel.fromJson(json as Map<String, dynamic>)).toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to load tags';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to load tags. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addTag(int employeeId, String tag) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.addEmployeeTag(employeeId, tag);
      
      if (response.statusCode == 201 && response.data != null) {
        final newTag = EmployeeTagModel.fromJson(response.data as Map<String, dynamic>);
        _tags.add(newTag);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to add tag';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to add tag. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeTag(int employeeId, String tag) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.removeEmployeeTag(employeeId, tag);
      
      if (response.statusCode == 200) {
        _tags.removeWhere((t) => t.employeeId == employeeId && t.tag == tag);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to remove tag';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to remove tag. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeTagById(int tagId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.removeEmployeeTagById(tagId);
      
      if (response.statusCode == 200) {
        _tags.removeWhere((t) => t.id == tagId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to remove tag';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to remove tag. Please try again.';
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


