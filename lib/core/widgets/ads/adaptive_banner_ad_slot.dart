import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../models/rewarded_ads_models.dart';
import '../../services/banner_ads/banner_ads_service.dart';

class AdaptiveBannerAdSlot extends StatefulWidget {
  const AdaptiveBannerAdSlot({
    super.key,
    this.visible = true,
    this.margin = EdgeInsets.zero,
    this.reserveSpaceWhileLoading = false,
  });

  final bool visible;
  final EdgeInsetsGeometry margin;
  final bool reserveSpaceWhileLoading;

  @override
  State<AdaptiveBannerAdSlot> createState() => _AdaptiveBannerAdSlotState();
}

class _AdaptiveBannerAdSlotState extends State<AdaptiveBannerAdSlot> {
  late final BannerAdsService _service;
  late final Worker _eligibilityWorker;
  BannerAd? _banner;
  AdSize? _size;
  int _width = 0;
  int _loadGeneration = 0;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _service = Get.find<BannerAdsService>();
    _eligibilityWorker = ever<RewardedAdsConfiguration?>(
      _service.configuration,
      (_) => _syncEligibility(),
    );
    unawaited(_refreshEligibility());
  }

  @override
  void didUpdateWidget(covariant AdaptiveBannerAdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.visible && widget.visible) {
      _ensureLoaded();
    }
  }

  Future<void> _refreshEligibility() async {
    await _service.refreshEligibility();
    if (mounted) _syncEligibility();
  }

  void _syncEligibility() {
    if (!_service.canRequestBanner) {
      _disposeBanner();
      return;
    }
    if (widget.visible) _ensureLoaded();
  }

  void _updateWidth(double width) {
    final int nextWidth = width.floor();
    if (nextWidth <= 0 || nextWidth == _width) return;
    _width = nextWidth;
    _failed = false;
    _disposeBanner(notify: false);
    if (widget.visible && _service.canRequestBanner) _ensureLoaded();
  }

  Future<void> _ensureLoaded() async {
    if (!mounted ||
        !widget.visible ||
        !_service.canRequestBanner ||
        _width <= 0 ||
        _banner != null ||
        _loading ||
        _failed) {
      return;
    }

    _loading = true;
    final int generation = ++_loadGeneration;
    final AdSize? size = await _service.adaptiveSize(_width);
    if (!mounted || generation != _loadGeneration) return;
    if (size == null) {
      _loading = false;
      _failed = true;
      return;
    }
    setState(() => _size = size);

    final BannerAd? banner = await _service.load(size: size);
    if (!mounted || generation != _loadGeneration) {
      banner?.dispose();
      return;
    }
    _loading = false;
    if (banner == null || !_service.canRequestBanner) {
      banner?.dispose();
      setState(() {
        _failed = true;
        _size = null;
      });
      return;
    }
    setState(() => _banner = banner);
  }

  void _disposeBanner({bool notify = true}) {
    _loadGeneration += 1;
    _loading = false;
    _failed = false;
    _banner?.dispose();
    _banner = null;
    _size = null;
    if (notify && mounted) setState(() {});
  }

  @override
  void dispose() {
    _eligibilityWorker.dispose();
    _disposeBanner(notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _updateWidth(constraints.maxWidth);
        });

        final AdSize? size = _size;
        final BannerAd? banner = _banner;
        final bool shouldReserve =
            widget.visible &&
            size != null &&
            (banner != null || widget.reserveSpaceWhileLoading);
        if (!shouldReserve) return const SizedBox.shrink();

        return Padding(
          padding: widget.margin,
          child: Center(
            child: SizedBox(
              width: size.width.toDouble(),
              height: size.height.toDouble(),
              child: banner == null ? null : AdWidget(ad: banner),
            ),
          ),
        );
      },
    );
  }
}
