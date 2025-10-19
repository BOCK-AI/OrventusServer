// lib/models/document.dart
class DocumentType {
  String id;
  String name;
  bool requiresExpiry;
  bool isActive;

  DocumentType({
    required this.id,
    required this.name,
    required this.requiresExpiry,
    this.isActive = true,
  });

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      id: json['id'].toString(),
      name: json['name'],
      requiresExpiry: json['requiresExpiry'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'requiresExpiry': requiresExpiry,
      'isActive': isActive,
    };
  }
}