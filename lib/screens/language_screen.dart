import 'package:flutter/material.dart';
import 'package:linguome/config/language_config.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/providers/language_provider.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatelessWidget {
  final Map<String, Locale>? selectedLanguage;

  LanguageScreen({required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    final Map<String, Locale> languages = LanguageConfig.supportedLanguages(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('selectLanguage'),
          style: TextStyle(
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages.keys.elementAt(index);
          return ListTile(
            title: Text(
              AppLocalizations.of(context)!.translate(language),
              style: TextStyle(
                fontFamily: 'Inter',
              ),),
            onTap: () {
              languageProvider.updateLocale({language: languages[language]!});
              Navigator.pop(context, {language: languages[language]!});
            },
          );
        },
      ),
    );
  }
}