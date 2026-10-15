import 'package:flutter/material.dart';
import '../models/pre_capture_form.dart';

/// Provider to manage pre-capture questionnaire form state
class PreCaptureProvider with ChangeNotifier {
  PreCaptureForm? _form;

  PreCaptureForm? get form => _form;
  bool get hasForm => _form != null;
  bool get isFormValid => _form?.isValid ?? false;

  /// Set the form data
  void setForm(PreCaptureForm form) {
    _form = form;
    notifyListeners();
  }

  /// Update form with partial data
  void updateForm({
    String? mood,
    double? sleepQuality,
    bool? stressed,
    String? painDescription,
  }) {
    _form = (_form ?? PreCaptureForm.empty()).copyWith(
      mood: mood,
      sleepQuality: sleepQuality,
      stressed: stressed,
      painDescription: painDescription,
    );
    notifyListeners();
  }

  /// Clear the form
  void clearForm() {
    _form = null;
    notifyListeners();
  }

  /// Reset to empty form
  void reset() {
    _form = PreCaptureForm.empty();
    notifyListeners();
  }
}


