import 'dart:io';

import 'package:flutter/foundation.dart';

abstract final class MobileAdsConfiguration {
  static const String androidRewardedId = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID_ID',
  );
  static const String androidBannerId = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID_ID',
  );
  static const String androidNativeId = String.fromEnvironment(
    'ADMOB_NATIVE_ANDROID_ID',
  );

  static const String iosRewardedId = String.fromEnvironment(
    'ADMOB_REWARDED_IOS_ID',
  );
  static const String iosBannerId = String.fromEnvironment(
    'ADMOB_BANNER_IOS_ID',
  );
  static const String iosNativeId = String.fromEnvironment(
    'ADMOB_NATIVE_IOS_ID',
  );

  static const String androidRewardedTestId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String androidBannerTestId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String androidNativeTestId =
      'ca-app-pub-3940256099942544/2247696110';
  static const String iosRewardedTestId =
      'ca-app-pub-3940256099942544/1712485313';
  static const String iosBannerTestId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String iosNativeTestId =
      'ca-app-pub-3940256099942544/3986624511';

  static String get rewardedAdUnitId => _unitId(
    androidProduction: androidRewardedId,
    iosProduction: iosRewardedId,
    androidTest: androidRewardedTestId,
    iosTest: iosRewardedTestId,
  );

  static String? get bannerAdUnitId => _optionalReleaseUnitId(
    androidProduction: androidBannerId,
    iosProduction: iosBannerId,
    androidTest: androidBannerTestId,
    iosTest: iosBannerTestId,
  );

  static String? get nativeAdUnitId => _optionalReleaseUnitId(
    androidProduction: androidNativeId,
    iosProduction: iosNativeId,
    androidTest: androidNativeTestId,
    iosTest: iosNativeTestId,
  );

  static void validateForCurrentPlatform({bool releaseMode = kReleaseMode}) {
    if (!releaseMode) return;

    final Map<String, String> values = Platform.isAndroid
        ? <String, String>{
            'ADMOB_REWARDED_ANDROID_ID': androidRewardedId,
            'ADMOB_BANNER_ANDROID_ID': androidBannerId,
            'ADMOB_NATIVE_ANDROID_ID': androidNativeId,
          }
        : <String, String>{
            'ADMOB_REWARDED_IOS_ID': iosRewardedId,
            'ADMOB_BANNER_IOS_ID': iosBannerId,
            'ADMOB_NATIVE_IOS_ID': iosNativeId,
          };
    final Set<String> testIds = Platform.isAndroid
        ? <String>{
            androidRewardedTestId,
            androidBannerTestId,
            androidNativeTestId,
          }
        : <String>{iosRewardedTestId, iosBannerTestId, iosNativeTestId};

    final List<String> invalid = values.entries
        .where(
          (MapEntry<String, String> entry) =>
              !_isAdUnitId(entry.value) || testIds.contains(entry.value.trim()),
        )
        .map((MapEntry<String, String> entry) => entry.key)
        .toList(growable: false);
    if (invalid.isNotEmpty) {
      throw StateError(
        'Release advertising configuration is missing or invalid: '
        '${invalid.join(', ')}. Supply production values with --dart-define.',
      );
    }
  }

  static String _unitId({
    required String androidProduction,
    required String iosProduction,
    required String androidTest,
    required String iosTest,
  }) {
    if (!kReleaseMode) return Platform.isIOS ? iosTest : androidTest;
    return Platform.isIOS ? iosProduction.trim() : androidProduction.trim();
  }

  static String? _optionalReleaseUnitId({
    required String androidProduction,
    required String iosProduction,
    required String androidTest,
    required String iosTest,
  }) {
    final String value = _unitId(
      androidProduction: androidProduction,
      iosProduction: iosProduction,
      androidTest: androidTest,
      iosTest: iosTest,
    );
    return value.isEmpty ? null : value;
  }

  static bool _isAdUnitId(String value) =>
      RegExp(r'^ca-app-pub-\d+/\d+$').hasMatch(value.trim());
}
