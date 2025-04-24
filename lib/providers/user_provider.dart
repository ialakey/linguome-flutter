import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:linguome/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserState extends ChangeNotifier {
  User? _user;

  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  Future<void> saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    prefs.setString('user', userJson);
  }

  Future<User?> getUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final userMap = jsonDecode(userJson);
      return User.fromJson(userMap);
    }
    return null;
  }

  User? get user => _user;
}
