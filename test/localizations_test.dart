import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Check localization files for missing keys', (WidgetTester tester) async {
    //Add new locales
    final List<String> supportedLocales = ['en', 'ru', 'fr', 'ja'];

    for (String baseLocale in supportedLocales) {
      for (String targetLocale in supportedLocales) {
        if (baseLocale == targetLocale) continue;

        final baseLocalizationPath = 'lib/l10n/app_$baseLocale.arb';
        final baseLocalizationJson = await rootBundle.loadString(baseLocalizationPath);
        final baseLocalizationMap = json.decode(baseLocalizationJson);

        final targetLocalizationPath = 'lib/l10n/app_$targetLocale.arb';
        final targetLocalizationJson = await rootBundle.loadString(targetLocalizationPath);
        final targetLocalizationMap = json.decode(targetLocalizationJson);

        List<String> missingKeys = [];
        baseLocalizationMap.forEach((key, value) {
          if (!targetLocalizationMap.containsKey(key)) {
            missingKeys.add(key);
          }
        });

        if (missingKeys.isNotEmpty) {
          print('Missing keys in $targetLocale localization from $baseLocale:');
          missingKeys.forEach((key) {
            print(key);
          });
        }

        expect(missingKeys.isEmpty, true, reason: 'Some keys are missing in $targetLocale localization from $baseLocale');
      }
    }
  });
}