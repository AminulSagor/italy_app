import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class ChapterVideoPlayerSurface extends StatefulWidget {
  final VideoPlayerController controller;
  final ValueListenable<bool> hasWatchedFullyListenable;
  final String progressLabel;
  final String fallbackPositionLabel;
  final String fallbackDurationLabel;
  final bool isFullscreen;
  final VoidCallback? onFullscreenTap;
  final VoidCallback? onCloseFullscreenTap;

  const ChapterVideoPlayerSurface({
    super.key,
    required this.controller,
    required this.hasWatchedFullyListenable,
    required this.progressLabel,
    required this.fallbackPositionLabel,
    required this.fallbackDurationLabel,
    this.isFullscreen = false,
    this.onFullscreenTap,
    this.onCloseFullscreenTap,
  });

  @override
  State<ChapterVideoPlayerSurface> createState() =>
      _ChapterVideoPlayerSurfaceState();
}

class _ChapterVideoPlayerSurfaceState extends State<ChapterVideoPlayerSurface> {
  static const Duration _controlsHideDelay = Duration(seconds: 1);

  Timer? _controlsHideTimer;
  bool _showControls = true;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    _wasPlaying = widget.controller.value.isPlaying;
    widget.controller.addListener(_handlePlaybackStateChanged);
    if (_wasPlaying) {
      _scheduleControlsHide();
    }
  }

  @override
  void didUpdateWidget(covariant ChapterVideoPlayerSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }

    oldWidget.controller.removeListener(_handlePlaybackStateChanged);
    widget.controller.addListener(_handlePlaybackStateChanged);
    _wasPlaying = widget.controller.value.isPlaying;
    _showControls = true;
    _scheduleControlsHideIfPlaying();
  }

  @override
  void dispose() {
    _controlsHideTimer?.cancel();
    widget.controller.removeListener(_handlePlaybackStateChanged);
    super.dispose();
  }

  void _handlePlaybackStateChanged() {
    final bool isPlaying = widget.controller.value.isPlaying;
    if (isPlaying == _wasPlaying) {
      return;
    }

    _wasPlaying = isPlaying;
    if (isPlaying) {
      _showControlsTemporarily();
    } else {
      _showControlsPersistently();
    }
  }

  Future<void> _handleVideoTap() async {
    if (widget.controller.value.isPlaying) {
      await widget.controller.pause();
      _showControlsPersistently();
      return;
    }

    _showControlsPersistently();
  }

  Future<void> _togglePlayback() async {
    final VideoPlayerValue value = widget.controller.value;
    if (!value.isInitialized || value.isBuffering) {
      return;
    }

    if (value.isPlaying) {
      await widget.controller.pause();
      _showControlsPersistently();
      return;
    }

    if (_isAtVideoEnd(value)) {
      await widget.controller.seekTo(Duration.zero);
    }

    await widget.controller.play();
    _showControlsTemporarily();
  }

  Future<void> _seekTo(double milliseconds) async {
    final Duration duration = widget.controller.value.duration;
    if (duration.inMilliseconds <= 0) {
      return;
    }

    final int targetMilliseconds = milliseconds
        .round()
        .clamp(0, duration.inMilliseconds)
        .toInt();
    await widget.controller.seekTo(Duration(milliseconds: targetMilliseconds));
    _showControlsTemporarily();
  }

  void _showControlsPersistently() {
    _controlsHideTimer?.cancel();
    if (!_showControls && mounted) {
      setState(() => _showControls = true);
    }
  }

  void _showControlsTemporarily() {
    if (!_showControls && mounted) {
      setState(() => _showControls = true);
    }
    _scheduleControlsHideIfPlaying();
  }

  void _scheduleControlsHideIfPlaying() {
    if (widget.controller.value.isPlaying) {
      _scheduleControlsHide();
    }
  }

  void _scheduleControlsHide() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = Timer(_controlsHideDelay, () {
      if (!mounted || !widget.controller.value.isPlaying) {
        return;
      }
      setState(() => _showControls = false);
    });
  }

  bool _isAtVideoEnd(VideoPlayerValue value) {
    if (value.duration.inMilliseconds <= 0) {
      return false;
    }
    return value.position >= value.duration - const Duration(milliseconds: 400);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.controller,
      builder: (BuildContext context, VideoPlayerValue value, Widget? child) {
        final bool controlsVisible =
            value.isBuffering || !value.isPlaying || _showControls;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleVideoTap,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const ColoredBox(color: AppColors.black),
              _FittedVideo(controller: widget.controller),
              IgnorePointer(
                ignoring: !controlsVisible,
                child: AnimatedOpacity(
                  opacity: controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: _VideoControlsOverlay(
                    value: value,
                    progressLabel: widget.progressLabel,
                    fallbackPositionLabel: widget.fallbackPositionLabel,
                    fallbackDurationLabel: widget.fallbackDurationLabel,
                    hasWatchedFullyListenable:
                        widget.hasWatchedFullyListenable,
                    isFullscreen: widget.isFullscreen,
                    onPlayPauseTap: _togglePlayback,
                    onSeek: _seekTo,
                    onFullscreenTap: widget.onFullscreenTap,
                    onCloseFullscreenTap: widget.onCloseFullscreenTap,
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

class _FittedVideo extends StatelessWidget {
  final VideoPlayerController controller;

  const _FittedVideo({required this.controller});

  @override
  Widget build(BuildContext context) {
    final double aspectRatio = controller.value.aspectRatio > 0
        ? controller.value.aspectRatio
        : 16 / 9;

    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _VideoControlsOverlay extends StatelessWidget {
  final VideoPlayerValue value;
  final String progressLabel;
  final String fallbackPositionLabel;
  final String fallbackDurationLabel;
  final ValueListenable<bool> hasWatchedFullyListenable;
  final bool isFullscreen;
  final VoidCallback onPlayPauseTap;
  final ValueChanged<double> onSeek;
  final VoidCallback? onFullscreenTap;
  final VoidCallback? onCloseFullscreenTap;

  const _VideoControlsOverlay({
    required this.value,
    required this.progressLabel,
    required this.fallbackPositionLabel,
    required this.fallbackDurationLabel,
    required this.hasWatchedFullyListenable,
    required this.isFullscreen,
    required this.onPlayPauseTap,
    required this.onSeek,
    this.onFullscreenTap,
    this.onCloseFullscreenTap,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = isFullscreen
        ? const EdgeInsets.fromLTRB(20, 12, 20, 14)
        : EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 24.h);
    final double playButtonSize = isFullscreen ? 58 : 64.w;
    final double playIconSize = isFullscreen ? 34 : 38.w;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.black.withValues(alpha: 0.42),
            AppColors.black.withValues(alpha: 0.05),
            AppColors.black.withValues(alpha: 0.78),
          ],
          stops: const <double>[0, 0.48, 1],
        ),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          children: <Widget>[
            _TopVideoActions(
              isFullscreen: isFullscreen,
              onFullscreenTap: onFullscreenTap,
              onCloseFullscreenTap: onCloseFullscreenTap,
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: value.isBuffering ? null : onPlayPauseTap,
                  child: Container(
                    width: playButtonSize,
                    height: playButtonSize,
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.42),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Center(
                      child: value.isBuffering
                          ? SizedBox(
                              width: playIconSize * 0.7,
                              height: playIconSize * 0.7,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.white,
                              ),
                            )
                          : Icon(
                              value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.white,
                              size: playIconSize,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            _VideoProgressControls(
              value: value,
              progressLabel: progressLabel,
              fallbackPositionLabel: fallbackPositionLabel,
              fallbackDurationLabel: fallbackDurationLabel,
              hasWatchedFullyListenable: hasWatchedFullyListenable,
              isFullscreen: isFullscreen,
              onSeek: onSeek,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopVideoActions extends StatelessWidget {
  final bool isFullscreen;
  final VoidCallback? onFullscreenTap;
  final VoidCallback? onCloseFullscreenTap;

  const _TopVideoActions({
    required this.isFullscreen,
    this.onFullscreenTap,
    this.onCloseFullscreenTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: _VideoActionButton(
        icon: isFullscreen
            ? Icons.fullscreen_exit_rounded
            : Icons.fullscreen_rounded,
        isFullscreen: isFullscreen,
        onTap: isFullscreen ? onCloseFullscreenTap : onFullscreenTap,
      ),
    );
  }
}

class _VideoProgressControls extends StatelessWidget {
  final VideoPlayerValue value;
  final String progressLabel;
  final String fallbackPositionLabel;
  final String fallbackDurationLabel;
  final ValueListenable<bool> hasWatchedFullyListenable;
  final bool isFullscreen;
  final ValueChanged<double> onSeek;

  const _VideoProgressControls({
    required this.value,
    required this.progressLabel,
    required this.fallbackPositionLabel,
    required this.fallbackDurationLabel,
    required this.hasWatchedFullyListenable,
    required this.isFullscreen,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final Duration duration = value.duration;
    final Duration position =
        value.position > duration && duration.inMilliseconds > 0
            ? duration
            : value.position;
    final double progress = duration.inMilliseconds <= 0
        ? 0
        : (position.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();
    final double fontSize = isFullscreen ? 12 : AppFont.font12.sp;
    final double horizontalGap = isFullscreen ? 8 : 8.w;
    final double verticalGap = isFullscreen ? 6 : 8.h;
    final double trackHeight = isFullscreen ? 5 : 8.h;

    return ValueListenableBuilder<bool>(
      valueListenable: hasWatchedFullyListenable,
      builder: (BuildContext context, bool hasWatchedFully, Widget? child) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    progressLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                SizedBox(width: horizontalGap),
                Text(
                  '${_durationLabel(position, fallbackPositionLabel)} / '
                  '${_durationLabel(duration, fallbackDurationLabel)}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homeLime,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            SizedBox(height: verticalGap),
            if (hasWatchedFully)
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: trackHeight,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: isFullscreen ? 5.5 : 7.r,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: isFullscreen ? 10 : 13.r,
                  ),
                  activeTrackColor: AppColors.homeLime,
                  inactiveTrackColor: AppColors.chapterProgressTrack,
                  thumbColor: AppColors.homeLime,
                  overlayColor: AppColors.homeLime.withValues(alpha: 0.2),
                  trackShape: const RoundedRectSliderTrackShape(),
                ),
                child: Slider(
                  value: duration.inMilliseconds <= 0
                      ? 0
                      : position.inMilliseconds
                          .clamp(0, duration.inMilliseconds)
                          .toDouble(),
                  min: 0,
                  max: duration.inMilliseconds <= 0
                      ? 1
                      : duration.inMilliseconds.toDouble(),
                  onChanged: duration.inMilliseconds <= 0 ? null : onSeek,
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  isFullscreen ? 999 : kHomePillRadius.r,
                ),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: trackHeight,
                  color: AppColors.homeLime,
                  backgroundColor: AppColors.chapterProgressTrack,
                ),
              ),
          ],
        );
      },
    );
  }

  String _durationLabel(Duration duration, String fallback) {
    if (duration == Duration.zero && fallback.isNotEmpty) {
      return fallback;
    }

    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _VideoActionButton extends StatelessWidget {
  final IconData icon;
  final bool isFullscreen;
  final VoidCallback? onTap;

  const _VideoActionButton({
    required this.icon,
    required this.isFullscreen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonSize = isFullscreen ? 38 : 42.w;
    final double iconSize = isFullscreen ? 22 : 24.w;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.48),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: AppColors.white, size: iconSize),
      ),
    );
  }
}
