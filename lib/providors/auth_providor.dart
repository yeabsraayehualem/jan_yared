// providers/auth_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jan_yared/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

// providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _sessionId; // ← ONLY THIS!

  UserModel? get user => _user;
  String? get sessionId => _sessionId;
  bool get isLoggedIn => _user != null;
  int get employee_id => _user!.employeeId;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final session = prefs.getString('session_id'); // ← just the string
    if (userJson != null && session != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
      _sessionId = session;
      notifyListeners();
    }
  }

  Future<void> save(UserModel user, String sessionId) async {
    _user = user;
    _sessionId = sessionId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    await prefs.setString('session_id', sessionId); // ← just string
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _sessionId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
