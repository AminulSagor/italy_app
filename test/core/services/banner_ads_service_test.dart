import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/core/models/rewarded_ads_models.dart';
import 'package:italir_pothe/core/services/banner_ads/banner_ads_service.dart';

RewardedAdsConfiguration _configuration({
  required bool adsEnabled,
  required bool isAdFree,
}) {
  return RewardedAdsConfiguration(
    adsEnabled: adsEnabled,
    isAdFree: isAdFree,
    dailyChallengeRemaining: 0,
    dailyChallengeXp: 0,
    callLimitEnabled: false,
    callFreeRemaining: 0,
    callCredits: 0,
  );
}

void main() {
  test('uses the official Android and iOS banner test IDs', () {
    expect(
      BannerAdsService.androidTestAdUnitId,
      'ca-app-pub-3940256099942544/6300978111',
    );
    expect(
      BannerAdsService.iosTestAdUnitId,
      'ca-app-pub-3940256099942544/2934735716',
    );
  });

  test('waits for confirmed eligibility and excludes ad-free users', () {
    expect(BannerAdsService.canRequest(null), isFalse);
    expect(
      BannerAdsService.canRequest(
        _configuration(adsEnabled: false, isAdFree: false),
      ),
      isFalse,
    );
    expect(
      BannerAdsService.canRequest(
        _configuration(adsEnabled: true, isAdFree: true),
      ),
      isFalse,
    );
    expect(
      BannerAdsService.canRequest(
        _configuration(adsEnabled: true, isAdFree: false),
      ),
      isTrue,
    );
  });

  test('quiz banner requires a full banner allowance below content', () {
    expect(
      BannerAdsService.hasSufficientLayoutSpace(
        viewportHeight: 800,
        bottomReserve: 150,
        contentHeight: 500,
        bannerAllowance: 100,
      ),
      isTrue,
    );
    expect(
      BannerAdsService.hasSufficientLayoutSpace(
        viewportHeight: 700,
        bottomReserve: 150,
        contentHeight: 500,
        bannerAllowance: 100,
      ),
      isFalse,
    );
  });
}
