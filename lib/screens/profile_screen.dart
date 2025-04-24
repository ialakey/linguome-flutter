import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:linguome/config/app_colors.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/entities/user.dart';
import 'package:linguome/helper/amplitude_manager.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/screens/language_screen.dart';
import 'package:linguome/screens/level_screen.dart';
import 'package:linguome/screens/start_screen.dart';
import 'package:linguome/services/auth_service.dart';
import 'package:linguome/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final AuthService _authService = AuthService();

  Map<String, Locale>? language;
  String level = '';
  String email = '';
  String version = '1.0.0';
  String photoUrl = '';
  String displayName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    User? user = await UserService.getCurrentUser();
    if (user != null) {
      setState(() {
        language = user.language!;
        level = user.level!;
        email = user.email!;
        photoUrl = user.photoUrl!;
        version = user.versionApp!;
        displayName = user.displayName!;
      });
    }
  }

  Future<void> changeSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = await UserService.getCurrentUser();
    if (user != null) {
      user.language = language;
      user.level = level;
      user.email = email;

      final updatedUserJson = jsonEncode(user.toJson());
      prefs.setString('user', updatedUserJson);

      setState(() {
        language = user.language!;
        level = user.level!;
        email = user.email!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.translate('profile'),
          style: TextStyle(
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
            ),
            accountName: Text(
              displayName,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),
            ),
            accountEmail: Text(
                email,
              style:
              TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.grey
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: photoUrl != '' ? NetworkImage(photoUrl) : null,
              child: photoUrl == ''
                  ? Text(
                displayName.isNotEmpty ? displayName[0] : '',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Inter',
                ),
              )
                  : null,
            ),
          ),
          SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMenuItem(
                  context,
                  Image.asset('${AppConfig.assetsIcons}world.png', width: 24, height: 24),
                  AppLocalizations.of(context)!.translate('interfaceLanguage'),
                  language?.keys.first
              ),
              Divider(),
              _buildMenuItem(
                  context,
                  Image.asset('${AppConfig.assetsIcons}star.png', width: 24, height: 24),
                  AppLocalizations.of(context)!.translate('level'),
                  level
              ),
              Divider(),
              _buildMenuItem(
                  context,
                  Image.asset('${AppConfig.assetsIcons}shield-exclamation.png', width: 24, height: 24),
                  AppLocalizations.of(context)!.translate('privacy')
              ),
              Divider(),
              _buildMenuItem(
                  context,
                  Image.asset('${AppConfig.assetsIcons}interrogation.png', width: 24, height: 24),
                  AppLocalizations.of(context)!.translate('helpAndSupport')
              ),
              Divider(),
              _buildMenuItem(
                  context,
                  Image.asset('${AppConfig.assetsIcons}trash.png', width: 24, height: 24),
                  AppLocalizations.of(context)!.translate('deleteAccount')
              ),
              Divider(),
              _buildMenuItem(
                  context,
                  Image.asset('${AppConfig.assetsIcons}arrow-alt-square-right.png', width: 24, height: 24),
                  AppLocalizations.of(context)!.translate('logOut')
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Text(
                  "${AppLocalizations.of(context)!.translate('versionApp')} $version",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Image icon, String title,
      [String? trailingText]) {

    String truncatedText = trailingText != null && trailingText.length > 12
        ? trailingText.substring(0, 16) + '...'
        : trailingText ?? '';

    return ListTile(
      leading: icon,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textColorBlack,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
          if (truncatedText.isNotEmpty &&
              title != AppLocalizations.of(context)!.translate('logOut'))
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.translate(truncatedText),
                  style: TextStyle(
                    color: AppColors.textColorBlack,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 24,
                  ),
                ),
              ],
            ),
        ],
      ),
      onTap: () async {
        if (title == AppLocalizations.of(context)!.translate('interfaceLanguage')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                LanguageScreen(selectedLanguage: language)),
          ).then((selectedLanguage) {
            if (selectedLanguage != null) {
              setState(() {
                language = selectedLanguage;
                changeSettings();
              });
            }
          });
          AmplitudeManager()
              .logProfileEvent(
              'ProfileScreen',
              eventProperties: {
                'button_clicked': 'interfaceLanguage',
              });
        }
        if (title == AppLocalizations.of(context)!.translate('level')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                LevelScreen(
                    selectedLevel: level)),
          ).then((value) {
            if (value != null) {
              setState(() {
                level = value;
                changeSettings();
              });
            }
          });
          AmplitudeManager()
              .logProfileEvent(
              'ProfileScreen',
              eventProperties: {
                'button_clicked': 'level',
              });
        }
        if (title == AppLocalizations.of(context)!.translate('privacy')) {
          await launchUrl(Uri.parse(AppConfig.privacyPolicy));
          AmplitudeManager()
              .logProfileEvent(
              'ProfileScreen',
              eventProperties: {
                'button_clicked': 'privacy',
              });
        }
        if (title == AppLocalizations.of(context)!.translate('helpAndSupport')) {
          await launchUrl(Uri.parse(AppConfig.baseUrl));
          AmplitudeManager()
              .logProfileEvent(
              'ProfileScreen',
              eventProperties: {
                'button_clicked': 'helpAndSupport',
              });
        }
        if (title == AppLocalizations.of(context)!.translate('deleteAccount')) {
          await launchUrl(Uri.parse(AppConfig.deleteAccountUrl));
          AmplitudeManager()
              .logProfileEvent(
              'ProfileScreen',
              eventProperties: {
                'button_clicked': 'deleteAccount',
              });
        }
        if (title == AppLocalizations.of(context)!.translate('logOut')) {
          _authService.logout();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StartScreen()),
          );
          AmplitudeManager()
              .logProfileEvent(
              'ProfileScreen',
              eventProperties: {
                'button_clicked': 'logout',
              });
        }
      },
    );
  }
}