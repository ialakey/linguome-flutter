import 'package:flutter/material.dart';

class User {
  String? id;
  String? email;
  String? accessToken;
  String? refreshToken;
  Map<String, Locale>? language;
  String? level;
  String? displayName;
  String? photoUrl;
  String? versionApp;
  int? timeSpentInGame;

  User({
    this.id,
    this.email,
    this.accessToken,
    this.refreshToken,
    this.language,
    this.level,
    this.displayName,
    this.photoUrl,
    this.versionApp,
    this.timeSpentInGame,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? languageMapJson = json['language'] as Map<String, dynamic>?;
    Map<String, Locale>? languageMap;
    if (languageMapJson != null) {
      languageMap = {};
      languageMapJson.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          languageMap![key] = Locale(value['languageCode'], value['countryCode']);
        }
      });
    }

    return User(
      id: json['id'] as String?,
      email: json['email'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      language: languageMap,
      level: json['level'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      versionApp: json['versionApp'] as String?,
      timeSpentInGame: json['timeSpentInGame'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? languageMapJson;
    if (language != null) {
      languageMapJson = {};
      language!.forEach((key, value) {
        languageMapJson![key] = {'languageCode': value.languageCode, 'countryCode': value.countryCode};
      });
    }

    return {
      'id': id,
      'email': email,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'language': languageMapJson,
      'level': level,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'versionApp': versionApp,
      'timeSpentInGame': timeSpentInGame,
    };
  }
}