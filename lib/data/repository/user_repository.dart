import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_constants.dart';
import '/models/user_model.dart';

class UserRepository {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<List<UserModel>> getUsers() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) throw 'Authentication token not found.';
      
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _dio.get("$kBaseUrl/users", options: options);
      
      final List<dynamic> userListJson = response.data['users'];
      return userListJson.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching users: $e");
      throw e.toString();
    }
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
  try {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw 'Not authenticated.';
    final options = Options(headers: {'Authorization': 'Bearer $token'});
    
    await _dio.patch(
      "$kBaseUrl/users/$userId/status",
      data: {'isActive': isActive},
      options: options,
    );
  } catch (e) {
    throw e.toString();
  }
}
}