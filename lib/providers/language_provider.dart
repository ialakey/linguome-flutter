import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:linguome/config/language_config.dart';
import 'package:linguome/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class LanguageProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  late Locale _selectedLocale;

  Locale get selectedLocale => _selectedLocale;

  final List<Locale> supportedLocales = LanguageConfig.supportedLocales;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    String? userDataJson = _prefs.getString('user');

    if (userDataJson != null) {
      User user = User.fromJson(json.decode(userDataJson));
      Map<String, Locale>? savedLanguage = user.language;
      if (savedLanguage != null &&
          supportedLocales.contains(savedLanguage.values.first)) {
        _selectedLocale = savedLanguage.values.first;
      } else {
        _setDefaultLocale();
      }
    } else {
      _setDefaultLocale();
    }

    notifyListeners();
  }

  void _setDefaultLocale() {
    Locale deviceLocale = ui.window.locale;
    if (supportedLocales
        .any((locale) => locale.languageCode == deviceLocale.languageCode)) {
      _selectedLocale = deviceLocale;
    } else {
      _selectedLocale = const Locale('en', '');
    }
  }

  Future<void> updateLocale(Map<String, Locale> newLocale) async {
    _prefs = await SharedPreferences.getInstance();
    String? userDataJson = _prefs.getString('user');
    User user = User.fromJson(json.decode(userDataJson!));
    user.language = newLocale;
    _prefs.setString('user', json.encode(user.toJson()));

    _selectedLocale = newLocale.values.first;

    notifyListeners();
  }

  Future<void> updateAndSaveLocale(Locale newLocale) async {
    _selectedLocale = newLocale;
    notifyListeners();

    _prefs = await SharedPreferences.getInstance();
    String? userDataJson = _prefs.getString('user');
    if (userDataJson != null) {
      User user = User.fromJson(json.decode(userDataJson));
      user.language = {_selectedLocale.languageCode: _selectedLocale};
      _prefs.setString('user', json.encode(user.toJson()));
    }
  }
}