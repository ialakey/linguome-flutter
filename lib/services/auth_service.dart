import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/entities/google_user.dart';
import 'package:linguome/entities/user.dart';
import 'package:linguome/providers/user_provider.dart';
import 'package:linguome/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrlApi,
    ),
  );

  AuthService() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? accessToken = await getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioError e, handler) async {
          if (e.response?.statusCode == 401) {
            String newAccessToken = await getNewAccessToken();
            e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            return handler.resolve(await dio.fetch(e.requestOptions));
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> authorizeOnServer(
      String authProvider,
      GoogleUser googleUser,
      BuildContext context,
      VoidCallback saveData,
      VoidCallback errorAlert,
      ) async {
    const String url = '/authorize';
    final Map<String, String> body = {
      'authProvider': authProvider,
      'token': googleUser.accessToken!,
    };

    try {
      final response = await dio.post(
        url,
        data: body,
      );

      if (response.statusCode == 200) {
        final responseBody = response.data;
        final accessToken = responseBody['accessToken'];
        final refreshToken = responseBody['refreshToken'];

        final prefs = await SharedPreferences.getInstance();
        final userDataJson = prefs.getString('user');

        User user;

        if (userDataJson != null) {
          user = User.fromJson(json.decode(userDataJson));
        } else {
          user = User();
        }

        saveData();
        await _saveUserData(user, googleUser, accessToken, refreshToken, context);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        errorAlert();
        throw Exception('Failed to authorize with Google');
      }
    } catch (error) {
      errorAlert();
      print('Error authorizing with Google: $error');
    }
  }

  Future<void> _saveUserData(User user, GoogleUser googleUser, String accessToken, String refreshToken, BuildContext context) async {
    final userState = Provider.of<UserState>(context, listen: false).user!;
    user.accessToken = accessToken;
    user.refreshToken = refreshToken;
    user.photoUrl = googleUser.photoUrl;
    user.email = googleUser.email;
    user.displayName = googleUser.displayName;
    user.language = userState.language;
    user.level = userState.level;

    final version = await fetchVersion();
    user.versionApp = version;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));

    await fetchUserData(user);
  }

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('user');
    if (userDataJson != null) {
      User user = User.fromJson(json.decode(userDataJson));
      return user.accessToken;
    }
    return null;
  }

  Future<String> getNewAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('user');

    User user = User.fromJson(json.decode(userDataJson!));

    const String apiUrl = '/refresh';

    try {
      final response = await dio.post(
        apiUrl,
        data: {'refreshToken': user.refreshToken!},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;
        String accessToken = responseData['accessToken'];
        user.accessToken = accessToken;
        await prefs.setString('user', json.encode(user.toJson()));
        return accessToken;
      } else {
        print('Error refresh token: ${response.data}');
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      print('Error request: $e');
      throw Exception('Failed to refresh token');
    }
  }

  Future<void> fetchUserData(User user) async {
    const String apiUrl = '/User';

    try {
      final response = await dio.get(
        apiUrl,
        options: Options(headers: {'Authorization': 'Bearer ${user.accessToken}'}),
      );

      if (response.statusCode == 200) {
        final userData = response.data;

        user.id = userData['id'];
        user.email = userData['email'];

        UserState userState = UserState();
        userState.saveUserToPrefs(user);
      } else {
        print('Error about User: ${response.statusCode}');
        print('Error text: ${response.data}');
      }
    } catch (error) {
      print('Failed to request: $error');
    }
  }

  Future<void> logout() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      print('Error Google: $error');
    }

    const String apiUrl = '/logout';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('user');

    User user = User.fromJson(json.decode(userDataJson!));

    final String? accessToken = user.accessToken;
    final String? refreshToken = user.refreshToken;

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final Map<String, String> body = {
      'refreshToken': refreshToken!,
    };

    try {
      final response = await dio.post(
        apiUrl,
        data: body,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        prefs.remove('user');
        prefs.remove('pages');
      } else {
        print('Error log: ${response.statusCode}');
        print('Error: ${response.data}');
      }
    } catch (error) {
      print('Error log : $error');
    }
  }

  Future<String> fetchVersion() async {
    try {
      final response = await dio.get('/version');

      if (response.statusCode == 200) {
        final data = response.data;
        final String version = data['version'];
        return version;
      } else {
        throw Exception('Failed to fetch version');
      }
    } catch (error) {
      throw Exception('Failed to fetch version: $error');
    }
  }
}