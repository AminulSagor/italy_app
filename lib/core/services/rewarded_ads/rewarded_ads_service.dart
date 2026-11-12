import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../models/rewarded_ads_models.dart';
import '../api_client.dart';

class RewardedAdsService extends GetxService {
  // Keep the public dependency name consistent with the other GetX services.
  // ignore: prefer_initializing_formals
  RewardedAdsService({
    ApiClient? apiClient,
    Dio? dio,
    bool? releaseModeOverride,
    Future<void> Function(Duration duration)? delay,
    Future<RewardedAd?> Function()? adLoader,
  }) : assert(apiClient != null || dio != null),
       _dio = dio ?? apiClient!.dio,
       _releaseMode = releaseModeOverride ?? kReleaseMode,
       _delay = delay ?? Future<void>.delayed,
       _adLoaderOverride = adLoader;

  static const String _androidTestId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestId = 'ca-app-pub-3940256099942544/1712485313';
  static const String _androidId = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID_ID',
    defaultValue: _androidTestId,
  );
  static const String _iosId = String.fromEnvironment(
    'ADMOB_REWARDED_IOS_ID',
    defaultValue: _iosTestId,
  );

  final Dio _dio;
  final bool _releaseMode;
  final Future<void> Function(Duration duration) _delay;
  final Future<RewardedAd?> Function()? _adLoaderOverride;
  final Rxn<RewardedAdsConfiguration> configuration =
      Rxn<RewardedAdsConfiguration>();
  final Rx<RewardedGateFailure> lastGateFailure = RewardedGateFailure.none.obs;
  final Set<String> _locallyEarnedSessions = <String>{};
  bool _gateInFlight = false;
  bool _showing = false;

  Future<RewardedAdsService> init() async {
    final String platformAdUnitId = Platform.isIOS ? _iosId : _androidId;
    final String platformTestId = Platform.isIOS ? _iosTestId : _androidTestId;
    if (_releaseMode && platformAdUnitId == platformTestId) {
      throw StateError(
        'Release builds require production rewarded ad unit IDs supplied with --dart-define.',
      );
    }
    await MobileAds.instance.initialize();
    return this;
  }

  Future<RewardedAdsConfiguration?> refreshConfiguration() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/rewarded-ads/config',
      );
      final data = response.data;
      if (data == null) return configuration.value;
      final parsed = RewardedAdsConfiguration.fromJson(data);
      configuration.value = parsed;
      return parsed;
    } catch (_) {
      return configuration.value;
    }
  }

  Future<bool> gate(RewardedPlacement placement, {String? contextId}) async {
    if (_gateInFlight) return false;
    _gateInFlight = true;
    try {
      return await _gateInternal(placement, contextId: contextId);
    } finally {
      _gateInFlight = false;
    }
  }

  Future<bool> _gateInternal(
    RewardedPlacement placement, {
    String? contextId,
  }) async {
    lastGateFailure.value = RewardedGateFailure.none;
    if (_showing) return false;
    final config = await refreshConfiguration();
    final bool grantsCurrency =
        placement == RewardedPlacement.callCredits ||
        placement == RewardedPlacement.cvCredits ||
        placement == RewardedPlacement.dailyChallengeXp;
    if (config == null) {
      lastGateFailure.value = RewardedGateFailure.verificationFailed;
      return false;
    }
    if (!config.adsEnabled || config.isAdFree) return !grantsCurrency;

    Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        '/rewarded-ads/sessions',
        data: <String, dynamic>{
          'placement': placement.apiValue,
          'contextId': ?contextId,
        },
      );
    } on DioException catch (error) {
      debugPrint(
        'Rewarded session request failed: status=${error.response?.statusCode}',
      );
      lastGateFailure.value = RewardedGateFailure.verificationFailed;
      return false;
    }
    final data = response.data ?? const <String, dynamic>{};
    if (data['required'] != true) return true;
    final sessionId = data['sessionId']?.toString();
    if (sessionId == null || sessionId.isEmpty) return false;
    if (data['verificationPending'] == true ||
        (data['resumed'] == true &&
            _locallyEarnedSessions.contains(sessionId))) {
      final result = await _pollSession(sessionId);
      return _acceptVerificationResult(result, sessionId);
    }
    return _show(sessionId);
  }

  Future<bool> ensureOutgoingCallCredit() async {
    final config = await refreshConfiguration();
    if (config == null) return true;
    if (!config.callLimitEnabled) return true;
    if (config.callFreeRemaining > 0 || config.callCredits > 0) return true;
    if (config.isAdFree) return false;
    return gate(RewardedPlacement.callCredits);
  }

  Future<bool> _show(String sessionId) async {
    _showing = true;
    try {
      final ad = await _loadAd();
      if (ad == null) {
        lastGateFailure.value = RewardedGateFailure.adUnavailable;
        await _cancelSession(sessionId);
        return false;
      }
      ad.setServerSideOptions(
        ServerSideVerificationOptions(customData: sessionId),
      );
      final completer = Completer<bool>();
      bool earned = false;
      Future<void>? earnedNotification;
      ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
        onAdShowedFullScreenContent: (_) {
          unawaited(_notifyLifecycle(sessionId, 'shown'));
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          unawaited(() async {
            try {
              if (!earned) {
                lastGateFailure.value = RewardedGateFailure.canceled;
                await _cancelSession(sessionId);
                if (!completer.isCompleted) completer.complete(false);
                return;
              }
              await earnedNotification;
              final result = await _confirmReward(sessionId);
              if (!completer.isCompleted) {
                completer.complete(
                  _acceptVerificationResult(result, sessionId),
                );
              }
            } catch (error) {
              debugPrint('Rewarded dismissal handling failed: $error');
              lastGateFailure.value = RewardedGateFailure.verificationFailed;
              if (!completer.isCompleted) completer.complete(false);
            }
          }());
        },
        onAdFailedToShowFullScreenContent: (ad, _) {
          ad.dispose();
          lastGateFailure.value = RewardedGateFailure.adUnavailable;
          unawaited(() async {
            await _cancelSession(sessionId);
            if (!completer.isCompleted) completer.complete(false);
          }());
        },
      );
      ad.show(
        onUserEarnedReward: (_, _) {
          earned = true;
          _locallyEarnedSessions.add(sessionId);
          earnedNotification = _notifyLifecycle(sessionId, 'earned');
        },
      );
      return completer.future.timeout(
        const Duration(seconds: 75),
        onTimeout: () {
          lastGateFailure.value = RewardedGateFailure.verificationPending;
          return false;
        },
      );
    } finally {
      _showing = false;
    }
  }

  Future<RewardedAd?> _loadAd() {
    final override = _adLoaderOverride;
    if (override != null) return override();
    final completer = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: Platform.isIOS ? _iosId : _androidId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: completer.complete,
        onAdFailedToLoad: (_) => completer.complete(null),
      ),
    );
    return completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () => null,
    );
  }

  Future<RewardedVerificationResult> _confirmReward(String sessionId) async {
    if (!_releaseMode) {
      try {
        final response = await _dio.post<Map<String, dynamic>>(
          '/rewarded-ads/sessions/$sessionId/complete-test',
        );
        if (response.data?['granted'] == true) {
          await refreshConfiguration();
          return RewardedVerificationResult.granted;
        }
        return RewardedVerificationResult.pending;
      } on DioException catch (error) {
        debugPrint(
          'Development reward confirmation failed: status=${error.response?.statusCode}',
        );
        return error.response?.statusCode == 403
            ? RewardedVerificationResult.rejected
            : RewardedVerificationResult.pending;
      }
    }
    return _pollSession(sessionId);
  }

  Future<RewardedVerificationResult> _pollSession(
    String sessionId, {
    int attempts = 15,
  }) async {
    for (int attempt = 0; attempt < attempts; attempt++) {
      if (attempt > 0) await _delay(const Duration(seconds: 2));
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          '/rewarded-ads/sessions/$sessionId',
        );
        final data = response.data ?? const <String, dynamic>{};
        if (data['granted'] == true) {
          await refreshConfiguration();
          return RewardedVerificationResult.granted;
        }
        switch (data['status']?.toString()) {
          case 'expired':
            return RewardedVerificationResult.expired;
          case 'canceled':
            return RewardedVerificationResult.canceled;
        }
      } on DioException catch (error) {
        debugPrint(
          'Reward verification poll failed: status=${error.response?.statusCode}',
        );
      }
    }
    return RewardedVerificationResult.pending;
  }

  bool _acceptVerificationResult(
    RewardedVerificationResult result,
    String sessionId,
  ) {
    switch (result) {
      case RewardedVerificationResult.granted:
        _locallyEarnedSessions.remove(sessionId);
        lastGateFailure.value = RewardedGateFailure.none;
        return true;
      case RewardedVerificationResult.pending:
        lastGateFailure.value = RewardedGateFailure.verificationPending;
        return false;
      case RewardedVerificationResult.rejected:
        lastGateFailure.value = RewardedGateFailure.verificationRejected;
        return false;
      case RewardedVerificationResult.canceled:
        lastGateFailure.value = RewardedGateFailure.canceled;
        return false;
      case RewardedVerificationResult.expired:
      case RewardedVerificationResult.failed:
        lastGateFailure.value = RewardedGateFailure.verificationFailed;
        return false;
    }
  }

  Future<void> _notifyLifecycle(String sessionId, String event) async {
    try {
      await _dio.post<void>('/rewarded-ads/sessions/$sessionId/$event');
    } on DioException catch (error) {
      debugPrint(
        'Rewarded lifecycle $event failed: status=${error.response?.statusCode}',
      );
    }
  }

  Future<void> _cancelSession(String sessionId) => _notifyLifecycle(
    sessionId,
    'cancel',
  ).whenComplete(() => _locallyEarnedSessions.remove(sessionId));

  @visibleForTesting
  Future<RewardedVerificationResult> confirmRewardForTesting(
    String sessionId,
  ) => _confirmReward(sessionId);

  @visibleForTesting
  Future<RewardedVerificationResult> pollSessionForTesting(
    String sessionId, {
    int attempts = 1,
  }) => _pollSession(sessionId, attempts: attempts);
}
