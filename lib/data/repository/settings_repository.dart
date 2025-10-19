import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_constants.dart';

class SettingsRepository {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<Options> _getAuthOptions() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw 'Not authenticated';
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<Map<String, dynamic>> getAllSettings() async {
    final options = await _getAuthOptions();
    final response = await _dio.get("$kBaseUrl/settings", options: options);
    return response.data['settings'];
  }

  Future<void> updateSettings(Map<String, String> settings) async {
    final options = await _getAuthOptions();
    await _dio.patch("$kBaseUrl/settings", data: settings, options: options);
  }
}