import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:linguome/config/app_colors.dart';
import 'package:linguome/config/language_config.dart';
import 'package:linguome/helper/amplitude_manager.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'providers/language_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en', null);

  LanguageProvider languageProvider = LanguageProvider();
  await languageProvider.init();

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo;
  IosDeviceInfo iosInfo;
  if (Platform.isAndroid) {
    androidInfo = await deviceInfo.androidInfo;
    AmplitudeManager().analytics.logEvent(
        'Startup Android',
        eventProperties: {
          'device_name': androidInfo.model
        }
    );
  } else if (Platform.isIOS) {
    iosInfo = await deviceInfo.iosInfo;
    AmplitudeManager().analytics.logEvent(
        'Startup IOS',
        eventProperties: {
          'device_name': iosInfo.name
        });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
        ChangeNotifierProvider<UserState>(create: (_) => UserState()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return MaterialApp(
          title: AppLocalizations.of(context)?.translate('appTitle') ?? '',
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            colorScheme: ThemeData().colorScheme.copyWith(background: AppColors.backgroundColor),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.backgroundColor,
            ),
          ),
          locale: languageProvider.selectedLocale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LanguageConfig.supportedLocales,
          home: SplashScreen(),
        );
      },
    );
  }
}