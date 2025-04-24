import 'package:flutter/material.dart';
import 'package:linguome/config/app_colors.dart';
import 'package:linguome/helper/amplitude_manager.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/screens/choose_languages_screen.dart';

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.translate('learnEnglishBy'),
                  style: TextStyle(
                    color: AppColors.textColorBlack,
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.translate('readingYourTexts'),
                  style: TextStyle(
                    color: AppColors.textColorBlack,
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          AppLocalizations.of(context)!.translate('takeAPhotoOfYourText'),
                          style: TextStyle(
                            color: AppColors.textColorBlack,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          AppLocalizations.of(context)!.translate('seeTheListOfWordsInTheTextWithDefinitions'),
                          style: TextStyle(
                            color: AppColors.textColorBlack,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                            AppLocalizations.of(context)!.translate('readWithoutInterruptions'),
                          style: TextStyle(
                            color: AppColors.textColorBlack,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChooseLanguageScreen()),
              );
              AmplitudeManager()
                  .analytics.logEvent(
                  'StartScreen',
                  eventProperties: {'button_clicked': 'next'});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 150, vertical: 15),
            ),
            child: Text(AppLocalizations.of(context)!.translate('next')),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        ],
      ),
    );
  }
}