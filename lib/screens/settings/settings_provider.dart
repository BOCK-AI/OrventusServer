import 'package:flutter/material.dart';
import '../../data/repository/settings_repository.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsRepository _repo = SettingsRepository();
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;
  String? _error; // New state for holding the error message

  Map<String, dynamic> get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error; // Expose the error

  SettingsProvider() { fetchSettings(); }

  Future<void> fetchSettings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _settings = await _repo.getAllSettings();
    } catch (e) {
      _error = e.toString(); // Store the error
    } finally {
      _isLoading = false;
      notifyListeners(); // Always turn off loading
    }
  }

  Future<void> updateSettings(Map<String, String> newSettings) async {
    await _repo.updateSettings(newSettings);
    _settings.addAll(newSettings);
    notifyListeners();
  }
}