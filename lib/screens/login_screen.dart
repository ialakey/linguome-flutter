import 'dart:io';

import 'package:flutter/material.dart';
import 'package:linguome/config/app_colors.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/helper/amplitude_manager.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/services/auth_google_apple.dart';
import 'package:linguome/widgets/custom_loading_indicator.dart';
import 'package:linguome/widgets/login_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String _statusText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomLoadingIndicator(),
            SizedBox(height: 20),
            Text(_statusText),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: SizedBox()),
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset('assets/images/app_icon.png'),
            ),
            Text(
              AppLocalizations.of(context)!.translate('appTitle'),
              style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textColorBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50),
            Platform.isIOS
                ? Column(
              children: [
                LoginButton(
                  text: AppLocalizations.of(context)!
                      .translate('continueWithApple'),
                  icon: FontAwesomeIcons.apple,
                  onPressed: () {
                    _signInWithApple(context);

                    AmplitudeManager()
                        .analytics.logEvent(
                        'LoginScreen',
                        eventProperties: {
                          'button_clicked': 'signInWithApple'
                        });
                  },
                ),
                SizedBox(height: 20),
                LoginButton(
                  text: AppLocalizations.of(context)!
                      .translate('continueWithGoogle'),
                  icon: FontAwesomeIcons.google,
                  onPressed: () {
                    _signInWithGoogle(context);

                    AmplitudeManager()
                        .analytics.logEvent(
                        'LoginScreen',
                        eventProperties: {
                          'button_clicked': 'signInWithGoogle'
                        });
                  },
                ),
              ],
            )
                : LoginButton(
              text: AppLocalizations.of(context)!
                  .translate('continueWithGoogle'),
              icon: FontAwesomeIcons.google,
              onPressed: () {
                _signInWithGoogle(context);

                AmplitudeManager()
                    .analytics.logEvent(
                    'LoginScreen',
                    eventProperties: {
                      'button_clicked': 'signInWithGoogle'
                    });
              },
            ),
            SizedBox(height: 50),
            InkWell(
              onTap: () async {
                await launchUrl(Uri.parse(AppConfig.termsOfUse));
              },
              child: Text(
                AppLocalizations.of(context)!
                    .translate('termsAndConditions'),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textColorBlack,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() {
      _loading = true;
      _statusText = AppLocalizations.of(context)!.translate('performingAuthorization');
    });
    try {
      await AuthGoogleAppleService().handleSignInGoogle(
          context,
          _saveData,
          _afterFetchWords,
          _errorAlert
      );
    } catch (error) {
      _errorAlert();
      print('Error signing in with Google: $error');
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    setState(() {
      _loading = true;
      _statusText = AppLocalizations.of(context)!.translate('performingAuthorization');
    });
    try {
      await AuthGoogleAppleService().handleSignInApple(
          context,
          _saveData,
          _afterFetchWords,
          _errorAlert
      );
    } catch (error) {
      _errorAlert();
      print('Error signing in with Google: $error');
    }
  }

  void _saveData() {
    setState(() {
      _loading = true;
      _statusText = AppLocalizations.of(context)!.translate('savingData');
    });
  }

  void _afterFetchWords() {
    setState(() {
      _loading = true;
      _statusText = AppLocalizations.of(context)!.translate('loadingDictionary');
    });
  }

  void _errorAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: AppLocalizations.of(context)!.translate('oops'),
      text: AppLocalizations.of(context)!.translate('sorrySthWentWrong'),
      onConfirmBtnTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              LoginScreen()
          ),
        );
      }
    );
  }
}