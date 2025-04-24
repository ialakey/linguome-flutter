import 'package:flutter/material.dart';
import 'package:linguome/config/language_config.dart';
import 'package:linguome/helper/amplitude_manager.dart';
import 'package:linguome/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:linguome/providers/language_provider.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/entities/user.dart';
import 'package:linguome/screens/choose_levels_screen.dart';
import 'package:quickalert/quickalert.dart';

class ChooseLanguageScreen extends StatefulWidget {
  @override
  _ChooseLanguageScreenState createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  String? _selectedLanguageName;
  Locale? _selectedLanguageLocale;

  @override
  Widget build(BuildContext context) {
    final Map<String, Locale> languages = LanguageConfig.supportedLanguages(context);

    return Scaffold(
      body: Center(
        child: Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.translate('whatIsYourNativeLanguage'),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  children: languages.entries.map((entry) {
                    final String languageName = entry.key;
                    final Locale locale = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          AmplitudeManager()
                              .analytics.logEvent(
                              'ChooseLanguageScreen',
                              eventProperties: {
                                'button_clicked': 'language',
                                'languageName': languageName
                              });
                          setState(() {
                            _selectedLanguageName = languageName;
                            _selectedLanguageLocale = locale;
                          });
                          languageProvider.updateAndSaveLocale(locale);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedLanguageLocale == locale ? Colors.blue : Colors.grey,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              title: Text(
                                AppLocalizations.of(context)!.translate(languageName),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18.0,
                                  color: _selectedLanguageLocale == locale ? Colors.blue : Colors.black,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedLanguageName = languageName;
                                  _selectedLanguageLocale = locale;
                                });
                                languageProvider.updateAndSaveLocale(locale);
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedLanguageLocale != null) {
                      User newUser = User();
                      newUser.language = {
                        _selectedLanguageName!: _selectedLanguageLocale!
                      };
                      UserState userState = Provider.of<UserState>(context, listen: false);
                      userState.setUser(newUser);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChooseLevelsScreen()),
                      );
                      AmplitudeManager()
                          .analytics.logEvent(
                          'ChooseLanguageScreen',
                          eventProperties: {
                            'button_clicked': 'next',
                            'languageName': _selectedLanguageLocale
                          });
                    } else {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: AppLocalizations.of(context)!.translate('error'),
                        text: AppLocalizations.of(context)!.translate('pleaseSelectALanguage'),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                  ),
                  child: Text(
                      AppLocalizations.of(context)!.translate('next'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}