import 'package:flutter/material.dart';
import 'package:linguome/config/level_config.dart';
import 'package:linguome/entities/user.dart';
import 'package:linguome/helper/amplitude_manager.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/providers/user_provider.dart';
import 'package:linguome/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class ChooseLevelsScreen extends StatefulWidget {
  @override
  _ChooseLevelsScreenState createState() => _ChooseLevelsScreenState();
}

class _ChooseLevelsScreenState extends State<ChooseLevelsScreen> {
  String? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    final List<String> levels = LevelConfig.supportedLevels(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.translate('whatIsYourEnglishLevel'),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLevel = level;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedLevel == level ? Colors.blue : Colors.grey,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.translate(level),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18.0,
                              color: _selectedLevel == level ? Colors.blue : Colors.black,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedLevel = level;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AmplitudeManager()
                    .analytics.logEvent(
                    'ChooseLevelsScreen',
                    eventProperties: {
                      'button_clicked': 'level',
                      'selectedLevel': _selectedLevel
                    });
                if (_selectedLevel != null) {
                  final User user = Provider.of<UserState>(context, listen: false).user!;
                  user.level = _selectedLevel!;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                } else {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: AppLocalizations.of(context)!.translate('error'),
                    text: AppLocalizations.of(context)!.translate('pleaseSelectALevel'),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 150, vertical: 15),
              ),
              child: Text(AppLocalizations.of(context)!.translate('next')),
            ),
          ],
        ),
      ),
    );
  }
}