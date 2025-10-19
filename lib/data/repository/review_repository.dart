// lib/data/repository/review_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_constants.dart';
import '/models/review_model.dart';

class ReviewRepository {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<List<ReviewModel>> getAllReviews() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) throw 'Authentication token not found.';
      
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _dio.get("$kBaseUrl/reviews", options: options);
      
      return (response.data['reviews'] as List).map((r) => ReviewModel.fromJson(r)).toList();
    } on DioException catch (e) {
      print("Error fetching reviews: $e");
      throw e.toString();
    }
  }
}