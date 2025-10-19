// lib/screens/rides/rides_provider.dart

import 'package:flutter/material.dart';
import '/models/ride_model.dart';
import '../../data/repository/ride_repository.dart';

class RidesProvider with ChangeNotifier {
  final RideRepository _rideRepository = RideRepository();
  List<RideModel> _rides = [];
  bool _isLoading = true;
  String? _error;

  List<RideModel> get rides => _rides;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RidesProvider() {
    fetchAllRides();
  }

  Future<void> fetchAllRides() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _rides = await _rideRepository.getRides();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}