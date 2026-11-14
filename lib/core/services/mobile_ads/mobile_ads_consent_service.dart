import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../config/mobile_advertising_policy.dart';
import '../../config/mobile_ads_configuration.dart';

class MobileAdsConsentService extends GetxService {
  final RxBool canRequestAds = false.obs;
  final RxBool privacyOptionsRequired = false.obs;
  final RxnString lastError = RxnString();

  Future<MobileAdsConsentService>? _initialization;
  bool _sdkInitialized = false;

  Future<MobileAdsConsentService> init() => _initialization ??= _initialize();

  Future<MobileAdsConsentService> _initialize() async {
    if (!MobileAdvertisingPolicy.enabled) return this;

    MobileAdsConfiguration.validateForCurrentPlatform();
    try {
      await _requestConsentUpdate();
    } catch (error, stackTrace) {
      lastError.value = 'Unable to update mobile ads consent information.';
      debugPrint('${lastError.value}: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    await _refreshConsentState();
    await _initializeSdkIfAllowed();
    return this;
  }

  Future<bool> showPrivacyOptions() async {
    if (!MobileAdvertisingPolicy.enabled || !privacyOptionsRequired.value) {
      return canRequestAds.value;
    }

    final Completer<void> completer = Completer<void>();
    try {
      await ConsentForm.showPrivacyOptionsForm((FormError? error) {
        if (error != null) _recordError('Privacy options form', error);
        if (!completer.isCompleted) completer.complete();
      });
    } catch (error, stackTrace) {
      lastError.value = 'Unable to show advertising privacy options.';
      debugPrint('${lastError.value}: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!completer.isCompleted) completer.complete();
    }
    await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        lastError.value = 'Advertising privacy options timed out.';
      },
    );
    await _refreshConsentState();
    await _initializeSdkIfAllowed();
    return canRequestAds.value;
  }

  Future<void> _requestConsentUpdate() async {
    final Completer<bool> update = Completer<bool>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        if (!update.isCompleted) update.complete(true);
      },
      (FormError error) {
        _recordError('Consent information update', error);
        if (!update.isCompleted) update.complete(false);
      },
    );

    final bool updated = await update.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        lastError.value = 'Consent information update timed out.';
        return false;
      },
    );
    if (!updated) return;

    final Completer<void> form = Completer<void>();
    await ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
      if (error != null) _recordError('Consent form', error);
      if (!form.isCompleted) form.complete();
    });
    await form.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        lastError.value = 'Consent form timed out.';
      },
    );
  }

  Future<void> _refreshConsentState() async {
    try {
      canRequestAds.value = await ConsentInformation.instance.canRequestAds();
      privacyOptionsRequired.value =
          await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (error, stackTrace) {
      canRequestAds.value = false;
      debugPrint('Unable to read mobile ads consent state: $error');
      debugPrintStack(stackTrace: stackTrace);
      lastError.value = 'Unable to read mobile ads consent state.';
    }
  }

  Future<void> _initializeSdkIfAllowed() async {
    if (_sdkInitialized || !canRequestAds.value) return;
    try {
      await MobileAds.instance.initialize();
      _sdkInitialized = true;
    } catch (error, stackTrace) {
      canRequestAds.value = false;
      lastError.value = 'Unable to initialize Google Mobile Ads.';
      debugPrint('${lastError.value}: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _recordError(String operation, FormError error) {
    lastError.value = '$operation failed: ${error.message}';
    debugPrint(lastError.value);
  }
}
