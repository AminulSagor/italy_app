import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../config/mobile_advertising_policy.dart';
import '../../config/mobile_ads_configuration.dart';
import '../../models/rewarded_ads_models.dart';
import '../../widgets/ads/rewarded_ad_opt_in_dialog.dart';
import '../../widgets/ads/rewarded_ad_progress_overlay.dart';
import '../api_client.dart';
import '../mobile_ads/mobile_ads_consent_service.dart';

class RewardedAdsService extends GetxService {
  // Keep the public dependency name consistent with the other GetX services.
  // ignore: prefer_initializing_formals
  RewardedAdsService({
    ApiClient? apiClient,
    Dio? dio,
    bool? releaseModeOverride,
    Future<void> Function(Duration duration)? delay,
    Future<RewardedAd?> Function()? adLoader,
    MobileAdsConsentService? mobileAdsConsentService,
  }) : assert(apiClient != null || dio != null),
       _dio = dio ?? apiClient!.dio,
       _releaseMode = releaseModeOverride ?? kReleaseMode,
       _delay = delay ?? Future<void>.delayed,
       _adLoaderOverride = adLoader,
       // Keep the public constructor parameter name stable for bindings/tests.
       // ignore: prefer_initializing_formals
       _mobileAdsConsentService = mobileAdsConsentService;

  final Dio _dio;
  final bool _releaseMode;
  final Future<void> Function(Duration duration) _delay;
  final Future<RewardedAd?> Function()? _adLoaderOverride;
  final MobileAdsConsentService? _mobileAdsConsentService;
  final Rxn<RewardedAdsConfiguration> configuration =
      Rxn<RewardedAdsConfiguration>();
  final Rx<RewardedGateFailure> lastGateFailure = RewardedGateFailure.none.obs;
  final Set<String> _locallyEarnedSessions = <String>{};
  static const Duration _rewardedAdCacheLifetime = Duration(minutes: 55);
  RewardedAd? _cachedRewardedAd;
  DateTime? _cachedRewardedAdLoadedAt;
  Future<void>? _rewardedAdPreloadFuture;
  Timer? _rewardedAdExpiryTimer;
  Timer? _rewardedAdRetryTimer;
  int _rewardedAdRetryAttempt = 0;
  bool _gateInFlight = false;
  bool _showing = false;
  bool _isClosed = false;
  bool _mobileAdsReady = false;

  Future<RewardedAdsService> init() async {
    if (!MobileAdvertisingPolicy.enabled) return this;

    final MobileAdsConsentService? consent = _mobileAdsConsentService;
    if (consent != null) {
      await consent.init();
      _mobileAdsReady = consent.canRequestAds.value;
    } else {
      MobileAdsConfiguration.validateForCurrentPlatform(
        releaseMode: _releaseMode,
      );
      await MobileAds.instance.initialize();
      _mobileAdsReady = true;
    }
    unawaited(_warmUpRewardedAd());
    return this;
  }

