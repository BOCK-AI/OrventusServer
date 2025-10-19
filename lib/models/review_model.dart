// lib/data/models/review_model.dart

class ReviewModel {
  final int id;
  final double rating;
  final String? comment;
  final int rideId;
  final DateTime createdAt;
  // Denormalized fields for easy UI display
  final String customerName;
  final String driverName;

  ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.rideId,
    required this.createdAt,
    required this.customerName,
    required this.driverName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Safely access nested data
    final rideData = json['ride'] ?? {};
    final customerData = rideData['customer'] ?? {};
    final riderData = rideData['rider'] ?? {};

    return ReviewModel(
      id: json['id'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      rideId: json['rideId'],
      createdAt: DateTime.parse(json['createdAt']),
      customerName: customerData['name'] ?? 'N/A',
      driverName: riderData['name'] ?? 'N/A',
    );
  }
}