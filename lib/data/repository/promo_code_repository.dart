// lib/data/repository/promo_code_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_constants.dart';
import '/models/promo_code.dart';

class PromoCodeRepository {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<Options> _getAuthOptions() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw 'Not authenticated';
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<PromoCode>> getAllPromoCodes() async {
    final options = await _getAuthOptions();
    final response = await _dio.get("$kBaseUrl/promocodes", options: options);
    return (response.data['promoCodes'] as List).map((p) => PromoCode.fromJson(p)).toList();
  }

  Future<PromoCode> addPromoCode(PromoCode promoCode) async {
    final options = await _getAuthOptions();
    final response = await _dio.post("$kBaseUrl/promocodes", data: promoCode.toJson(), options: options);
    return PromoCode.fromJson(response.data['promoCode']);
  }

  Future<PromoCode> updatePromoCode(String id, PromoCode promoCode) async {
    final options = await _getAuthOptions();
    final response = await _dio.patch("$kBaseUrl/promocodes/$id", data: promoCode.toJson(), options: options);
    return PromoCode.fromJson(response.data['promoCode']);
  }

  Future<void> deletePromoCode(String id) async {
    final options = await _getAuthOptions();
    await _dio.delete("$kBaseUrl/promocodes/$id", options: options);
  }
}