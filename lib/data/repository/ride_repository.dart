import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_constants.dart';
import '/models/ride_model.dart';

class RideRepository {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<List<RideModel>> getRides() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) throw 'Authentication token not found.';
      
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _dio.get("$kBaseUrl/rides", options: options);
      
      final List<dynamic> rideListJson = response.data['rides'];
      return rideListJson.map((json) => RideModel.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching rides: $e");
      throw e.toString();
    }
  }

  Future<void> createRideAsAdmin({
    required String pickupAddress,
    required String dropoffAddress,
    required String vehicle,
    required double fare,
    required String customerPhone,
  }) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) throw 'Not authenticated.';
      
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      
      await _dio.post(
        "$kBaseUrl/rides",
        data: {
          'pickupAddress': pickupAddress,
          'dropAddress': dropoffAddress,
          'vehicle': vehicle,
          'fare': fare,
          'customerPhone': customerPhone,
        },
        options: options,
      );
    } on DioException catch (e) {
      throw e.response?.data['msg'] ?? 'Failed to create ride';
    }
  }
}