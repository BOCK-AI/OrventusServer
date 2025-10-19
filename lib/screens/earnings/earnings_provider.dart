// lib/screens/earnings/earnings_provider.dart

import 'package:flutter/material.dart';
import '/models/earnings_report_model.dart';
import '../../data/repository/earnings_repository.dart';

class EarningsProvider with ChangeNotifier {
  final EarningsRepository _repo = EarningsRepository();
  EarningsReportModel? _report;
  bool _isLoading = true;
  String? _error;

  EarningsReportModel? get report => _report;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EarningsProvider() {
    fetchEarningsReport();
  }

  Future<void> fetchEarningsReport() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _report = await _repo.getEarningsReport();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}