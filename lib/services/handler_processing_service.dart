import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linguome/entities/full_page.dart';
import 'package:linguome/entities/item.dart';
import 'package:linguome/entities/page.dart';
import 'package:linguome/entities/word_definition.dart';
import 'package:linguome/entities/word_vocabulary.dart';
import 'package:linguome/entities/wordlist.dart';
import 'package:linguome/helper/amplitude_manager.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/services/page_service.dart';
import 'package:linguome/services/word_service.dart';
import 'package:quickalert/quickalert.dart';

class HandlerProcessingService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _picker = ImagePicker();

  Future<FullPage?> takePictureOrGallery(ImageSource source, BuildContext context) async {
    try {
      XFile? imageFile = await _picker.pickImage(source: source);
      if (imageFile != null) {
        final file = File(imageFile.path);
        final inputImage = InputImage.fromFile(file);
        final recognizedText = await _textRecognizer.processImage(inputImage);
        String text = recognizedText.text;
        AmplitudeManager()
            .logProfileEvent(
            'Create page',
            eventProperties: {
              'text': text,
            });
        return await createFullPage(text, context);
      }
    } catch (e) {
      AmplitudeManager()
          .logProfileEvent(
          'Error',
          eventProperties: {
            'message': 'Error taking picture: $e',
          });
      print('Error taking picture: $e');
    }
    return null;
  }

  Future<FullPage?> createFullPage(String text, BuildContext context) async {
    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: AppLocalizations.of(context)!.translate('loading'),
        text: AppLocalizations.of(context)!.translate('creatingPage'),
      );
      final PageService pageService = PageService();
      final Map<String, dynamic> responseCreatePage = await pageService.createPage(text);
      final PageLinguome page = PageLinguome.fromJson(responseCreatePage);
      List<Item> itemList = await fetchItems(page.id);
      Navigator.pop(context);
      return FullPage(pageLinguome: page, items: itemList);
    } catch (e) {
      Navigator.pop(context);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: AppLocalizations.of(context)!.translate('oops'),
        text: AppLocalizations.of(context)!.translate('failedToCreatePage'),
      );
      AmplitudeManager()
          .logProfileEvent(
          'Error',
          eventProperties: {
            'message': 'Error create page: $e',
          });
      return null;
    }
  }

  Future<List<Item>> fetchItems(String pageId) async {
    try {
      final WordService wordService = WordService();
      final Map<String, dynamic> response = await wordService.fetchWordList(pageId);
      final Wordlist wordlist = Wordlist.fromJson(response);

      final List<Item> items = wordlist.items.map((item) {
        item.pageId = pageId;
        return item;
      }).toList();

      return items;
    } catch (e) {
      AmplitudeManager()
          .logProfileEvent(
          'Error',
          eventProperties: {
            'message': 'Error fetching items: $e',
          });
      print('Error fetching items: $e');
      return [];
    }
  }

  Future<List<PageLinguome>> fetchPages() async {
    try {
      final PageService pageService = PageService();
      final List<dynamic> response = await pageService.fetchPage();

      return response.map((e) => PageLinguome.fromJson(e)).toList();
    } catch (e, stackTrace) {
      AmplitudeManager()
          .logProfileEvent(
          'Error',
          eventProperties: {
            'message': 'Error fetching pages: $e\nStackTrace: $stackTrace',
          });
      print('Error fetching pages: $e\nStackTrace: $stackTrace');
      return [];
    }
  }

  Future<void> deletePage(String pageId) async {
    try {
      final PageService pageService = PageService();
      await pageService.deletePage(pageId);
    } catch (e) {
      AmplitudeManager()
          .logProfileEvent(
          'Error',
          eventProperties: {
            'message': 'Error deleting page: $e',
          });
      print('Error deleting page: $e');
    }
  }

  Future<List<WordDefinition>> fetchWordDefinition(String word, String? partOfSpeech, bool? strict) async {
    final WordService wordService = WordService();
    List<WordDefinition> wordDefinitions = await wordService.fetchWordDefinition(word, partOfSpeech, strict);
    return wordDefinitions;
  }

  Future<List<WordVocabulary>> fetchVocabulary(
    int? count,
    int? page,
    String? sort,
    String? search,
    String? status
      ) async {
    final WordService wordService = WordService();
    List<WordVocabulary> wordDefinitions = await wordService.fetchVocabulary(
        count,
        page,
        sort,
        search,
        status
    );
    return wordDefinitions;
  }

  Future<void> addWordToVocabulary(String word, String pos, String status) async {
    final WordService wordService = WordService();
    wordService.addWordToVocabulary(word, pos, status);
  }
}