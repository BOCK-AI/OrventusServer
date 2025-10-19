// lib/screens/notifications/notifications_provider.dart

import 'package:flutter/material.dart';
import '/models/notification_model.dart';
import '../../data/repository/notification_repository.dart';

class NotificationsProvider with ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NotificationsProvider() {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _notifications = await _repo.getAllNotifications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendNotification({
    required String type,
    required String title,
    required String message,
  }) async {
    try {
      await _repo.createNotification(type: type, title: title, message: message);
      // After sending, refresh the history
      await fetchNotifications();
    } catch (e) {
      // Re-throw the error so the UI can display it
      throw e.toString();
    }
  }
}