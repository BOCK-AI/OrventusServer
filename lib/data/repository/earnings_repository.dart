import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_constants.dart';
import '/models/earnings_report_model.dart';

class EarningsRepository {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<EarningsReportModel> getEarningsReport() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) throw 'Authentication token not found.';
      
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _dio.get("$kBaseUrl/stats/earnings", options: options);
      
      return EarningsReportModel.fromJson(response.data);
    } on DioException catch (e) {
      print("Error fetching earnings report: $e");
      throw e.toString();
    }
  }
}