import 'package:dio/dio.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/entities/word_definition.dart';
import 'package:linguome/entities/word_vocabulary.dart';
import 'package:linguome/services/auth_service.dart';

class WordService {
  final AuthService _authService = AuthService();
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrlApi));

  WordService() {
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

  Future<List<WordVocabulary>> fetchVocabulary(
      int? count,
      int? page,
      String? sort,
      String? search,
      String? status,
      ) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (count != null) queryParameters['count'] = count;
      if (page != null) queryParameters['page'] = page;
      if (sort != null) queryParameters['sort'] = sort;
      if (search != null) queryParameters['search'] = search;
      if (status != null) queryParameters['status'] = status;

      final response = await _dio.get('/Vocabulary', queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final responseData = response.data['items'] as List<dynamic>;
        List<WordVocabulary> words = responseData.map((item) => WordVocabulary.fromJson(item)).toList();
        return words;
      } else {
        print('Error getting data: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<WordDefinition>> fetchWordDefinition(String word, String? partOfSpeech, bool? strict) async {
    try {

      String url = '/Word/$word';
      if (!strict!) {
        '$url?normalize=true';
      }

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey(partOfSpeech)) {
            List<dynamic> wordData = responseData[partOfSpeech];

            List<WordDefinition> definitions = wordData.map((json) =>
                WordDefinition.fromJson(json)).toList();
            return definitions;
                    } else {
            print('No data found for part of speech: $partOfSpeech');
          }
        } else {
          print('Invalid response data format');
        }
        return [];
      } else {
        print('Error getting data: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchWordList(String page) async {
    try {
      final response = await _dio.get('/WordList?page=$page&sort=level&wait-until-ready=true');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to send request');
      }
    } catch (error) {
      throw Exception('Error fetching word list: $error');
    }
  }

  Future<void> addWordToVocabulary(String word, String pos, String status) async {
    try {
      final data = {
        'word': word,
        'pos': pos,
        'status': status,
      };

      final response = await _dio.post('/Vocabulary', data: data);

      if (response.statusCode == 200) {
        print('Word added successfully');
      } else {
        print('Failed to add word: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding word: $error');
    }
  }
}