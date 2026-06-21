import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';

class JobIntroVideoCard extends StatefulWidget {
  const JobIntroVideoCard({
    required this.videoUrl,
    required this.initialProgressPercent,
    required this.onProgress,
    super.key,
  });

  final String videoUrl;
  final int initialProgressPercent;
  final void Function(int watchedPercent, int timeSpentSeconds) onProgress;

  @override
  State<JobIntroVideoCard> createState() => _JobIntroVideoCardState();
}

class _JobIntroVideoCardState extends State<JobIntroVideoCard> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  String? _errorMessage;
  int _lastReportedPercent = 0;
  int _lastReportedPositionSeconds = 0;
  int _unreportedWatchSeconds = 0;

  @override
  void initState() {
    super.initState();
    _lastReportedPercent = widget.initialProgressPercent;
  }

  @override
  void dispose() {
    final VideoPlayerController? controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      _reportProgress(controller.value.position, controller.value.duration);
    }
    controller?.removeListener(_onVideoChanged);
    controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isInitializing) return;

    if (_controller == null) {
      await _initializeAndPlay();
      return;
    }

    final VideoPlayerController controller = _controller!;
    if (controller.value.isPlaying) {
      await controller.pause();
      _reportProgress(controller.value.position, controller.value.duration);
    } else {
      if (controller.value.position >= controller.value.duration &&
          controller.value.duration > Duration.zero) {
        await controller.seekTo(Duration.zero);
        _lastReportedPositionSeconds = 0;
      }
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _initializeAndPlay() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    VideoPlayerController? pendingController;
    try {
      pendingController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await pendingController.initialize();
      pendingController.addListener(_onVideoChanged);
      _controller = pendingController;
      pendingController = null;
      await _controller!.play();
    } catch (_) {
      final VideoPlayerController? failedController =
          pendingController ?? _controller;
      failedController?.removeListener(_onVideoChanged);
      await failedController?.dispose();
      _controller = null;
      _errorMessage = 'Unable to load the introduction video.';
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  void _onVideoChanged() {
    final VideoPlayerController? controller = _controller;
    if (!mounted || controller == null) return;

    final VideoPlayerValue value = controller.value;
    _reportProgress(value.position, value.duration);
    setState(() {});
  }

  void _reportProgress(Duration position, Duration duration) {
    if (duration.inMilliseconds <= 0) return;

    final int percent = ((position.inMilliseconds / duration.inMilliseconds) *
            100)
        .round()
        .clamp(0, 100)
        .toInt();
    final bool shouldReport =
        percent >= 100 ||
        (percent >= 80 && _lastReportedPercent < 80) ||
        percent >= _lastReportedPercent + 10;
    if (!shouldReport) return;

    final int currentSeconds = position.inSeconds;
    final int elapsedSeconds = currentSeconds > _lastReportedPositionSeconds
        ? currentSeconds - _lastReportedPositionSeconds
        : 0;
    _unreportedWatchSeconds += elapsedSeconds;
    final bool shouldFlushTime =
        _unreportedWatchSeconds >= 60 || percent >= 100;
    final int timeSpentSeconds = shouldFlushTime
        ? _unreportedWatchSeconds
        : 0;
    if (shouldFlushTime) _unreportedWatchSeconds = 0;

    _lastReportedPercent = percent;
    _lastReportedPositionSeconds = currentSeconds;
    widget.onProgress(percent, timeSpentSeconds);
  }

  Future<void> _seek(double value) async {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final Duration duration = controller.value.duration;
    await controller.seekTo(
      Duration(milliseconds: (duration.inMilliseconds * value).round()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;
    final bool isReady = controller?.value.isInitialized ?? false;
    final bool isPlaying = controller?.value.isPlaying ?? false;
    final Duration position = controller?.value.position ?? Duration.zero;
    final Duration duration = controller?.value.duration ?? Duration.zero;
    final double progress = duration.inMilliseconds <= 0
        ? (widget.initialProgressPercent / 100).clamp(0, 1).toDouble()
        : (position.inMilliseconds / duration.inMilliseconds)
              .clamp(0, 1)
              .toDouble();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111715),
        borderRadius: BorderRadius.circular(36.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36.r),
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: isReady && controller!.value.aspectRatio > 0
                  ? controller.value.aspectRatio
                  : 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (isReady)
                    ColoredBox(
                      color: Colors.black,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: controller!.value.size.width,
                          height: controller.value.size.height,
                          child: VideoPlayer(controller),
                        ),
                      ),
                    )
                  else
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[Color(0xFF263B34), Color(0xFF0D1713)],
                        ),
                      ),
                    ),
                  Center(
                    child: _isInitializing
                        ? const CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                          )
                        : GestureDetector(
                            onTap: _togglePlayback,
                            child: Container(
                              width: 66.r,
                              height: 66.r,
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 36.r,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                  ),
                  if (_errorMessage != null)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.72),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.r),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: AppFont.font14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 14.h),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.h,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 6.r,
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: 12.r,
                        ),
                      ),
                      child: Slider(
                        value: progress,
                        onChanged: isReady ? _seek : null,
                        activeColor: AppColors.primaryGreen,
                        inactiveColor: Colors.white24,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${_formatDuration(position)} / ${_formatDuration(duration)}',
                    style: TextStyle(
                      fontSize: AppFont.font11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration value) {
    final int minutes = value.inMinutes;
    final int seconds = value.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
