import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:linguome/entities/google_user.dart';
import 'package:linguome/services/auth_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../config/app_config.dart';

class AuthGoogleAppleService {

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS ? AppConfig.appleClientId : AppConfig
        .googleClientId,
  );
  final AuthService authService = AuthService();

  Future<void> handleSignInGoogle(BuildContext context,
      VoidCallback saveData,
      VoidCallback afterFetchWords,
      VoidCallback errorAlert) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn
          .signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount
            .authentication;

        final GoogleUser googleUser = GoogleUser(
          accessToken: googleSignInAuthentication.accessToken,
          email: googleSignInAccount.email,
          displayName: googleSignInAccount.displayName,
          photoUrl: googleSignInAccount.photoUrl,
        );

        await authService.authorizeOnServer(
            'google',
            googleUser,
            context,
            saveData,
            errorAlert
        );
      } else {
        print("Sign in cancelled or error occurred.");
      }
    } catch (error) {
      print('Error signing in with Google: $error');
    }
  }

  Future<void> handleSignInApple(BuildContext context,
      VoidCallback saveData,
      VoidCallback afterFetchWords,
      VoidCallback errorAlert) async {
    try {
      final result = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: AppConfig.authAppleClientId,
          redirectUri: Uri.parse(AppConfig.uriApple),
        ),
      );

      final GoogleUser googleUser = GoogleUser(
        accessToken: result.identityToken,
        email: result.email,
        displayName: '${result.givenName} ${result.familyName}',
        photoUrl: '',
      );

      await authService.authorizeOnServer(
          'apple',
          googleUser,
          context,
          saveData,
          errorAlert
      );
    } catch (error) {
      print('Error during sign in with Apple: $error');
    }
  }
}