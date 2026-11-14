import 'dart:async';
// ignore_for_file: prefer_initializing_formals

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../config/mobile_ads_configuration.dart';
import '../../models/rewarded_ads_models.dart';
import '../rewarded_ads/rewarded_ads_service.dart';

class BannerAdsService extends GetxService {
  // Keep the public dependency name aligned with the bootstrap binding.
  BannerAdsService({required RewardedAdsService rewardedAdsService})
    : _rewardedAdsService = rewardedAdsService;

  static const String androidTestAdUnitId =
      MobileAdsConfiguration.androidBannerTestId;
  static const String iosTestAdUnitId = MobileAdsConfiguration.iosBannerTestId;

  final RewardedAdsService _rewardedAdsService;

  Rxn<RewardedAdsConfiguration> get configuration =>
      _rewardedAdsService.configuration;

  bool get canRequestBanner => canRequest(configuration.value);

  Future<RewardedAdsConfiguration?> refreshEligibility() =>
      _rewardedAdsService.refreshConfiguration();

  static bool canRequest(RewardedAdsConfiguration? configuration) {
    return configuration != null &&
        configuration.adsEnabled &&
        !configuration.isAdFree;
  }

  static bool hasSufficientLayoutSpace({
    required double viewportHeight,
    required double bottomReserve,
    required double contentHeight,
    required double bannerAllowance,
  }) {
    return viewportHeight - bottomReserve - contentHeight >= bannerAllowance;
  }

  String? get adUnitId => MobileAdsConfiguration.bannerAdUnitId;

  Future<AdSize?> adaptiveSize(int availableWidth) {
    if (availableWidth <= 0) return Future<AdSize?>.value(null);
    return AdSize.getLargeAnchoredAdaptiveBannerAdSize(availableWidth);
  }

  Future<BannerAd?> load({required AdSize size}) {
    final String? unitId = adUnitId;
    if (!canRequestBanner || unitId == null) {
      return Future<BannerAd?>.value(null);
    }

    final Completer<BannerAd?> completer = Completer<BannerAd?>();
    late final BannerAd banner;
    banner = BannerAd(
      adUnitId: unitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!completer.isCompleted) completer.complete(banner);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    banner.load();
    return completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        banner.dispose();
        return null;
      },
    );
  }
}
