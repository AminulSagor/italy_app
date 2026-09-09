import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/controllers/adaptive_network_video_controller.dart';
import '../../../../../core/controllers/video_playback_wakelock.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/chapter_detail_models.dart';
import 'chapter_video_fullscreen_view.dart';
import 'chapter_video_player_surface.dart';

class ChapterVideoCard extends StatefulWidget {
  final ChapterDetailModel detail;
  final int playbackCommand;
  final bool shouldPlay;
  final Future<ChapterVideoAccessModel?> Function() loadVideoAccess;
  final ValueChanged<bool> onPlaybackChanged;
  final void Function(Duration position, Duration duration) onProgressChanged;

  const ChapterVideoCard({
    super.key,
    required this.detail,
    required this.playbackCommand,
    required this.shouldPlay,
    required this.loadVideoAccess,
    required this.onPlaybackChanged,
    required this.onProgressChanged,
  });

  @override
  State<ChapterVideoCard> createState() => _ChapterVideoCardState();
}

class _ChapterVideoCardState extends State<ChapterVideoCard> {
  VideoPlayerController? _videoController;
  final VideoPlaybackWakelock _playbackWakelock = VideoPlaybackWakelock();
  Future<void>? _initializationFuture;
  late final ValueNotifier<bool> _hasWatchedFullyNotifier;
  final ValueNotifier<VideoPlayerController?> _controllerNotifier =
      ValueNotifier<VideoPlayerController?>(null);
  final ValueNotifier<String> _selectedQualityNotifier = ValueNotifier<String>(
    'Auto',
  );

  ChapterVideoAccessModel? _videoAccess;
  bool _isInitializing = false;
  bool _isChangingQuality = false;
  String? _errorMessage;
  int _lastPlaybackCommand = 0;
  bool _lastReportedPlaying = false;
  int _lastReportedPercent = 0;

  @override
  void initState() {
    super.initState();
    _lastPlaybackCommand = widget.playbackCommand;
    _lastReportedPercent = widget.detail.progress.videoWatchPercent;
    _hasWatchedFullyNotifier = ValueNotifier<bool>(
      widget.detail.progress.videoWatchPercent >= 100,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ensurePlayerInitialized();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChapterVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.detail.video?.fileId != widget.detail.video?.fileId) {
      _lastReportedPercent = widget.detail.progress.videoWatchPercent;
      _hasWatchedFullyNotifier.value =
          widget.detail.progress.videoWatchPercent >= 100;
      _disposePlayer();
      _videoAccess = null;
      _selectedQualityNotifier.value = 'Auto';
      _initializationFuture = null;
      _isInitializing = false;
      _isChangingQuality = false;
      _errorMessage = null;
    }

    final int savedPercent = widget.detail.progress.videoWatchPercent;
    if (savedPercent > _lastReportedPercent) {
      _lastReportedPercent = savedPercent;
    }
    if (savedPercent >= 100 && !_hasWatchedFullyNotifier.value) {
      _hasWatchedFullyNotifier.value = true;
    }

    if (widget.playbackCommand != _lastPlaybackCommand) {
      _lastPlaybackCommand = widget.playbackCommand;
      if (widget.shouldPlay) {
        _play();
      } else {
        _pause();
      }
    }
  }

  @override
  void dispose() {
    _playbackWakelock.dispose();
    _disposePlayer();
    _controllerNotifier.dispose();
    _selectedQualityNotifier.dispose();
    _hasWatchedFullyNotifier.dispose();
    super.dispose();
  }

  Future<void> _ensurePlayerInitialized() async {
    final VideoPlayerController? currentController = _videoController;
    if (currentController?.value.isInitialized == true) {
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

      _videoAccess = access;
      _selectedQualityNotifier.value = 'Auto';

      controller = _createVideoController(
        streamUrl: access.streamUrl,
        access: access,
      );

      await controller.initialize();
      await _seekToSavedProgress(controller);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _videoController = controller;
      _controllerNotifier.value = controller;
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

  VideoPlayerController _createVideoController({
    required String streamUrl,
    required ChapterVideoAccessModel access,
  }) {
    final Uri streamUri = Uri.parse(streamUrl);

    if (!streamUri.hasScheme || streamUri.host.isEmpty) {
      throw StateError('Invalid HLS stream URL.');
    }

    return createAdaptiveNetworkVideoController(
      uri: streamUri,
      forceHls: true,
      httpHeaders: access.videoHttpHeaders,
    );
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
          return 'CloudFront video access could not be prepared. Tap to retry.';
        }

        return 'Video could not be loaded. Tap to retry.';

      case ChapterVideoTranscodeStatus.unknown:
      case null:
        return 'video_could_not_be_loaded_tap_to_retry'.tr;
    }
  }

