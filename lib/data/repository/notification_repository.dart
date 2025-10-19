import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_constants.dart';
import '/models/notification_model.dart';

class NotificationRepository {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<Options> _getAuthOptions() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw 'Authentication token not found.';
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      // --- THIS IS THE FIX ---
      final options = await _getAuthOptions(); 
      // --- END FIX ---
      final response = await _dio.get("$kBaseUrl/notifications", options: options);
      return (response.data['notifications'] as List).map((n) => NotificationModel.fromJson(n)).toList();
    } on DioException catch (e) {
      throw e.response?.data['msg'] ?? 'Failed to load notifications';
    }
  }

  Future<NotificationModel> createNotification({
    required String type,
    required String title,
    required String message,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        "$kBaseUrl/notifications",
        data: {'type': type, 'title': title, 'message': message},
        options: options,
      );
      return NotificationModel.fromJson(response.data['notification']);
    } on DioException catch (e) {
      throw e.response?.data['msg'] ?? 'Failed to send notification';
    }
  }
}