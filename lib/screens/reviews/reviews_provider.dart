// lib/screens/reviews/reviews_provider.dart

import 'package:flutter/material.dart';
import '/models/review_model.dart';
import '../../data/repository/review_repository.dart';

class ReviewsProvider with ChangeNotifier {
  final ReviewRepository _repo = ReviewRepository();
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ReviewsProvider() {
    fetchAllReviews();
  }

  Future<void> fetchAllReviews() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _reviews = await _repo.getAllReviews();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}