  Future<RewardedAdsConfiguration?> refreshConfiguration() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/rewarded-ads/config',
      );
      final data = response.data;
      if (data == null) return configuration.value;
      final backendConfiguration = RewardedAdsConfiguration.fromJson(data);
      final bool advertisingAllowed =
          MobileAdvertisingPolicy.enabled &&
          (_mobileAdsConsentService?.canRequestAds.value ?? true);
      final parsed = advertisingAllowed
          ? backendConfiguration
          : RewardedAdsConfiguration(
              adsEnabled: false,
              isAdFree: backendConfiguration.isAdFree,
              dailyChallengeRemaining:
                  backendConfiguration.dailyChallengeRemaining,
              dailyChallengeXp: backendConfiguration.dailyChallengeXp,
              callLimitEnabled: backendConfiguration.callLimitEnabled,
              callFreeRemaining: backendConfiguration.callFreeRemaining,
              callCredits: backendConfiguration.callCredits,
              callCreditsPerAd: backendConfiguration.callCreditsPerAd,
              cvCreditsPerAd: backendConfiguration.cvCreditsPerAd,
              nativeAds: backendConfiguration.nativeAds,
            );
      configuration.value = parsed;
      _syncRewardedAdCacheEligibility(parsed);
      return parsed;
    } catch (_) {
      return configuration.value;
    }
  }

  Future<bool> gate(
    RewardedPlacement placement, {
    String? contextId,
    required String rewardDescription,
  }) async {
    if (_gateInFlight) return false;
    _gateInFlight = true;
    try {
      return await _gateInternal(
        placement,
        contextId: contextId,
        rewardDescription: rewardDescription,
      );
    } finally {
      _gateInFlight = false;
    }
  }

  Future<bool> _gateInternal(
    RewardedPlacement placement, {
    String? contextId,
    required String rewardDescription,
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
      final result = await _pollSessionWithProgress(sessionId);
      return _acceptVerificationResult(result, sessionId);
    }
    final String? ssvUserId = data['ssvUserId']?.toString();
    if (ssvUserId == null || ssvUserId.isEmpty) {
      lastGateFailure.value = RewardedGateFailure.verificationFailed;
      await _cancelSession(sessionId);
      return false;
    }
    final bool accepted = await RewardedAdOptInDialog.show(
      rewardDescription: rewardDescription,
    );
    if (!accepted) {
      lastGateFailure.value = RewardedGateFailure.canceled;
      await _cancelSession(sessionId);
      return false;
    }
    return _show(sessionId, ssvUserId);
  }

  Future<bool> ensureOutgoingCallCredit() async {
    final config = await refreshConfiguration();
    if (config == null) return true;
    if (!config.callLimitEnabled) return true;
    if (config.callFreeRemaining > 0 || config.callCredits > 0) return true;
    if (config.isAdFree) return false;
    return gate(
      RewardedPlacement.callCredits,
      rewardDescription: 'rewarded_reward_call_credits'.trParams(
        <String, String>{'count': config.callCreditsPerAd.toString()},
      ),
    );
  }

  Future<bool> _show(String sessionId, String ssvUserId) async {
    _showing = true;
    try {
      final bool wasReady = _hasFreshCachedRewardedAd;
      final RewardedAdProgressOverlay? loadingOverlay = wasReady
          ? null
          : RewardedAdProgressOverlay.show(
              context: Get.overlayContext,
              title: 'rewarded_ad_preparing_title'.tr,
              message: 'rewarded_ad_preparing_message'.tr,
            );
      final RewardedAd? ad;
      try {
        ad = await _takeOrLoadRewardedAd();
      } finally {
        loadingOverlay?.dismiss();
      }
      if (ad == null) {
        lastGateFailure.value = RewardedGateFailure.adUnavailable;
        await _cancelSession(sessionId);
        _showAdUnavailableMessage();
        return false;
      }
      ad.setServerSideOptions(
        ServerSideVerificationOptions(customData: sessionId, userId: ssvUserId),
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
          unawaited(_preloadRewardedAd());
          unawaited(() async {
            try {
              if (!earned) {
                lastGateFailure.value = RewardedGateFailure.canceled;
                await _cancelSession(sessionId);
                if (!completer.isCompleted) completer.complete(false);
                return;
              }
              await earnedNotification;
              final RewardedVerificationResult result =
                  await _confirmRewardWithProgress(sessionId);
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
          unawaited(_preloadRewardedAd());
          lastGateFailure.value = RewardedGateFailure.adUnavailable;
          _showAdUnavailableMessage();
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
        const Duration(minutes: 5),
        onTimeout: () {
          lastGateFailure.value = RewardedGateFailure.verificationPending;
          return false;
        },
      );
    } finally {
      _showing = false;
    }
  }

  Future<RewardedAd?> _takeOrLoadRewardedAd() async {
    final override = _adLoaderOverride;
    if (override != null) return override();

    _discardExpiredRewardedAd();
    RewardedAd? ad = _cachedRewardedAd;
    if (ad != null) {
      _rewardedAdExpiryTimer?.cancel();
      _rewardedAdExpiryTimer = null;
      _cachedRewardedAd = null;
      _cachedRewardedAdLoadedAt = null;
      return ad;
    }

    await _preloadRewardedAd();
    ad = _cachedRewardedAd;
    _rewardedAdExpiryTimer?.cancel();
    _rewardedAdExpiryTimer = null;
    _cachedRewardedAd = null;
    _cachedRewardedAdLoadedAt = null;
    return ad;
  }

  Future<void> _preloadRewardedAd() {
    if (_adLoaderOverride != null ||
        _isClosed ||
        !_isRewardedAdEligible ||
        _hasFreshCachedRewardedAd) {
      return Future<void>.value();
    }
    final Future<void>? activeLoad = _rewardedAdPreloadFuture;
    if (activeLoad != null) return activeLoad;

    final Future<void> load = _loadFreshRewardedAd().then((RewardedAd? ad) {
      if (ad == null) {
        _scheduleRewardedAdRetry();
        return;
      }
      if (_isClosed || !_isRewardedAdEligible) {
        ad.dispose();
        return;
      }
      _rewardedAdRetryTimer?.cancel();
      _rewardedAdRetryTimer = null;
      _rewardedAdRetryAttempt = 0;
      _cachedRewardedAd?.dispose();
      _cachedRewardedAd = ad;
      _cachedRewardedAdLoadedAt = DateTime.now();
      _scheduleRewardedAdRefresh();
    });
    _rewardedAdPreloadFuture = load;
    return load.whenComplete(() {
      if (identical(_rewardedAdPreloadFuture, load)) {
        _rewardedAdPreloadFuture = null;
      }
    });
  }

  Future<RewardedAd?> _loadFreshRewardedAd() {
    final completer = Completer<RewardedAd?>();
    final Timer timeout = Timer(const Duration(seconds: 20), () {
      if (!completer.isCompleted) completer.complete(null);
    });
    RewardedAd.load(
      adUnitId: MobileAdsConfiguration.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          if (completer.isCompleted) {
            ad.dispose();
          } else {
            timeout.cancel();
            completer.complete(ad);
          }
        },
        onAdFailedToLoad: (_) {
          if (!completer.isCompleted) {
            timeout.cancel();
            completer.complete(null);
          }
        },
      ),
    );
    return completer.future;
  }

  bool get _isRewardedAdEligible {
    final RewardedAdsConfiguration? config = configuration.value;
    final bool sdkReady =
        _mobileAdsReady ||
        (_mobileAdsConsentService?.canRequestAds.value ?? false);
    return sdkReady && config != null && config.adsEnabled && !config.isAdFree;
  }

  bool get _hasFreshCachedRewardedAd {
    _discardExpiredRewardedAd();
    return _cachedRewardedAd != null;
  }

  void _discardExpiredRewardedAd() {
    final DateTime? loadedAt = _cachedRewardedAdLoadedAt;
    if (_cachedRewardedAd == null || loadedAt == null) return;
    if (DateTime.now().difference(loadedAt) < _rewardedAdCacheLifetime) return;
    _cachedRewardedAd?.dispose();
    _cachedRewardedAd = null;
    _cachedRewardedAdLoadedAt = null;
    _rewardedAdExpiryTimer?.cancel();
    _rewardedAdExpiryTimer = null;
  }

  void _syncRewardedAdCacheEligibility(RewardedAdsConfiguration config) {
    if (config.adsEnabled && !config.isAdFree) {
      unawaited(_preloadRewardedAd());
      return;
    }
    _cachedRewardedAd?.dispose();
    _cachedRewardedAd = null;
    _cachedRewardedAdLoadedAt = null;
    _rewardedAdExpiryTimer?.cancel();
    _rewardedAdExpiryTimer = null;
    _rewardedAdRetryTimer?.cancel();
    _rewardedAdRetryTimer = null;
    _rewardedAdRetryAttempt = 0;
  }

  void _scheduleRewardedAdRefresh() {
    _rewardedAdExpiryTimer?.cancel();
    _rewardedAdExpiryTimer = Timer(_rewardedAdCacheLifetime, () {
      _rewardedAdExpiryTimer = null;
      _cachedRewardedAd?.dispose();
      _cachedRewardedAd = null;
      _cachedRewardedAdLoadedAt = null;
      unawaited(_preloadRewardedAd());
    });
  }

  void _scheduleRewardedAdRetry() {
    if (_isClosed || !_isRewardedAdEligible || _rewardedAdRetryTimer != null) {
      return;
    }
    const List<Duration> retryDelays = <Duration>[
      Duration(seconds: 30),
      Duration(minutes: 1),
      Duration(minutes: 2),
      Duration(minutes: 5),
    ];
    final int delayIndex = _rewardedAdRetryAttempt.clamp(
      0,
      retryDelays.length - 1,
    );
    _rewardedAdRetryAttempt += 1;
    _rewardedAdRetryTimer = Timer(retryDelays[delayIndex], () {
      _rewardedAdRetryTimer = null;
      unawaited(_preloadRewardedAd());
    });
  }

  Future<void> _warmUpRewardedAd() async {
    final RewardedAdsConfiguration? config = await refreshConfiguration();
    if (config != null && config.adsEnabled && !config.isAdFree) {
      await _preloadRewardedAd();
    }
  }

  Future<RewardedVerificationResult> _confirmRewardWithProgress(
    String sessionId,
  ) => _withVerificationProgress(() => _confirmReward(sessionId));

  Future<RewardedVerificationResult> _pollSessionWithProgress(
    String sessionId,
  ) => _withVerificationProgress(() => _pollSession(sessionId));

  Future<RewardedVerificationResult> _withVerificationProgress(
    Future<RewardedVerificationResult> Function() action,
  ) async {
    final RewardedAdProgressOverlay? overlay = RewardedAdProgressOverlay.show(
      context: Get.overlayContext,
      title: 'rewarded_ad_verifying_title'.tr,
      message: 'rewarded_ad_verifying_message'.tr,
    );
    try {
      return await action();
    } finally {
      overlay?.dismiss();
    }
  }

  void _showAdUnavailableMessage() {
    Get.snackbar(
      'rewarded_ad_unavailable_title'.tr,
      'rewarded_ad_unavailable_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
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
    int attempts = 30,
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

  @override
  void onClose() {
    _isClosed = true;
    _rewardedAdExpiryTimer?.cancel();
    _rewardedAdRetryTimer?.cancel();
    _cachedRewardedAd?.dispose();
    _cachedRewardedAd = null;
    _cachedRewardedAdLoadedAt = null;
    super.onClose();
  }

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
