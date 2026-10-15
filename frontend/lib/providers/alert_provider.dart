import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/alert_model.dart';
import '../services/api_service.dart';

class AlertProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  List<AlertModel> _alerts = [];
  List<AlertModel> _unreadAlerts = [];
  
  // Real-time polling
  Timer? _pollingTimer;
  int? _currentManagerId;
  bool _isPolling = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AlertModel> get alerts => _alerts;
  List<AlertModel> get unreadAlerts => _unreadAlerts;
  int get unreadCount => _unreadAlerts.length;
  bool get isPolling => _isPolling;

  Future<bool> loadAlertsByManagerId(int managerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getAlertsByManagerId(managerId);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        _alerts = data.map((json) => AlertModel.fromJson(json as Map<String, dynamic>)).toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to load alerts';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to load alerts. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadUnreadAlertsByManagerId(int managerId, {bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _apiService.getUnreadAlertsByManagerId(managerId);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        final newAlerts = data.map((json) => AlertModel.fromJson(json as Map<String, dynamic>)).toList();
        
        // Vérifier si les données ont vraiment changé avant de notifier
        if (!_listsEqual(_unreadAlerts, newAlerts)) {
          _unreadAlerts = newAlerts;
          if (!silent) {
            _isLoading = false;
          }
          notifyListeners(); // Notifier seulement si les données ont changé
        } else {
          if (!silent) {
            _isLoading = false;
          }
          // Ne pas notifier si les données sont identiques (évite les rebuilds inutiles)
        }
        return true;
      } else {
        if (!silent) {
          _errorMessage = 'Failed to load unread alerts';
          _isLoading = false;
          notifyListeners();
        }
        return false;
      }
    } catch (e) {
      if (!silent) {
        _errorMessage = 'Failed to load unread alerts. Please try again.';
        _isLoading = false;
        notifyListeners();
      }
      return false;
    }
  }
  
  // Helper pour comparer les listes d'alertes
  bool _listsEqual(List<AlertModel> list1, List<AlertModel> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id || 
          list1[i].isRead != list2[i].isRead ||
          list1[i].message != list2[i].message) {
        return false;
      }
    }
    return true;
  }

  Future<bool> markAlertAsRead(int alertId) async {
    try {
      final response = await _apiService.markAlertAsRead(alertId);
      
      if (response.statusCode == 200) {
        // Update local state
        final alert = _alerts.firstWhere((a) => a.id == alertId);
        final index = _alerts.indexOf(alert);
        _alerts[index] = AlertModel(
          id: alert.id,
          message: alert.message,
          createdAt: alert.createdAt,
          isRead: true,
          employeeId: alert.employeeId,
          employeeName: alert.employeeName,
          managerId: alert.managerId,
          managerName: alert.managerName,
        );
        
        // Remove from unread list
        _unreadAlerts.removeWhere((a) => a.id == alertId);
        
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Start real-time polling for alerts (refreshes every 10 seconds)
  void startRealTimePolling(int managerId) {
    if (_isPolling && _currentManagerId == managerId) {
      return; // Already polling for this manager
    }

    stopPolling(); // Stop any existing polling
    _currentManagerId = managerId;
    _isPolling = true;

    // Load immediately (not silent for initial load)
    loadUnreadAlertsByManagerId(managerId);

    // Then poll every 10 seconds for real-time updates (silent to avoid UI flicker)
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentManagerId != null) {
        loadUnreadAlertsByManagerId(_currentManagerId!, silent: true);
      }
    });

    notifyListeners();
  }

  /// Stop real-time polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    _currentManagerId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}