  Future<void> _seekToSavedProgress(VideoPlayerController controller) async {
    final Duration duration = controller.value.duration;
    final double savedProgress = widget.detail.videoProgress
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
  }

  void _onVideoTick() {
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    _reportPlaybackState(controller.value.isPlaying);

    final Duration duration = controller.value.duration;
    final Duration position = controller.value.position;
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

    if (percent == 100 && _lastReportedPercent < 100) {
      _lastReportedPercent = 100;
      widget.onProgressChanged(duration, duration);
      return;
    }

    final bool reachedQuizThreshold =
        _lastReportedPercent < 80 && percent >= 80;
    if (reachedQuizThreshold || percent >= _lastReportedPercent + 5) {
      _lastReportedPercent = percent;
      widget.onProgressChanged(position, duration);
    }
  }

  void _reportPlaybackState(bool isPlaying) {
    if (_lastReportedPlaying == isPlaying) return;
    _lastReportedPlaying = isPlaying;
    widget.onPlaybackChanged(isPlaying);
  }

  Future<void> _pause() async {
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.pause();
    _reportPlaybackState(false);
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
    _reportPlaybackState(true);
  }

  Future<void> _changeQuality(ChapterVideoQualityOption? quality) async {
    if (_isChangingQuality) {
      return;
    }

    final ChapterVideoAccessModel? access = _videoAccess;
    final VideoPlayerController? oldController = _videoController;

    if (access == null ||
        oldController == null ||
        !oldController.value.isInitialized) {
      return;
    }

    final String oldLabel = _selectedQualityNotifier.value;
    final String nextLabel = quality?.label ?? 'Auto';
    final String nextStreamUrl = quality?.streamUrl ?? access.streamUrl;

    if (nextLabel == oldLabel || nextStreamUrl.trim().isEmpty) {
      return;
    }

    _isChangingQuality = true;
    VideoPlayerController? pendingController;

    final VideoPlayerValue oldValue = oldController.value;
    final Duration oldPosition = oldValue.position;
    final bool wasPlaying = oldValue.isPlaying;
    final double playbackSpeed = oldValue.playbackSpeed;

    try {
      pendingController = _createVideoController(
        streamUrl: nextStreamUrl,
        access: access,
      );

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
      _showQualityChangeError();
      _isChangingQuality = false;
      return;
    }

    final VideoPlayerController newController = pendingController!;

    if (!mounted) {
      await newController.dispose();
      _isChangingQuality = false;
      return;
    }

    oldController.removeListener(_onVideoTick);
    newController.addListener(_onVideoTick);

    _videoController = newController;
    _controllerNotifier.value = newController;
    _selectedQualityNotifier.value = nextLabel;
    _playbackWakelock.attach(newController);

    try {
      if (wasPlaying) {
        await oldController.pause();
        await newController.play();
      }
    } catch (_) {
      newController.removeListener(_onVideoTick);

      _videoController = oldController;
      _controllerNotifier.value = oldController;
      _selectedQualityNotifier.value = oldLabel;
      oldController.addListener(_onVideoTick);
      _playbackWakelock.attach(oldController);

      await newController.dispose();

      if (wasPlaying) {
        await oldController.play();
      }

      _reportPlaybackState(oldController.value.isPlaying);
      _showQualityChangeError();
      _isChangingQuality = false;
      return;
    }

    try {
      await oldController.dispose();
      _reportPlaybackState(newController.value.isPlaying);
    } finally {
      _isChangingQuality = false;
    }
  }

  void _showQualityChangeError() {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to change video quality.')),
    );
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
          progressLabel: widget.detail.videoProgressLabel,
          fallbackPositionLabel: widget.detail.watchedTimeLabel,
          fallbackDurationLabel: widget.detail.totalTimeLabel,
          showSettings: true,
          qualityOptions:
              _videoAccess?.qualities ?? const <ChapterVideoQualityOption>[],
          selectedQualityListenable: _selectedQualityNotifier,
          onQualityChanged: _changeQuality,
        ),
      ),
    );

    /*
   * The fullscreen page restores portrait before it
   * closes. Rebuild this video card using the restored
   * portrait dimensions.
   */
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: Colors.black,
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
                  progressLabel: widget.detail.videoProgressLabel,
                  fallbackPositionLabel: widget.detail.watchedTimeLabel,
                  fallbackDurationLabel: widget.detail.totalTimeLabel,
                  showSettings: true,
                  qualityOptions:
                      _videoAccess?.qualities ??
                      const <ChapterVideoQualityOption>[],
                  selectedQualityListenable: _selectedQualityNotifier,
                  onQualityChanged: _changeQuality,
                  onFullscreenTap: _openFullscreen,
                );
              },
        ),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onPlayTap;

  const _VideoPlaceholder({
    required this.isLoading,
    required this.onPlayTap,
    this.errorMessage,
  });

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
