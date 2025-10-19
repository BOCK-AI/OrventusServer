import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_constants.dart';
import '/models/dashboard_stats_model.dart';

class StatsRepository {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) throw 'Authentication token not found.';
      
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _dio.get("$kBaseUrl/stats/dashboard", options: options);
      
      return DashboardStatsModel.fromJson(response.data);
    } catch (e) {
      print("Error fetching dashboard stats: $e");
      throw e.toString();
    }
  }
}