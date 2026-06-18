import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/chapter_detail_models.dart';

class ChapterVideoCard extends StatefulWidget {
  final ChapterDetailModel detail;
  final int playCommand;
  final void Function(Duration position, Duration duration) onProgressChanged;

  const ChapterVideoCard({
    super.key,
    required this.detail,
    required this.playCommand,
    required this.onProgressChanged,
  });

  @override
  State<ChapterVideoCard> createState() => _ChapterVideoCardState();
}

class _ChapterVideoCardState extends State<ChapterVideoCard> {
  VideoPlayerController? _videoController;
  bool _isInitializing = true;
  String? _errorMessage;
  int _lastPlayCommand = 0;
  int _lastReportedPercent = 0;

  @override
  void initState() {
    super.initState();
    _lastPlayCommand = widget.playCommand;
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant ChapterVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail.video?.url != widget.detail.video?.url) {
      _disposePlayer();
      _initializePlayer();
      return;
    }

    if (widget.playCommand != _lastPlayCommand) {
      _lastPlayCommand = widget.playCommand;
      _play();
    }
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    final String videoUrl = widget.detail.video?.url ?? '';
    if (videoUrl.isEmpty) {
      return;
    }

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final VideoPlayerController controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      await controller.initialize();
      await _seekToSavedProgress(controller);
      controller.addListener(_onVideoTick);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _isInitializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Video could not be loaded.';
      });
    }
  }

  Future<void> _seekToSavedProgress(VideoPlayerController controller) async {
    final Duration duration = controller.value.duration;
    final double savedProgress = widget.detail.videoProgress
        .clamp(0.0, 0.98)
        .toDouble();
    if (duration.inMilliseconds <= 0 || savedProgress <= 0) {
      return;
    }

    await controller.seekTo(
      Duration(milliseconds: (duration.inMilliseconds * savedProgress).round()),
    );
  }

  void _disposePlayer() {
    final VideoPlayerController? controller = _videoController;
    if (controller == null) return;
    controller.removeListener(_onVideoTick);
    controller.dispose();
    _videoController = null;
  }

  void _onVideoTick() {
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final Duration duration = controller.value.duration;
    final Duration position = controller.value.position;
    if (duration.inMilliseconds <= 0) {
      return;
    }

    final int percent = ((position.inMilliseconds / duration.inMilliseconds) * 100)
        .floor()
        .clamp(0, 100)
        .toInt();

    if (percent >= _lastReportedPercent + 5 || percent >= 80) {
      _lastReportedPercent = percent;
      widget.onProgressChanged(position, duration);
    }
  }

  Future<void> _togglePlayback() async {
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _play() async {
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    await controller.play();
    if (mounted) setState(() {});
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
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (controller != null && controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              )
            else
              _VideoPlaceholder(
                isLoading: _isInitializing,
                errorMessage: _errorMessage,
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppColors.black.withValues(alpha: 0.10),
                    AppColors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
            _VideoOverlay(
              detail: widget.detail,
              controller: controller,
              isReady: controller?.value.isInitialized == true,
              onPlayTap: _togglePlayback,
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;

  const _VideoPlaceholder({required this.isLoading, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.chapterVideoDark, AppColors.chapterVideoDeep],
        ),
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: AppColors.homeLime)
            : Text(
                errorMessage ?? 'Video not available',
                style: TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }
}

class _VideoOverlay extends StatelessWidget {
  final ChapterDetailModel detail;
  final VideoPlayerController? controller;
  final bool isReady;
  final VoidCallback onPlayTap;

  const _VideoOverlay({
    required this.detail,
    required this.controller,
    required this.isReady,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPlaying = controller?.value.isPlaying == true;
    final Duration position = controller?.value.position ?? Duration.zero;
    final Duration duration = controller?.value.duration ?? Duration.zero;
    final double progress = duration.inMilliseconds <= 0
        ? detail.videoProgress
        : (position.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 34.h, 24.w, 26.h),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: isReady ? onPlayTap : null,
            child: Container(
              width: 74.w,
              height: 74.w,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.22),
                ),
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.white,
                size: 44.w,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  detail.videoProgressLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${_durationLabel(position, detail.watchedTimeLabel)} / ${_durationLabel(duration, detail.totalTimeLabel)}',
                style: TextStyle(
                  fontSize: AppFont.font15.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.homeLime,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
            child: LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(999.r),
              minHeight: 15.h,
              color: AppColors.homeLime,
              backgroundColor: AppColors.chapterProgressTrack,
            ),
          ),
        ],
      ),
    );
  }

  String _durationLabel(Duration duration, String fallback) {
    if (duration == Duration.zero) return fallback;
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
