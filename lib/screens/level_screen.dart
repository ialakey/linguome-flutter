import 'package:flutter/material.dart';
import 'package:linguome/config/level_config.dart';
import 'package:linguome/localizations/app_localizations.dart';

class LevelScreen extends StatelessWidget {
  final String selectedLevel;

  LevelScreen({required this.selectedLevel});

  @override
  Widget build(BuildContext context) {
    final List<String> levels = LevelConfig.supportedLevels(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('selectLevel'),
          style: TextStyle(
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final language = levels[index];
          return ListTile(
            title: Text(
                AppLocalizations.of(context)!.translate(language),
                style: TextStyle(
                fontFamily: 'Inter',
              ),
            ),
            onTap: () {
              Navigator.pop(context, language);
            },
          );
        },
      ),
    );
  }
}