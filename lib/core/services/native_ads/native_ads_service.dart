import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../models/rewarded_ads_models.dart';
import '../rewarded_ads/rewarded_ads_service.dart';

class NativeAdDisplayRow {
  const NativeAdDisplayRow.content(this.contentIndex) : adBoundary = null;
  const NativeAdDisplayRow.ad(this.adBoundary) : contentIndex = null;

  final int? contentIndex;
  final int? adBoundary;
  bool get isAd => adBoundary != null;
}

class NativeAdInsertionPlan {
  const NativeAdInsertionPlan(this.rows);

  final List<NativeAdDisplayRow> rows;

  factory NativeAdInsertionPlan.build({
    required int contentCount,
    required int firstAfter,
    int? interval,
  }) {
    final List<NativeAdDisplayRow> rows = <NativeAdDisplayRow>[];
    for (int index = 0; index < contentCount; index += 1) {
      rows.add(NativeAdDisplayRow.content(index));
      final int boundary = index + 1;
      final bool first = boundary == firstAfter;
      final bool repeated =
          interval != null &&
          boundary > firstAfter &&
          (boundary - firstAfter) % interval == 0;
      if (first || repeated) rows.add(NativeAdDisplayRow.ad(boundary));
    }
    return NativeAdInsertionPlan(List<NativeAdDisplayRow>.unmodifiable(rows));
  }
}

int? completeGridRowBoundary({
  required int firstAfter,
  required int leadingItemCount,
  required int gridItemCount,
  required int columnCount,
}) {
  final int targetGridCount = firstAfter - leadingItemCount;
  if (targetGridCount <= 0 ||
      targetGridCount > gridItemCount ||
      columnCount <= 0) {
    return null;
  }
  final int completedRowCount =
      ((targetGridCount + columnCount - 1) ~/ columnCount) * columnCount;
  return completedRowCount.clamp(1, gridItemCount);
}

class NativeAdsService extends GetxService {
  NativeAdsService({required RewardedAdsService rewardedAdsService})
    : _rewardedAdsService = rewardedAdsService;

  static const String androidTestAdUnitId =
      'ca-app-pub-3940256099942544/2247696110';
  static const String iosTestAdUnitId =
      'ca-app-pub-3940256099942544/3986624511';
  static const String _androidProductionAdUnitId = String.fromEnvironment(
    'ADMOB_NATIVE_ANDROID_ID',
  );
  static const String _iosProductionAdUnitId = String.fromEnvironment(
    'ADMOB_NATIVE_IOS_ID',
  );
  static const int _maximumRetainedSlots = 20;

  final RewardedAdsService _rewardedAdsService;
  final Map<String, NativeAd> _loaded = <String, NativeAd>{};
  final Map<String, Future<NativeAd?>> _inFlight =
      <String, Future<NativeAd?>>{};
  final Map<String, NativeAdPlacement> _placements =
      <String, NativeAdPlacement>{};
  final Map<String, int> _generations = <String, int>{};
  Worker? _eligibilityWorker;

  Rxn<RewardedAdsConfiguration> get configuration =>
      _rewardedAdsService.configuration;

  @override
  void onInit() {
    super.onInit();
    _eligibilityWorker = ever<RewardedAdsConfiguration?>(
      configuration,
      (_) => _discardIneligibleSlots(),
    );
  }

  NativeAdPlacementConfiguration? placementConfiguration(
    NativeAdPlacement placement,
  ) => configuration.value?.nativeAds?.placement(placement);

  bool canRequestPlacement(NativeAdPlacement placement) =>
      canRequest(configuration.value, placement);

  static bool canRequest(
    RewardedAdsConfiguration? configuration,
    NativeAdPlacement placement,
  ) {
    final NativeAdsConfiguration? nativeAds = configuration?.nativeAds;
    return configuration != null &&
        configuration.adsEnabled &&
        !configuration.isAdFree &&
        nativeAds != null &&
        nativeAds.enabled &&
        nativeAds.placement(placement)?.enabled == true;
  }

  NativeAdInsertionPlan insertionPlan({
    required NativeAdPlacement placement,
    required int contentCount,
  }) {
    final NativeAdPlacementConfiguration? config = placementConfiguration(
      placement,
    );
    if (!canRequestPlacement(placement) || config == null) {
      return NativeAdInsertionPlan.build(
        contentCount: contentCount,
        firstAfter: contentCount + 1,
      );
    }
    final int? interval = config.interval;
    final int firstAfter = config.firstAfter ?? interval ?? contentCount + 1;
    return NativeAdInsertionPlan.build(
      contentCount: contentCount,
      firstAfter: firstAfter,
      interval: interval,
    );
  }

  String? get adUnitId {
    if (!kReleaseMode) {
      return Platform.isIOS ? iosTestAdUnitId : androidTestAdUnitId;
    }
    final String productionId = Platform.isIOS
        ? _iosProductionAdUnitId.trim()
        : _androidProductionAdUnitId.trim();
    if (productionId.isEmpty ||
        productionId == androidTestAdUnitId ||
        productionId == iosTestAdUnitId) {
      return null;
    }
    return productionId;
  }

  Future<NativeAd?> acquire({
    required String slotId,
    required NativeAdPlacement placement,
  }) {
    if (!canRequestPlacement(placement) || adUnitId == null) {
      return Future<NativeAd?>.value(null);
    }
    final NativeAd? cached = _loaded[slotId];
    if (cached != null) return Future<NativeAd?>.value(cached);
    final Future<NativeAd?>? pending = _inFlight[slotId];
    if (pending != null) return pending;
    if (_loaded.length + _inFlight.length >= _maximumRetainedSlots) {
      return Future<NativeAd?>.value(null);
    }

    final int generation = (_generations[slotId] ?? 0) + 1;
    _generations[slotId] = generation;
    _placements[slotId] = placement;
    final Completer<NativeAd?> completer = Completer<NativeAd?>();
    late final NativeAd ad;
    ad = NativeAd(
      adUnitId: adUnitId!,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
      listener: NativeAdListener(
        onAdLoaded: (Ad loadedAd) {
          final bool current =
              _generations[slotId] == generation &&
              canRequestPlacement(placement);
          _inFlight.remove(slotId);
          if (current) {
            _loaded[slotId] = ad;
            if (!completer.isCompleted) completer.complete(ad);
          } else {
            loadedAd.dispose();
            if (!completer.isCompleted) completer.complete(null);
          }
        },
        onAdFailedToLoad: (Ad failedAd, LoadAdError error) {
          _inFlight.remove(slotId);
          failedAd.dispose();
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    final Future<NativeAd?> future = completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        release(slotId);
        return null;
      },
    );
    _inFlight[slotId] = future;
    ad.load();
    return future;
  }

  void release(String slotId) {
    _generations[slotId] = (_generations[slotId] ?? 0) + 1;
    _loaded.remove(slotId)?.dispose();
    _inFlight.remove(slotId);
    _placements.remove(slotId);
  }

  void _discardIneligibleSlots() {
    final List<String> slotIds = _placements.entries
        .where(
          (MapEntry<String, NativeAdPlacement> entry) =>
              !canRequestPlacement(entry.value),
        )
        .map((MapEntry<String, NativeAdPlacement> entry) => entry.key)
        .toList(growable: false);
    for (final String slotId in slotIds) {
      release(slotId);
    }
  }

  @override
  void onClose() {
    _eligibilityWorker?.dispose();
    final Set<String> slotIds = <String>{..._loaded.keys, ..._inFlight.keys};
    for (final String slotId in slotIds) {
      release(slotId);
    }
    super.onClose();
  }
}
