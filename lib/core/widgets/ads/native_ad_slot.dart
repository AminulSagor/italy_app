import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../models/rewarded_ads_models.dart';
import '../../services/native_ads/native_ads_service.dart';

class NativeAdSlot extends StatefulWidget {
  const NativeAdSlot({
    required this.placement,
    required this.slotId,
    this.margin = EdgeInsets.zero,
    this.height = 360,
    super.key,
  });

  final NativeAdPlacement placement;
  final String slotId;
  final EdgeInsetsGeometry margin;
  final double height;

  @override
  State<NativeAdSlot> createState() => _NativeAdSlotState();
}

class _NativeAdSlotState extends State<NativeAdSlot> {
  static const List<Duration> _retryDelays = <Duration>[
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
  ];

  late final NativeAdsService _service;
  Worker? _eligibilityWorker;
  NativeAd? _ad;
  Timer? _retryTimer;
  int _generation = 0;
  int _retryAttempt = 0;
  bool _reserveSpace = false;

  @override
  void initState() {
    super.initState();
    _service = Get.find<NativeAdsService>();
    _eligibilityWorker = ever<RewardedAdsConfiguration?>(
      _service.configuration,
      (_) => _sync(),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant NativeAdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slotId != widget.slotId ||
        oldWidget.placement != widget.placement) {
      _cancelRetry(resetAttempt: true);
      _generation += 1;
      _service.release(oldWidget.slotId);
      _ad = null;
      _reserveSpace = false;
      _sync();
    }
  }

  Future<void> _sync() async {
    if (!_service.canRequestPlacement(widget.placement)) {
      _cancelRetry(resetAttempt: true);
      _generation += 1;
      _service.release(widget.slotId);
      if (mounted && (_ad != null || _reserveSpace)) {
        setState(() {
          _ad = null;
          _reserveSpace = false;
        });
      }
      return;
    }
    if (_ad != null) return;
    if (!_reserveSpace && mounted) {
      setState(() => _reserveSpace = true);
    }
    final int generation = ++_generation;
    final NativeAd? ad = await _service.acquire(
      slotId: widget.slotId,
      placement: widget.placement,
    );
    if (!mounted || generation != _generation) return;
    if (ad == null) {
      if (!_scheduleRetry()) {
        setState(() => _reserveSpace = false);
      }
      return;
    }
    _cancelRetry(resetAttempt: true);
    setState(() {
      _ad = ad;
      _reserveSpace = false;
    });
  }

  bool _scheduleRetry() {
    if (!mounted || !_service.canRequestPlacement(widget.placement)) {
      return false;
    }
    if (_retryAttempt >= _retryDelays.length) return false;
    final Duration delay = _retryDelays[_retryAttempt++];
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (!mounted || !_service.canRequestPlacement(widget.placement)) {
        if (mounted) setState(() => _reserveSpace = false);
        return;
      }
      unawaited(_sync());
    });
    return true;
  }

  void _cancelRetry({required bool resetAttempt}) {
    _retryTimer?.cancel();
    _retryTimer = null;
    if (resetAttempt) _retryAttempt = 0;
  }

  @override
  void dispose() {
    _cancelRetry(resetAttempt: true);
    _generation += 1;
    _eligibilityWorker?.dispose();
    _service.release(widget.slotId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NativeAd? ad = _ad;
    if (ad == null && !_reserveSpace) return const SizedBox.shrink();
    if (ad == null) {
      return IgnorePointer(
        child: Container(
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }
    return Semantics(
      label: 'Advertisement',
      container: true,
      child: Container(
        height: widget.height,
        margin: widget.margin,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
