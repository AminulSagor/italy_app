import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/video_playback_wakelock.dart';

class GuideFaqVideoPlayer extends StatefulWidget {
  final String assetPath;

  const GuideFaqVideoPlayer({super.key, required this.assetPath});

  @override
  State<GuideFaqVideoPlayer> createState() => _GuideFaqVideoPlayerState();
}

class _GuideFaqVideoPlayerState extends State<GuideFaqVideoPlayer> {
  VideoPlayerController? _videoController;
  final VideoPlaybackWakelock _playbackWakelock = VideoPlaybackWakelock();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeVideo());
  }

  @override
  void didUpdateWidget(covariant GuideFaqVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      unawaited(_initializeVideo());
    }
  }

  Future<void> _initializeVideo() async {
    final VideoPlayerController? previousController = _videoController;
    _videoController = null;
    _errorMessage = null;

    if (previousController != null) {
      _playbackWakelock.detach();
      await previousController.dispose();
    }

    final VideoPlayerController controller = VideoPlayerController.asset(
      widget.assetPath,
    );

    try {
      await controller.initialize();
      await controller.setLooping(false);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
      });
      _playbackWakelock.attach(controller);
    } catch (_) {
      await controller.dispose();

      if (!mounted) return;

      setState(() {
        _errorMessage = 'This guide video is currently unavailable.';
      });
    }
  }

  Future<void> _togglePlayback() async {
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      if (controller.value.position >= controller.value.duration) {
        await controller.seekTo(Duration.zero);
      }
      await controller.play();
    }
  }

  @override
  void dispose() {
    _playbackWakelock.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _videoController;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 188.h),
      decoration: BoxDecoration(
        color: const Color(0xFF183F3D),
        borderRadius: BorderRadius.circular(42.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(42.r),
        child: _buildContent(controller),
      ),
    );
  }

  Widget _buildContent(VideoPlayerController? controller) {
    if (_errorMessage != null) {
      return _VideoStatusView(
        icon: Icons.videocam_off_rounded,
        message: _errorMessage!,
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return const _VideoLoadingView();
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (BuildContext context, VideoPlayerValue value, Widget? child) {
        final double aspectRatio = value.aspectRatio > 0
            ? value.aspectRatio
            : 16 / 9;

        return AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: _togglePlayback,
                child: VideoPlayer(controller),
              ),
              if (!value.isPlaying)
                ColoredBox(color: Colors.black.withValues(alpha: 0.22)),
              Center(
                child: Semantics(
                  button: true,
                  label: value.isPlaying
                      ? 'pause_guide_video'.tr
                      : 'play_guide_video'.tr,
                  child: GestureDetector(
                    onTap: _togglePlayback,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: value.isPlaying ? 0 : 1,
                      child: Container(
                        width: 70.r,
                        height: 70.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFF79F535),
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 12.r,
                              offset: Offset(0, 6.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 42.r,
                          color: const Color(0xFF0D6200),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18.w,
                right: 18.w,
                bottom: 18.h,
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  colors: const VideoProgressColors(
                    playedColor: Color(0xFF79F535),
                    bufferedColor: Color(0x99FFFFFF),
                    backgroundColor: Color(0x55FFFFFF),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VideoLoadingView extends StatelessWidget {
  const _VideoLoadingView();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 188.h,
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF79F535)),
      ),
    );
  }
}

class _VideoStatusView extends StatelessWidget {
  final IconData icon;
  final String message;

  const _VideoStatusView({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 188.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 36.r, color: Colors.white),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
