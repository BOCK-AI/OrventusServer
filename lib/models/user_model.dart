// lib/data/models/user_model.dart

class UserModel {
  final String id;
  final String? name;
  final String? phone;
  final String? role; // Make nullable
  final bool isActive; // <-- NEW FIELD

  final DateTime? createdAt; // Make nullable

  UserModel({
    required this.id,
    this.name,
    this.phone,
    this.role,
    required this.isActive, // <-- ADDED TO CONSTRUCTOR

    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? 'N/A').toString(),
      name: json['name'],
      phone: json['phone']?.toString(), // Safely convert to string if not null
      role: json['role'], // It's okay if this is null now
      isActive: json['isActive'] ?? true, // <-- NEW FIELD PARSING

      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}