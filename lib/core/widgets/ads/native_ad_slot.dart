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
    super.key,
  });

  final NativeAdPlacement placement;
  final String slotId;
  final EdgeInsetsGeometry margin;

  @override
  State<NativeAdSlot> createState() => _NativeAdSlotState();
}

class _NativeAdSlotState extends State<NativeAdSlot> {
  late final NativeAdsService _service;
  Worker? _eligibilityWorker;
  NativeAd? _ad;
  int _generation = 0;

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
      _generation += 1;
      _service.release(oldWidget.slotId);
      _ad = null;
      _sync();
    }
  }

  Future<void> _sync() async {
    if (!_service.canRequestPlacement(widget.placement)) {
      _generation += 1;
      _service.release(widget.slotId);
      if (mounted && _ad != null) setState(() => _ad = null);
      return;
    }
    if (_ad != null) return;
    final int generation = ++_generation;
    final NativeAd? ad = await _service.acquire(
      slotId: widget.slotId,
      placement: widget.placement,
    );
    if (!mounted || generation != _generation) return;
    setState(() => _ad = ad);
  }

  @override
  void dispose() {
    _generation += 1;
    _eligibilityWorker?.dispose();
    _service.release(widget.slotId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NativeAd? ad = _ad;
    if (ad == null) return const SizedBox.shrink();
    return Semantics(
      label: 'Advertisement',
      container: true,
      child: Container(
        height: 360,
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
