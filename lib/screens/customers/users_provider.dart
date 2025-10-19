// lib/screens/customers/users_provider.dart

import 'package:flutter/material.dart';
import '/models/user_model.dart';
import '../../data/repository/user_repository.dart';

class UsersProvider with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  List<UserModel> _allUsers = [];
  bool _isLoading = true;
  String? _error;

  List<UserModel> get allUsers => _allUsers;
  // A helper to get only customers
  List<UserModel> get customers => _allUsers.where((user) => user.role == 'customer').toList();
  // A helper to get only riders
  List<UserModel> get riders => _allUsers.where((user) => user.role == 'rider').toList();
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  UsersProvider() {
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _allUsers = await _userRepository.getUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // In lib/screens/customers/users_provider.dart
Future<void> updateUserStatus(String userId, bool isActive) async {
  try {
    await _userRepository.updateUserStatus(userId, isActive);
    // After updating, find the user in the local list and update them
    // This provides an instant UI update without a full refresh.
    final index = _allUsers.indexWhere((user) => user.id == userId);
    if (index != -1) {
      // You'll need to add isActive to your UserModel and update it here
      // For now, we'll just refetch the whole list for simplicity.
      await fetchAllUsers();
    }
  } catch (e) {
    // Handle error
    print(e);
  }
}
}