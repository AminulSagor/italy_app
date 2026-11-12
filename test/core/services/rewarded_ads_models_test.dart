import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/core/models/rewarded_ads_models.dart';

void main() {
  test('parses server-authoritative rewarded configuration', () {
    final RewardedAdsConfiguration config = RewardedAdsConfiguration.fromJson(
      <String, dynamic>{
        'adsEnabled': true,
        'isAdFree': false,
        'dailyChallenge': <String, dynamic>{'remaining': 2, 'xp': 10},
        'calls': <String, dynamic>{
          'limitEnabled': true,
          'freeRemaining': 0,
          'credits': 3,
        },
      },
    );

    expect(config.adsEnabled, isTrue);
    expect(config.isAdFree, isFalse);
    expect(config.dailyChallengeRemaining, 2);
    expect(config.dailyChallengeXp, 10);
    expect(config.callLimitEnabled, isTrue);
    expect(config.callFreeRemaining, 0);
    expect(config.callCredits, 3);
  });

  test('uses stable backend placement identifiers', () {
    expect(RewardedPlacement.freeVideo.apiValue, 'free_video');
    expect(RewardedPlacement.quizReview.apiValue, 'quiz_review');
    expect(RewardedPlacement.callCredits.apiValue, 'call_credits');
    expect(RewardedPlacement.cvCredits.apiValue, 'cv_credits');
  });

  test('parses native ad placement controls from rewarded config', () {
    final RewardedAdsConfiguration config = RewardedAdsConfiguration.fromJson(
      <String, dynamic>{
        'adsEnabled': true,
        'isAdFree': false,
        'nativeAds': <String, dynamic>{
          'enabled': true,
          'placements': <String, dynamic>{
            'freeVideoProgress': <String, dynamic>{
              'enabled': true,
              'progressPercent': 60,
            },
            'messages': <String, dynamic>{
              'enabled': true,
              'firstAfter': 3,
              'interval': 4,
            },
          },
        },
      },
    );

    expect(config.nativeAds?.enabled, isTrue);
    expect(
      config.nativeAds
          ?.placement(NativeAdPlacement.freeVideoProgress)
          ?.progressPercent,
      60,
    );
    expect(
      config.nativeAds?.placement(NativeAdPlacement.messages)?.firstAfter,
      3,
    );
    expect(
      config.nativeAds?.placement(NativeAdPlacement.messages)?.interval,
      4,
    );
  });
}
