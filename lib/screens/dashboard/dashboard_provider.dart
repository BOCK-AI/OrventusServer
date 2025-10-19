// lib/screens/dashboard/dashboard_provider.dart

import 'package:flutter/material.dart';
// --- CORRECTED IMPORT PATHS ---
import '/models/dashboard_stats_model.dart';
import '../../data/repository/stats_repository.dart';

class DashboardProvider with ChangeNotifier {
  final StatsRepository _statsRepository = StatsRepository();
  DashboardStatsModel? _stats;
  bool _isLoading = true;
  String? _error;

  DashboardStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DashboardProvider() {
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _stats = await _statsRepository.getDashboardStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}