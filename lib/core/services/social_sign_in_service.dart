import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../utils/app_logger.dart';

class SocialSignInException implements Exception {
  const SocialSignInException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SocialProviderCredential {
  const SocialProviderCredential({
    required this.token,
    this.tokenType,
    this.nonce,
    this.displayName,
    this.authorizationCode,
  });

  final String token;
  final String? tokenType;
  final String? nonce;
  final String? displayName;
  final String? authorizationCode;
}

class SocialSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleInitialization;
  bool _googleSignInInProgress = false;

  Future<SocialProviderCredential?> getGoogleCredential() async {
    if (_googleSignInInProgress) return null;

    final String serverClientId =
        dotenv.env['GOOGLE_SERVER_CLIENT_ID']?.trim() ?? '';
    if (serverClientId.isEmpty) {
      throw const SocialSignInException(
        'Google Sign-In is not configured for this build.',
      );
    }

    final String iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID']?.trim() ?? '';
    _googleSignInInProgress = true;
    try {
      await _ensureGoogleInitialized(
        serverClientId: serverClientId,
        iosClientId: iosClientId,
      );
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: const <String>['email', 'profile'],
      );
      final String idToken = account.authentication.idToken?.trim() ?? '';
      if (idToken.isEmpty) {
        await _googleSignIn.signOut();
        throw const SocialSignInException(
          'Google did not return a valid identity token.',
        );
      }
      return SocialProviderCredential(token: idToken);
    } on GoogleSignInException catch (error, stackTrace) {
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      await _reportHandledSocialFailure(
        provider: 'Google',
        error: error,
        stackTrace: stackTrace,
      );
      throw const SocialSignInException(
        'Google Sign-In could not be completed.',
      );
    } on PlatformException catch (error, stackTrace) {
      final String code = error.code.toLowerCase();
      if (code.contains('cancel')) return null;
      await _reportHandledSocialFailure(
        provider: 'Google',
        error: error,
        stackTrace: stackTrace,
      );
      throw const SocialSignInException(
        'Google Sign-In could not be completed.',
      );
    } finally {
      _googleSignInInProgress = false;
    }
  }

  Future<void> _ensureGoogleInitialized({
    required String serverClientId,
    required String iosClientId,
  }) async {
    final Future<void>? existing = _googleInitialization;
    if (existing != null) {
      await existing;
      return;
    }

    final Future<void> initialization = _googleSignIn.initialize(
      serverClientId: serverClientId,
      clientId: Platform.isIOS && iosClientId.isNotEmpty ? iosClientId : null,
    );
    _googleInitialization = initialization;
    try {
      await initialization;
    } catch (_) {
      _googleInitialization = null;
      rethrow;
    }
  }

  Future<void> _reportHandledSocialFailure({
    required String provider,
    required Object error,
    required StackTrace stackTrace,
  }) async {
    AppLogger.log(
      '$provider Sign-In request failed',
      name: 'SocialSignIn',
      error: error,
      stackTrace: stackTrace,
    );
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Handled $provider Sign-In failure',
        fatal: false,
      );
    } catch (_) {
      // Reporting must never turn an authentication failure fatal.
    }
  }

  Future<SocialProviderCredential?> getFacebookCredential() async {
    late final LoginResult result;
    try {
      result = await FacebookAuth.instance.login(
        permissions: const <String>['email', 'public_profile'],
        // Meta Android SDK 18.x can throw ActivityNotFoundException while
        // handing native login to a stale/unavailable Facebook ProxyAuth
        // activity. That native exception terminates the process before its
        // advertised web fallback can run, so Android must start with the
        // reliable web/custom-tab handler instead.
        loginBehavior: Platform.isAndroid
            ? LoginBehavior.webOnly
            : LoginBehavior.nativeWithFallback,
        loginTracking: Platform.isIOS
            ? LoginTracking.limited
            : LoginTracking.enabled,
      );
    } on PlatformException catch (error, stackTrace) {
      AppLogger.log(
        'Facebook Login platform request failed (${error.code})',
        name: 'SocialSignIn',
        error: error.message,
        stackTrace: stackTrace,
      );
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Handled Facebook Login platform failure',
          fatal: false,
        );
      } catch (_) {
        // Crash reporting must never turn an authentication failure fatal.
      }
      throw const SocialSignInException(
        'Facebook Login could not be completed.',
      );
    }

    if (result.status == LoginStatus.cancelled) return null;
    if (result.status != LoginStatus.success || result.accessToken == null) {
      throw SocialSignInException(
        result.message?.trim().isNotEmpty == true
            ? result.message!.trim()
            : 'Facebook Login could not be completed.',
      );
    }

    final AccessToken accessToken = result.accessToken!;
    final String token = accessToken.tokenString.trim();
    if (token.isEmpty) {
      throw const SocialSignInException(
        'Facebook did not return a valid access token.',
      );
    }
    return SocialProviderCredential(
      token: token,
      tokenType: accessToken.type.name,
      nonce: accessToken is LimitedToken ? accessToken.nonce : null,
    );
  }

  Future<SocialProviderCredential?> getAppleCredential() async {
    if (!Platform.isIOS) {
      throw const SocialSignInException(
        'Sign in with Apple is only available on iOS in this app.',
      );
    }

    if (!await SignInWithApple.isAvailable()) {
      throw const SocialSignInException(
        'Sign in with Apple is not available on this device.',
      );
    }

    final String rawNonce = _generateSecureNonce();
    final String hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    try {
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
            scopes: const <AppleIDAuthorizationScopes>[
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            nonce: hashedNonce,
          );

      final String identityToken = credential.identityToken?.trim() ?? '';
      if (identityToken.isEmpty) {
        throw const SocialSignInException(
          'Apple did not return a valid identity token.',
        );
      }

      final String displayName =
          <String?>[credential.givenName, credential.familyName]
              .whereType<String>()
              .map((String value) => value.trim())
              .where((String value) => value.isNotEmpty)
              .join(' ');

      return SocialProviderCredential(
        token: identityToken,
        nonce: rawNonce,
        displayName: displayName.isEmpty ? null : displayName,
        authorizationCode: credential.authorizationCode.trim(),
      );
    } on SignInWithAppleAuthorizationException catch (error, stackTrace) {
      if (error.code == AuthorizationErrorCode.canceled) return null;

      AppLogger.log(
        'Sign in with Apple authorization failed (${error.code.name})',
        name: 'SocialSignIn',
        error: error.message,
        stackTrace: stackTrace,
      );
      throw const SocialSignInException(
        'Sign in with Apple could not be completed.',
      );
    } on PlatformException catch (error, stackTrace) {
      AppLogger.log(
        'Sign in with Apple platform request failed (${error.code})',
        name: 'SocialSignIn',
        error: error.message,
        stackTrace: stackTrace,
      );
      throw const SocialSignInException(
        'Sign in with Apple could not be completed.',
      );
    }
  }

  String _generateSecureNonce([int length = 32]) {
    const String characters =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final Random random = Random.secure();
    return List<String>.generate(
      length,
      (_) => characters[random.nextInt(characters.length)],
      growable: false,
    ).join();
  }
}
