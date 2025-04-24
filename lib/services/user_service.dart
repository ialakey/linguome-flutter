import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:linguome/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<User?> getCurrentUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataJson = prefs.getString('user');
      if (userDataJson != null) {
        return User.fromJson(json.decode(userDataJson));
      }
    } catch (e) {
      debugPrint('Error getting user data: $e');
    }
    return null;
  }
}