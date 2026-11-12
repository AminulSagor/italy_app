import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/core/models/rewarded_ads_models.dart';
import 'package:italir_pothe/core/services/native_ads/native_ads_service.dart';

RewardedAdsConfiguration _configuration({
  bool adsEnabled = true,
  bool isAdFree = false,
  bool nativeEnabled = true,
  bool placementEnabled = true,
}) {
  return RewardedAdsConfiguration(
    adsEnabled: adsEnabled,
    isAdFree: isAdFree,
    dailyChallengeRemaining: 0,
    dailyChallengeXp: 0,
    callLimitEnabled: false,
    callFreeRemaining: 0,
    callCredits: 0,
    nativeAds: NativeAdsConfiguration(
      enabled: nativeEnabled,
      placements: <NativeAdPlacement, NativeAdPlacementConfiguration>{
        NativeAdPlacement.messages: NativeAdPlacementConfiguration(
          enabled: placementEnabled,
          firstAfter: 3,
          interval: 4,
        ),
      },
    ),
  );
}

void main() {
  test('uses the official Google native test ad unit IDs', () {
    expect(
      NativeAdsService.androidTestAdUnitId,
      'ca-app-pub-3940256099942544/2247696110',
    );
    expect(
      NativeAdsService.iosTestAdUnitId,
      'ca-app-pub-3940256099942544/3986624511',
    );
  });

  test('native eligibility fails closed and honors all ad-free switches', () {
    expect(
      NativeAdsService.canRequest(null, NativeAdPlacement.messages),
      isFalse,
    );
    expect(
      NativeAdsService.canRequest(
        _configuration(adsEnabled: false),
        NativeAdPlacement.messages,
      ),
      isFalse,
    );
    expect(
      NativeAdsService.canRequest(
        _configuration(isAdFree: true),
        NativeAdPlacement.messages,
      ),
      isFalse,
    );
    expect(
      NativeAdsService.canRequest(
        _configuration(nativeEnabled: false),
        NativeAdPlacement.messages,
      ),
      isFalse,
    );
    expect(
      NativeAdsService.canRequest(
        _configuration(placementEnabled: false),
        NativeAdPlacement.messages,
      ),
      isFalse,
    );
    expect(
      NativeAdsService.canRequest(_configuration(), NativeAdPlacement.messages),
      isTrue,
    );
  });

  test('insertion plan preserves content indexes and configured cadence', () {
    final NativeAdInsertionPlan plan = NativeAdInsertionPlan.build(
      contentCount: 12,
      firstAfter: 3,
      interval: 4,
    );

    expect(
      plan.rows
          .where((NativeAdDisplayRow row) => row.isAd)
          .map((NativeAdDisplayRow row) => row.adBoundary),
      <int>[3, 7, 11],
    );
    expect(
      plan.rows
          .where((NativeAdDisplayRow row) => !row.isAd)
          .map((NativeAdDisplayRow row) => row.contentIndex),
      List<int>.generate(12, (int index) => index),
    );
  });

  test('survival insertion completes the row containing item four', () {
    final int? gridBoundary = completeGridRowBoundary(
      firstAfter: 4,
      leadingItemCount: 1,
      gridItemCount: 8,
      columnCount: 2,
    );

    expect(gridBoundary, 4);
    expect(1 + gridBoundary!, 5);
  });
}
