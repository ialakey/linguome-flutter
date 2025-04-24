import 'package:flutter/material.dart';
import 'package:linguome/config/app_colors.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/screens/games/game_sentence.dart';
import 'package:linguome/widgets/bottom_navigation.dart';

class TestResultScreen extends StatelessWidget {
  final int score;

  TestResultScreen(this.score);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('testResult')),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${AppLocalizations.of(context)!.translate('yourScore')}: $score/10',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24
              ),
            ),
            SizedBox(height: 70),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EnglishLearningGame()),
                );
              },
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 18,
                  color: AppColors.textColorBlack,
                  fontFamily: 'Inter',
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.translate('tryAgain'),
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textColorBlack,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BottomNavigation(initialIndex: 3,)),
                );
              },
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                    fontSize: 18,
                    color: AppColors.textColorBlack,
                    fontFamily: 'Inter',
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.translate('goBack'),
                style: TextStyle(
                fontSize: 18,
                color: AppColors.textColorBlack,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}