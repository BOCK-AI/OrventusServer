// lib/data/models/notification_model.dart

class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'] ?? 'General',
      title: json['title'] ?? 'No Title',
      message: json['message'] ?? 'No Message',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}