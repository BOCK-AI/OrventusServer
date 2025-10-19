// lib/data/repository/vehicle_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_constants.dart';
import '/models/vehicle.dart';

class VehicleRepository {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  // Helper to get the auth token and create request options
  Future<Options> _getAuthOptions() async {
    final accessToken = await _storage.read(key: 'accessToken');
    if (accessToken == null) {
      throw 'Authentication Token not found. Please log in.';
    }
    return Options(headers: {'Authorization': 'Bearer $accessToken'});
  }

  // Corresponds to GET /api/v1/vehicles
  Future<List<Vehicle>> getAllVehicles() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get("$kBaseUrl/vehicles", options: options);
      return (response.data['vehicles'] as List).map((v) => Vehicle.fromJson(v)).toList();
    } on DioException catch (e) {
      throw e.response?.data['msg'] ?? 'Failed to load vehicles';
    }
  }

  // Corresponds to POST /api/v1/vehicles
  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post("$kBaseUrl/vehicles", data: vehicle.toJson(), options: options);
      return Vehicle.fromJson(response.data['vehicle']);
    } on DioException catch (e) {
      throw e.response?.data['msg'] ?? 'Failed to add vehicle';
    }
  }

  // Corresponds to PATCH /api/v1/vehicles/:id
  Future<Vehicle> updateVehicle(String id, Vehicle vehicle) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.patch("$kBaseUrl/vehicles/$id", data: vehicle.toJson(), options: options);
      return Vehicle.fromJson(response.data['vehicle']);
    } on DioException catch (e) {
      throw e.response?.data['msg'] ?? 'Failed to update vehicle';
    }
  }

  // Corresponds to DELETE /api/v1/vehicles/:id
  Future<void> deleteVehicle(String id) async {
    try {
      final options = await _getAuthOptions();
      await _dio.delete("$kBaseUrl/vehicles/$id", options: options);
    } on DioException catch (e) {
      throw e.response?.data['msg'] ?? 'Failed to delete vehicle';
    }
  }
}