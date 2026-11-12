enum RewardedPlacement {
  freeVideo('free_video'),
  dailyChallengeXp('daily_challenge_xp'),
  dailyChest('daily_chest'),
  careerModule('career_module'),
  quizOpen('quiz_open'),
  quizReview('quiz_review'),
  vocabularyReveal('vocabulary_reveal'),
  survivalPdf('survival_pdf'),
  verbDetail('verb_detail'),
  callCredits('call_credits'),
  cvCredits('cv_credits');

  const RewardedPlacement(this.apiValue);
  final String apiValue;
}

enum RewardedVerificationResult {
  granted,
  pending,
  rejected,
  expired,
  canceled,
  failed,
}

enum RewardedGateFailure {
  none,
  adUnavailable,
  canceled,
  verificationPending,
  verificationRejected,
  verificationFailed,
}

enum NativeAdPlacement {
  freeVideoProgress('freeVideoProgress'),
  freeVideoComplete('freeVideoComplete'),
  courseCatalog('courseCatalog'),
  practiceHub('practiceHub'),
  home('home'),
  courseDetail('courseDetail'),
  careerTracks('careerTracks'),
  aiTutorLanding('aiTutorLanding'),
  survivalItalian('survivalItalian'),
  careerTrackDetail('careerTrackDetail'),
  careerSentences('careerSentences'),
  importantVerbs('importantVerbs'),
  savedVerbs('savedVerbs'),
  verbDetail('verbDetail'),
  league('league'),
  messages('messages'),
  vocabulary('vocabulary');

  const NativeAdPlacement(this.apiValue);
  final String apiValue;
}

class NativeAdPlacementConfiguration {
  const NativeAdPlacementConfiguration({
    required this.enabled,
    this.firstAfter,
    this.interval,
    this.progressPercent,
  });

  final bool enabled;
  final int? firstAfter;
  final int? interval;
  final int? progressPercent;

  factory NativeAdPlacementConfiguration.fromJson(Map<String, dynamic> json) {
    int? positiveInteger(String key) {
      final int? value = (json[key] as num?)?.toInt();
      return value != null && value > 0 ? value : null;
    }

    return NativeAdPlacementConfiguration(
      enabled: json['enabled'] == true,
      firstAfter: positiveInteger('firstAfter'),
      interval: positiveInteger('interval'),
      progressPercent: positiveInteger('progressPercent'),
    );
  }
}

class NativeAdsConfiguration {
  const NativeAdsConfiguration({
    required this.enabled,
    required this.placements,
  });

  final bool enabled;
  final Map<NativeAdPlacement, NativeAdPlacementConfiguration> placements;

  NativeAdPlacementConfiguration? placement(NativeAdPlacement placement) =>
      placements[placement];

  factory NativeAdsConfiguration.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawPlacements = Map<String, dynamic>.from(
      json['placements'] as Map? ?? const {},
    );
    return NativeAdsConfiguration(
      enabled: json['enabled'] == true,
      placements: <NativeAdPlacement, NativeAdPlacementConfiguration>{
        for (final NativeAdPlacement placement in NativeAdPlacement.values)
          if (rawPlacements[placement.apiValue] is Map)
            placement: NativeAdPlacementConfiguration.fromJson(
              Map<String, dynamic>.from(
                rawPlacements[placement.apiValue] as Map,
              ),
            ),
      },
    );
  }
}

class RewardedAdsConfiguration {
  const RewardedAdsConfiguration({
    required this.adsEnabled,
    required this.isAdFree,
    required this.dailyChallengeRemaining,
    required this.dailyChallengeXp,
    required this.callLimitEnabled,
    required this.callFreeRemaining,
    required this.callCredits,
    this.nativeAds,
  });
  final bool adsEnabled;
  final bool isAdFree;
  final int dailyChallengeRemaining;
  final int dailyChallengeXp;
  final bool callLimitEnabled;
  final int callFreeRemaining;
  final int callCredits;
  final NativeAdsConfiguration? nativeAds;

  factory RewardedAdsConfiguration.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> daily = Map<String, dynamic>.from(
      json['dailyChallenge'] as Map? ?? const {},
    );
    final Map<String, dynamic> calls = Map<String, dynamic>.from(
      json['calls'] as Map? ?? const {},
    );
    return RewardedAdsConfiguration(
      adsEnabled: json['adsEnabled'] == true,
      isAdFree: json['isAdFree'] == true,
      dailyChallengeRemaining: (daily['remaining'] as num?)?.toInt() ?? 0,
      dailyChallengeXp: (daily['xp'] as num?)?.toInt() ?? 0,
      callLimitEnabled: calls['limitEnabled'] == true,
      callFreeRemaining: (calls['freeRemaining'] as num?)?.toInt() ?? 0,
      callCredits: (calls['credits'] as num?)?.toInt() ?? 0,
      nativeAds: json['nativeAds'] is Map
          ? NativeAdsConfiguration.fromJson(
              Map<String, dynamic>.from(json['nativeAds'] as Map),
            )
          : null,
    );
  }
}
