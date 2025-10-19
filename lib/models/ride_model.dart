// lib/data/models/ride_model.dart

import 'user_model.dart';

class RideModel {
  final String id;
  final String status;
  final String pickupAddress;
  final String dropoffAddress;
  final double fare;
  final double commission; // <-- ADD THIS LINE

  final DateTime createdAt;
  final UserModel? customer;
  final UserModel? rider;

  RideModel({
    required this.id,
    required this.status,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.fare,
    required this.commission, // <-- ADD THIS LINE

    required this.createdAt,
    this.customer,
    this.rider,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) return DateTime.parse(dateValue);
      if (dateValue is Map && dateValue.containsKey('\$date')) {
        return DateTime.parse(dateValue['\$date']);
      }
      return DateTime.now();
    }

    return RideModel(
      id: (json['id'] ?? 'N/A').toString(),
      status: json['status'] ?? 'UNKNOWN',
      pickupAddress: json['pickupAddress'] ?? 'No pickup address',
      dropoffAddress: json['dropoffAddress'] ?? 'No dropoff address',
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
      commission: (json['commission'] as num?)?.toDouble() ?? 0.0, // <-- ADD THIS LINE

      createdAt: parseDate(json['createdAt']),
      customer: json['customer'] != null ? UserModel.fromJson(json['customer']) : null,
      rider: json['rider'] != null ? UserModel.fromJson(json['rider']) : null,
    );
  }
}