import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/controllers/adaptive_network_video_controller.dart';
import '../../../../../core/controllers/hls_playback_recovery_coordinator.dart';
import '../../../../../core/controllers/video_playback_wakelock.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../courses/sub_features/chapter_detail/models/chapter_detail_models.dart';
import '../../../../courses/sub_features/chapter_detail/widgets/chapter_video_fullscreen_view.dart';
import '../../../../courses/sub_features/chapter_detail/widgets/chapter_video_player_surface.dart';

class JobIntroVideoCard extends StatefulWidget {
  const JobIntroVideoCard({
    required this.videoId,
    required this.loadVideoAccess,
    required this.initialProgressPercent,
    required this.onProgress,
    super.key,
  });

  final String videoId;
  final Future<ChapterVideoAccessModel?> Function({bool forceRefresh})
  loadVideoAccess;
  final int initialProgressPercent;
  final void Function(int watchedPercent, int timeSpentSeconds) onProgress;

  @override
  State<JobIntroVideoCard> createState() => _JobIntroVideoCardState();
}

class _JobIntroVideoCardState extends State<JobIntroVideoCard>
    with WidgetsBindingObserver {
  VideoPlayerController? _videoController;
  final VideoPlaybackWakelock _playbackWakelock = VideoPlaybackWakelock();
  Future<void>? _initializationFuture;
  late final ValueNotifier<bool> _hasWatchedFullyNotifier;
  final ValueNotifier<VideoPlayerController?> _controllerNotifier =
      ValueNotifier<VideoPlayerController?>(null);
  final ValueNotifier<String?> _recoveryMessageNotifier =
      ValueNotifier<String?>(null);
  late final HlsPlaybackRecoveryCoordinator _recoveryCoordinator;
  ChapterVideoAccessModel? _videoAccess;

  bool _isInitializing = false;
  String? _errorMessage;
  int _lastReportedPercent = 0;
  int _unreportedWatchMilliseconds = 0;
  DateTime? _lastPlaybackTickAt;
  bool _playbackIntent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recoveryCoordinator = HlsPlaybackRecoveryCoordinator(
      onRecover: _recoverPlayback,
      onRecoveryExhausted: _handleRecoveryExhausted,
    );
    _lastReportedPercent = widget.initialProgressPercent.clamp(0, 100).toInt();
    _hasWatchedFullyNotifier = ValueNotifier<bool>(_lastReportedPercent >= 100);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ensurePlayerInitialized();
      }
    });
  }

  @override
  void didUpdateWidget(covariant JobIntroVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId == widget.videoId) {
      return;
    }

    _disposePlayer();
    _recoveryCoordinator.reset();
    _videoAccess = null;
    _recoveryMessageNotifier.value = null;
    _initializationFuture = null;
    _isInitializing = false;
    _errorMessage = null;
    _playbackIntent = false;
    _lastReportedPercent = widget.initialProgressPercent.clamp(0, 100).toInt();
    _hasWatchedFullyNotifier.value = _lastReportedPercent >= 100;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ensurePlayerInitialized();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flushProgress(force: true);
    _recoveryCoordinator.dispose();
    _playbackWakelock.dispose();
    _disposePlayer();
    _hasWatchedFullyNotifier.dispose();
    _controllerNotifier.dispose();
    _recoveryMessageNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recoveryCoordinator.handleAppResumed();
    }
  }

  Future<void> _ensurePlayerInitialized() async {
    if (_videoController?.value.isInitialized == true) {
      return;
    }

    final Future<void>? activeInitialization = _initializationFuture;
    if (activeInitialization != null) {
      await activeInitialization;
      return;
    }

    final Future<void> initialization = _initializePlayer();
    _initializationFuture = initialization;
    try {
      await initialization;
    } finally {
      _initializationFuture = null;
    }
  }

  Future<void> _initializePlayer() async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });
    }

    ChapterVideoAccessModel? access;
    VideoPlayerController? controller;

    try {
      access = await widget.loadVideoAccess(forceRefresh: false);

      if (access == null || !access.canPlay) {
        throw StateError(_videoAccessMessage(access));
      }

      controller = _createVideoController(access);

      await controller.initialize();
      await _seekToSavedProgress(controller);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _videoController = controller;
      _controllerNotifier.value = controller;
      _videoAccess = access;
      controller.addListener(_onVideoTick);
      _playbackWakelock.attach(controller);
      _recoveryCoordinator.updateAccess(
        expiresAt: access.expiresAt,
        requiresSignedAccess: access.requiresSignedCookies,
      );

      setState(() {
        _isInitializing = false;
        _errorMessage = null;
        _recoveryMessageNotifier.value = null;
      });
    } catch (_) {
      await controller?.dispose();

      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _errorMessage = _videoAccessMessage(access);
      });
    }
  }

  String _videoAccessMessage(ChapterVideoAccessModel? access) {
    switch (access?.status) {
      case ChapterVideoTranscodeStatus.pending:
        return 'Video processing has not started yet. Tap to check again.';

      case ChapterVideoTranscodeStatus.processing:
        return 'Video is still processing. Tap to check again.';

      case ChapterVideoTranscodeStatus.failed:
        return access?.retryable == true
            ? 'Video processing failed. Tap to retry.'
            : 'Video processing failed.';

      case ChapterVideoTranscodeStatus.notRequired:
        return 'This video has not been converted to HLS yet.';

      case ChapterVideoTranscodeStatus.ready:
        if (access == null || access.streamUrl.isEmpty) {
          return 'The HLS stream URL is unavailable. Tap to retry.';
        }

        if (access.requiresSignedCookies && !access.hasCloudFrontCookies) {
          return 'CloudFront access could not be prepared. Tap to retry.';
        }

        return 'Video could not be loaded. Tap to retry.';

      case ChapterVideoTranscodeStatus.unknown:
      case null:
        return 'Video could not be loaded. Tap to retry.';
    }
  }

  VideoPlayerController _createVideoController(ChapterVideoAccessModel access) {
    final Uri? uri = Uri.tryParse(access.streamUrl.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('Invalid HLS stream URL.');
    }

    return createAdaptiveNetworkVideoController(
      uri: uri,
      forceHls: true,
      httpHeaders: access.videoHttpHeaders,
    );
  }

  Future<void> _seekToSavedProgress(VideoPlayerController controller) async {
    final Duration duration = controller.value.duration;
    final double savedProgress = (widget.initialProgressPercent / 100)
        .clamp(0.0, 1.0)
        .toDouble();
    if (duration.inMilliseconds <= 0 || savedProgress <= 0) {
      return;
    }

    if (savedProgress >= 1) {
      await controller.seekTo(Duration.zero);
      return;
    }

    await controller.seekTo(
      Duration(milliseconds: (duration.inMilliseconds * savedProgress).round()),
    );
  }

  void _disposePlayer() {
    final VideoPlayerController? controller = _videoController;
    if (controller == null) return;

    _playbackWakelock.detach();
    _controllerNotifier.value = null;
    controller.removeListener(_onVideoTick);
    controller.dispose();
    _videoController = null;
    _lastPlaybackTickAt = null;
  }

  void _onVideoTick() {
    final VideoPlayerController? controller = _videoController;
    if (controller == null) {
      return;
    }

    final VideoPlayerValue value = controller.value;
    _recoveryCoordinator.updatePlaybackValue(value);
    if (!value.isInitialized || value.hasError) {
      return;
    }
    final DateTime now = DateTime.now();
    if (value.isPlaying && !value.isBuffering) {
      final DateTime? previousTick = _lastPlaybackTickAt;
      if (previousTick != null) {
        final int elapsed = now.difference(previousTick).inMilliseconds;
        if (elapsed > 0 && elapsed <= 2000) {
          _unreportedWatchMilliseconds += elapsed;
        }
      }
      _lastPlaybackTickAt = now;
    } else {
      _lastPlaybackTickAt = null;
    }

    final Duration duration = value.duration;
    final Duration position = value.position;
    if (duration.inMilliseconds <= 0) {
      return;
    }

    final Duration remaining = duration - position;
    final bool isComplete =
        position > Duration.zero &&
        (position >= duration ||
            remaining <= const Duration(milliseconds: 150));
    final int percent = isComplete
        ? 100
        : ((position.inMilliseconds / duration.inMilliseconds) * 100)
              .floor()
              .clamp(0, 99)
              .toInt();

    if (isComplete && !_hasWatchedFullyNotifier.value) {
      _hasWatchedFullyNotifier.value = true;
    }
    if (isComplete) {
      _playbackIntent = false;
    }

    final bool reachedQuizThreshold =
        _lastReportedPercent < 80 && percent >= 80;
    if (percent >= 100 ||
        reachedQuizThreshold ||
        percent >= _lastReportedPercent + 10) {
      _reportProgress(percent);
    }
  }

  void _reportProgress(int percent) {
    final int normalizedPercent = percent.clamp(0, 100).toInt();
    final int timeSpentSeconds = _unreportedWatchMilliseconds ~/ 1000;
    _unreportedWatchMilliseconds %= 1000;
    _lastReportedPercent = normalizedPercent;
    widget.onProgress(normalizedPercent, timeSpentSeconds);
  }

  void _flushProgress({bool force = false}) {
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final Duration duration = controller.value.duration;
    if (duration.inMilliseconds <= 0) return;
    final int percent =
        ((controller.value.position.inMilliseconds / duration.inMilliseconds) *
                100)
            .floor()
            .clamp(0, 100)
            .toInt();
    if (force && _unreportedWatchMilliseconds >= 1000) {
      _reportProgress(percent);
    }
  }

  Future<bool> _recoverPlayback({
    required HlsPlaybackRecoveryReason reason,
    required bool refreshAccess,
  }) async {
    final ChapterVideoAccessModel? currentAccess = _videoAccess;
    if (!mounted || currentAccess == null) {
      return false;
    }

    ChapterVideoAccessModel? access = currentAccess;
    if (refreshAccess) {
      access = await widget.loadVideoAccess(forceRefresh: true);
    }
    if (!mounted || access == null || !access.canPlay) {
      return false;
    }

    return _replaceController(access);
  }

  Future<bool> _replaceController(ChapterVideoAccessModel access) async {
    final VideoPlayerController? oldController = _videoController;
    if (oldController == null) {
      return false;
    }

    final ChapterVideoAccessModel? oldAccess = _videoAccess;
    final VideoPlayerValue oldValue = oldController.value;
    final Duration oldPosition = oldValue.position;
    final bool shouldResume = _playbackIntent;
    final double playbackSpeed = oldValue.playbackSpeed;
    VideoPlayerController? pendingController;

    try {
      pendingController = _createVideoController(access);
      await pendingController.initialize();
      final Duration newDuration = pendingController.value.duration;
      final Duration targetPosition =
          newDuration.inMilliseconds > 0 && oldPosition > newDuration
          ? newDuration
          : oldPosition;
      if (targetPosition > Duration.zero) {
        await pendingController.seekTo(targetPosition);
      }
      await pendingController.setPlaybackSpeed(playbackSpeed);
    } catch (_) {
      await pendingController?.dispose();
      return false;
    }

    final VideoPlayerController newController = pendingController;
    if (!mounted || !identical(_videoController, oldController)) {
      await newController.dispose();
      return false;
    }

    if (oldController.value.isPlaying) {
      try {
        await oldController.pause();
      } catch (_) {
        // The replacement is already ready, so a stale-player pause failure
        // does not prevent the swap.
      }
    }

    if (!mounted || !identical(_videoController, oldController)) {
      await newController.dispose();
      return false;
    }

    try {
      oldController.removeListener(_onVideoTick);
      newController.addListener(_onVideoTick);
      _videoController = newController;
      _controllerNotifier.value = newController;
      _videoAccess = access;
      _playbackWakelock.attach(newController);
      _recoveryCoordinator.updateAccess(
        expiresAt: access.expiresAt,
        requiresSignedAccess: access.requiresSignedCookies,
      );

      if (shouldResume) {
        await newController.play();
      }
    } catch (_) {
      if (!mounted) {
        await newController.dispose();
        await oldController.dispose();
        return false;
      }
      newController.removeListener(_onVideoTick);
      _videoController = oldController;
      _controllerNotifier.value = oldController;
      _videoAccess = oldAccess;
      oldController.addListener(_onVideoTick);
      _playbackWakelock.attach(oldController);
      _recoveryCoordinator.updateAccess(
        expiresAt: oldAccess?.expiresAt,
        requiresSignedAccess: oldAccess?.requiresSignedCookies ?? false,
      );
      await newController.dispose();
      if (shouldResume) {
        try {
          await oldController.play();
        } catch (_) {
          // The old access may already be expired.
        }
      }
      return false;
    }

    try {
      await oldController.dispose();
    } catch (_) {
      // The replacement is already active; disposal failure is non-fatal.
    }
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _recoveryMessageNotifier.value = null;
      });
    }
    return true;
  }

  Future<void> _retryPlayback() async {
    final bool recovered = await _recoveryCoordinator.recoverNow(
      refreshAccess: true,
    );
    if (!recovered && mounted) {
      _recoveryMessageNotifier.value =
          'Unable to resume video. Check your connection and tap Retry.';
    }
  }

  void _handleRecoveryExhausted(HlsPlaybackRecoveryReason reason) {
    if (mounted) {
      _recoveryMessageNotifier.value =
          'Video playback was interrupted. Tap Retry to continue.';
    }
  }

  void _handlePlaybackIntentChanged(bool shouldPlay) {
    _playbackIntent = shouldPlay;
  }

  Future<void> _play() async {
    if (_videoController != null &&
        _videoController?.value.isInitialized != true &&
        _videoAccess != null) {
      await _retryPlayback();
    } else {
      await _ensurePlayerInitialized();
    }
    if (_videoAccess?.isExpiredOrNearExpiry == true) {
      await _recoveryCoordinator.recoverNow(refreshAccess: true);
    }
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final VideoPlayerValue value = controller.value;
    if (value.duration.inMilliseconds > 0 &&
        value.position >= value.duration - const Duration(milliseconds: 400)) {
      await controller.seekTo(Duration.zero);
    }
    await controller.play();
    _playbackIntent = true;
  }

  Future<void> _openFullscreen() async {
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !controller.value.isInitialized || !mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChapterVideoFullscreenView(
          controller: controller,
          controllerListenable: _controllerNotifier,
          hasWatchedFullyListenable: _hasWatchedFullyNotifier,
          progressLabel: 'career_introduction'.tr,
          fallbackPositionLabel: '0:00',
          fallbackDurationLabel: '0:00',
          recoveryMessageListenable: _recoveryMessageNotifier,
          onRetry: _retryPlayback,
          onPlaybackIntentChanged: _handlePlaybackIntentChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kChapterVideoCardHeight.h,
      decoration: BoxDecoration(
        color: AppColors.chapterVideoDark,
        borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 24.r,
            offset: Offset(0, 16.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
        child: ValueListenableBuilder<VideoPlayerController?>(
          valueListenable: _controllerNotifier,
          builder:
              (
                BuildContext context,
                VideoPlayerController? controller,
                Widget? child,
              ) {
                if (controller == null || !controller.value.isInitialized) {
                  return _VideoPlaceholder(
                    isLoading: _isInitializing,
                    errorMessage: _errorMessage,
                    onPlayTap: _play,
                  );
                }

                return ChapterVideoPlayerSurface(
                  controller: controller,
                  hasWatchedFullyListenable: _hasWatchedFullyNotifier,
                  progressLabel: 'career_introduction'.tr,
                  fallbackPositionLabel: '0:00',
                  fallbackDurationLabel: '0:00',
                  recoveryMessageListenable: _recoveryMessageNotifier,
                  onRetry: _retryPlayback,
                  onPlaybackIntentChanged: _handlePlaybackIntentChanged,
                  onFullscreenTap: _openFullscreen,
                );
              },
        ),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({
    required this.isLoading,
    required this.onPlayTap,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onPlayTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.chapterVideoDark,
            AppColors.chapterVideoDeep,
          ],
        ),
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: AppColors.homeLime)
            : GestureDetector(
                onTap: onPlayTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.42),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.white,
                        size: 38.w,
                      ),
                    ),
                    if (errorMessage != null) ...<Widget>[
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
