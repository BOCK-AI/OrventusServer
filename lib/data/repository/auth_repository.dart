import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_constants.dart';
import '/models/user_model.dart';

class AuthRepository {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<void> login({required String phone}) async {
    try {
      await _dio.post("$kBaseUrl/auth/login", data: {"phone": phone, "role": "admin"});
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> verifyOtp({required String phone, required String otp}) async {
    try {
      final response = await _dio.post("$kBaseUrl/auth/verify", data: {"phone": phone, "otp": otp});
      final responseData = response.data;
      if (responseData.containsKey('accessToken')) {
        await _storage.write(key: 'accessToken', value: responseData['accessToken']);
        print("--- Access Token SAVED to storage ---");
      }
      return responseData;
    } catch (e) {
      throw e.toString();
    }
  }
}