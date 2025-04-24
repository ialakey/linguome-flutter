import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:linguome/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeSpentProvider extends ChangeNotifier {
  int _timeSpentInMinutes = 1;
  Timer? _timer;

  TimeSpentProvider() {
    _loadTimeSpent();
    _startTimer();
  }

  int get timeSpentInMinutes => _timeSpentInMinutes;

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (_timeSpentInMinutes % 60 == 0) {
        notifyListeners();
      }
    });
  }

  void saveTimeSpent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('user');
    if (userDataJson != null) {
      User user = User.fromJson(json.decode(userDataJson));
      user.timeSpentInGame = _timeSpentInMinutes;
      await prefs.setString('user', json.encode(user.toJson()));
    }
  }

  void _loadTimeSpent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('user');
    if (userDataJson != null) {
      User user = User.fromJson(json.decode(userDataJson));
      _timeSpentInMinutes = user.timeSpentInGame!;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    saveTimeSpent();
    super.dispose();
  }
}