import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/services/auth_service.dart';

class PageService {
  final AuthService _authService = AuthService();
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrlApi));

  PageService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken = await _authService.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioError e, handler) async {
        if (e.response?.statusCode == 401) {
          String newAccessToken = await _authService.getNewAccessToken();
          e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          return handler.resolve(await _dio.fetch(e.requestOptions));
        }
        return handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> createPage(String text) async {
    try {
      final String? token = await _authService.getAccessToken();

      if (token != null) {
        final Map<String, dynamic> requestData = {
          'text': text,
        };

        final response = await _dio.post(
          '/Page',
          data: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Failed to send request');
        }
      } else {
        throw Exception('Access token not found');
      }
    } catch (e) {
      throw Exception('Error creating page: $e');
    }
  }

  Future<void> deletePage(String pageId) async {
    try {
      final String? token = await _authService.getAccessToken();

      if (token != null) {
        final response = await _dio.delete(
          '/Page/$pageId',
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to send delete request');
        }
      } else {
        throw Exception('Access token not found');
      }
    } catch (e) {
      throw Exception('Error deleting page: $e');
    }
  }

  Future<dynamic> fetchPage() async {
    try {
      final String? token = await _authService.getAccessToken();

      if (token != null) {
        final response = await _dio.get(
          '/Page',
        );

        if (response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Failed to send request');
        }
      } else {
        throw Exception('Access token not found');
      }
    } catch (e) {
      throw Exception('Error fetching page: $e');
    }
  }
}