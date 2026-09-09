import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/controllers/adaptive_network_video_controller.dart';
import '../../../../../core/controllers/video_playback_wakelock.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../courses/sub_features/chapter_detail/models/chapter_detail_models.dart';
import '../../../../courses/sub_features/chapter_detail/widgets/chapter_video_fullscreen_view.dart';
import '../../../../courses/sub_features/chapter_detail/widgets/chapter_video_player_surface.dart';
import 'package:get/get.dart';

class JobIntroVideoCard extends StatefulWidget {
  const JobIntroVideoCard({
    required this.videoId,
    required this.loadVideoAccess,
    required this.initialProgressPercent,
    required this.onProgress,
    super.key,
  });

  final String videoId;
  final Future<ChapterVideoAccessModel?> Function() loadVideoAccess;
  final int initialProgressPercent;
  final void Function(int watchedPercent, int timeSpentSeconds) onProgress;

  @override
  State<JobIntroVideoCard> createState() => _JobIntroVideoCardState();
}

class _JobIntroVideoCardState extends State<JobIntroVideoCard> {
  VideoPlayerController? _videoController;
  final VideoPlaybackWakelock _playbackWakelock = VideoPlaybackWakelock();
  Future<void>? _initializationFuture;
  late final ValueNotifier<bool> _hasWatchedFullyNotifier;

  bool _isInitializing = false;
  String? _errorMessage;
  int _lastReportedPercent = 0;
  int _unreportedWatchMilliseconds = 0;
  DateTime? _lastPlaybackTickAt;

  @override
  void initState() {
    super.initState();
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
    _initializationFuture = null;
    _isInitializing = false;
    _errorMessage = null;
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
    _flushProgress(force: true);
    _playbackWakelock.dispose();
    _disposePlayer();
    _hasWatchedFullyNotifier.dispose();
    super.dispose();
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
      access = await widget.loadVideoAccess();

      if (access == null || !access.canPlay) {
        throw StateError(_videoAccessMessage(access));
      }

      final Uri? uri = Uri.tryParse(access.streamUrl.trim());

      if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
        throw StateError('Invalid HLS stream URL.');
      }

      controller = createAdaptiveNetworkVideoController(
        uri: uri,
        forceHls: true,
        httpHeaders: access.videoHttpHeaders,
      );

      await controller.initialize();
      await _seekToSavedProgress(controller);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _videoController = controller;
      controller.addListener(_onVideoTick);
      _playbackWakelock.attach(controller);

      setState(() {
        _isInitializing = false;
        _errorMessage = null;
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
    controller.removeListener(_onVideoTick);
    controller.dispose();
    _videoController = null;
    _lastPlaybackTickAt = null;
  }

  void _onVideoTick() {
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final VideoPlayerValue value = controller.value;
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

  Future<void> _play() async {
    await _ensurePlayerInitialized();
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
          hasWatchedFullyListenable: _hasWatchedFullyNotifier,
          progressLabel: 'career_introduction'.tr,
          fallbackPositionLabel: '0:00',
          fallbackDurationLabel: '0:00',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _videoController;

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
        child: controller != null && controller.value.isInitialized
            ? ChapterVideoPlayerSurface(
                controller: controller,
                hasWatchedFullyListenable: _hasWatchedFullyNotifier,
                progressLabel: 'career_introduction'.tr,
                fallbackPositionLabel: '0:00',
                fallbackDurationLabel: '0:00',
                onFullscreenTap: _openFullscreen,
              )
            : _VideoPlaceholder(
                isLoading: _isInitializing,
                errorMessage: _errorMessage,
                onPlayTap: _play,
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
