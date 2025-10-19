// lib/data/repository/document_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_constants.dart';
import '/models/document.dart';

class DocumentRepository {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<Options> _getAuthOptions() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw 'Not authenticated';
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<DocumentType>> getAllDocuments() async {
    final options = await _getAuthOptions();
    final response = await _dio.get("$kBaseUrl/documents", options: options);
    return (response.data['documentTypes'] as List).map((d) => DocumentType.fromJson(d)).toList();
  }

  Future<DocumentType> addDocument(DocumentType doc) async {
    final options = await _getAuthOptions();
    final response = await _dio.post("$kBaseUrl/documents", data: doc.toJson(), options: options);
    return DocumentType.fromJson(response.data['documentType']);
  }

  Future<DocumentType> updateDocument(String id, DocumentType doc) async {
    final options = await _getAuthOptions();
    final response = await _dio.patch("$kBaseUrl/documents/$id", data: doc.toJson(), options: options);
    return DocumentType.fromJson(response.data['documentType']);
  }

  Future<void> deleteDocument(String id) async {
    final options = await _getAuthOptions();
    await _dio.delete("$kBaseUrl/documents/$id", options: options);
  }
}