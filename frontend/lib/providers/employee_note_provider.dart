import 'package:flutter/foundation.dart';
import '../models/employee_note_model.dart';
import '../services/api_service.dart';
import '../services/api_exception.dart';

class EmployeeNoteProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  List<EmployeeNoteModel> _notes = [];
  
  // Protection contre les chargements simultanés
  final Map<int, bool> _loadingEmployees = {}; // employeeId -> isLoading
  
  // Cache pour éviter les requêtes répétées
  final Map<int, DateTime> _lastLoadTime = {}; // employeeId -> last load time
  static const Duration _cacheDuration = Duration(seconds: 30); // Cache de 30 secondes

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EmployeeNoteModel> get notes => _notes;
  
  // Vérifier si les notes pour un employee sont déjà chargées
  bool hasNotesForEmployee(int employeeId) {
    return _notes.any((note) => note.employeeId == employeeId);
  }
  
  // Vérifier si le cache est encore valide
  bool _isCacheValid(int employeeId) {
    final lastLoad = _lastLoadTime[employeeId];
    if (lastLoad == null) return false;
    return DateTime.now().difference(lastLoad) < _cacheDuration;
  }

  Future<bool> loadNotesByEmployeeId(int employeeId, {bool forceRefresh = false}) async {
    // Éviter les chargements simultanés pour le même employee
    if (_loadingEmployees[employeeId] == true) {
      return false; // Déjà en cours de chargement
    }
    
    // Si le cache est valide et qu'on a déjà des notes, ne pas recharger
    if (!forceRefresh && _isCacheValid(employeeId) && hasNotesForEmployee(employeeId)) {
      return true; // Utiliser les données en cache
    }
    
    _loadingEmployees[employeeId] = true;
    _isLoading = true;
    _errorMessage = null;
    
    // Notifier après le frame actuel pour éviter setState() during build
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.getEmployeeNotes(employeeId);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        final newNotes = data.map((json) => EmployeeNoteModel.fromJson(json as Map<String, dynamic>)).toList();
        
        // Vérifier si les données ont vraiment changé avant de notifier
        if (!_notesEqual(_notes, newNotes)) {
          _notes = newNotes;
        }
        _isLoading = false;
        _loadingEmployees[employeeId] = false;
        _lastLoadTime[employeeId] = DateTime.now(); // Mettre à jour le cache
        
        // Notifier après le frame actuel pour éviter setState() during build
        Future.microtask(() => notifyListeners());
        return true;
      } else {
        _errorMessage = 'Failed to load notes';
        _isLoading = false;
        _loadingEmployees[employeeId] = false;
        Future.microtask(() => notifyListeners());
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to load notes. Please try again.';
      _isLoading = false;
      _loadingEmployees[employeeId] = false;
      Future.microtask(() => notifyListeners());
      return false;
    } finally {
      // S'assurer que le flag est toujours réinitialisé
      _loadingEmployees[employeeId] = false;
    }
  }
  
  // Invalider le cache pour un employee (après création/modification/suppression)
  void _invalidateCache(int employeeId) {
    _lastLoadTime.remove(employeeId);
  }
  
  // Helper pour comparer les listes de notes
  bool _notesEqual(List<EmployeeNoteModel> list1, List<EmployeeNoteModel> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id || 
          list1[i].note != list2[i].note ||
          list1[i].employeeId != list2[i].employeeId) {
        return false;
      }
    }
    return true;
  }

  Future<bool> createNote(int employeeId, String note) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.createEmployeeNote(employeeId, note);
      
      if (response.statusCode == 201 && response.data != null) {
        final newNote = EmployeeNoteModel.fromJson(response.data as Map<String, dynamic>);
        _notes.insert(0, newNote);
        _isLoading = false;
        _invalidateCache(employeeId); // Invalider le cache après création
        Future.microtask(() => notifyListeners());
        return true;
      } else {
        _errorMessage = 'Failed to create note';
        _isLoading = false;
        Future.microtask(() => notifyListeners());
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to create note. Please try again.';
      _isLoading = false;
      Future.microtask(() => notifyListeners());
      return false;
    }
  }

  Future<bool> updateNote(int noteId, String note) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.updateEmployeeNote(noteId, note);
      
      if (response.statusCode == 200 && response.data != null) {
        final updatedNote = EmployeeNoteModel.fromJson(response.data as Map<String, dynamic>);
        final index = _notes.indexWhere((n) => n.id == noteId);
        if (index != -1) {
          _notes[index] = updatedNote;
          _invalidateCache(updatedNote.employeeId); // Invalider le cache après modification
        }
        _isLoading = false;
        Future.microtask(() => notifyListeners());
        return true;
      } else {
        _errorMessage = 'Failed to update note';
        _isLoading = false;
        Future.microtask(() => notifyListeners());
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update note. Please try again.';
      _isLoading = false;
      Future.microtask(() => notifyListeners());
      return false;
    }
  }

  Future<bool> deleteNote(int noteId) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.deleteEmployeeNote(noteId);
      
      if (response.statusCode == 200) {
        // Trouver la note avant de la supprimer pour obtenir le employeeId
        final deletedNoteIndex = _notes.indexWhere((n) => n.id == noteId);
        if (deletedNoteIndex != -1) {
          final employeeId = _notes[deletedNoteIndex].employeeId;
          _notes.removeAt(deletedNoteIndex);
          _invalidateCache(employeeId); // Invalider le cache après suppression
        } else {
          // Note déjà supprimée localement, supprimer quand même de la liste
          _notes.removeWhere((n) => n.id == noteId);
        }
        _isLoading = false;
        Future.microtask(() => notifyListeners());
        return true;
      } else {
        _errorMessage = 'Failed to delete note';
        _isLoading = false;
        Future.microtask(() => notifyListeners());
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to delete note. Please try again.';
      _isLoading = false;
      Future.microtask(() => notifyListeners());
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


