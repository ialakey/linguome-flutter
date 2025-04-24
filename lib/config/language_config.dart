import 'package:flutter/material.dart';

class LanguageConfig {
  static final List<Locale> supportedLocales = [
    const Locale('en', ''),
    const Locale('ru', ''),
    const Locale('fr', ''),
    const Locale('ja', ''),
  ];

  static Map<String, Locale> supportedLanguages(BuildContext context) => {
    'english' : supportedLocales[0],
    'russian' : supportedLocales[1],
    'french' : supportedLocales[2],
    'japanese' : supportedLocales[3],
  };
}