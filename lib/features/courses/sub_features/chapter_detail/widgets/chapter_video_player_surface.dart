import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/chapter_detail_models.dart';

class ChapterVideoPlayerSurface extends StatefulWidget {
  final VideoPlayerController controller;
  final ValueListenable<bool> hasWatchedFullyListenable;
  final String progressLabel;
  final String fallbackPositionLabel;
  final String fallbackDurationLabel;
  final bool isFullscreen;
  final bool showSettings;
  final List<ChapterVideoQualityOption> qualityOptions;
  final ValueListenable<String>? selectedQualityListenable;
  final Future<void> Function(ChapterVideoQualityOption? quality)?
  onQualityChanged;
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
    this.showSettings = false,
    this.qualityOptions = const <ChapterVideoQualityOption>[],
    this.selectedQualityListenable,
    this.onQualityChanged,
    this.onFullscreenTap,
    this.onCloseFullscreenTap,
  });

  @override
  State<ChapterVideoPlayerSurface> createState() =>
      _ChapterVideoPlayerSurfaceState();
}

class _ChapterVideoPlayerSurfaceState extends State<ChapterVideoPlayerSurface> {
  static const Duration _controlsHideDelay = Duration(seconds: 1);
  static const List<double> _playbackSpeeds = <double>[
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

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

  void _handleVideoTap() {
    if (_showControls) {
      _controlsHideTimer?.cancel();
      setState(() => _showControls = false);
      return;
    }

    _showControlsTemporarily();
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

    await widget.controller.seekTo(
      Duration(milliseconds: targetMilliseconds),
    );
    _showControlsTemporarily();
  }

  Future<void> _seekBy(Duration offset) async {
    final VideoPlayerValue value = widget.controller.value;
    if (!value.isInitialized || value.duration.inMilliseconds <= 0) {
      return;
    }

    final int targetMilliseconds =
        (value.position + offset).inMilliseconds.clamp(
              0,
              value.duration.inMilliseconds,
            );

    await widget.controller.seekTo(
      Duration(milliseconds: targetMilliseconds),
    );
    _showControlsTemporarily();
  }

  Future<void> _showSettingsSheet() async {
    _showControlsPersistently();

    final _VideoSettingsAction? action =
    await showModalBottomSheet<_VideoSettingsAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return _VideoBottomSheetFrame(
          title: 'Settings',
          children: <Widget>[
            if (widget.onQualityChanged != null)
              _VideoSettingsTile(
                icon: Icons.high_quality_rounded,
                title: 'Quality',
                value: widget.selectedQualityListenable?.value ?? 'Auto',
                onTap: () {
                  Navigator.of(sheetContext).pop(
                    _VideoSettingsAction.quality,
                  );
                },
              ),
            _VideoSettingsTile(
              icon: Icons.speed_rounded,
              title: 'Playback speed',
              value: _speedLabel(widget.controller.value.playbackSpeed),
              onTap: () {
                Navigator.of(sheetContext).pop(
                  _VideoSettingsAction.playbackSpeed,
                );
              },
            ),
          ],
        );
      },
    );

    if (!mounted || action == null) {
      _scheduleControlsHideIfPlaying();
      return;
    }

    switch (action) {
      case _VideoSettingsAction.quality:
        await _showQualitySheet();
        break;
      case _VideoSettingsAction.playbackSpeed:
        await _showPlaybackSpeedSheet();
        break;
    }

    _showControlsTemporarily();
  }

  Future<void> _showPlaybackSpeedSheet() async {
    final double currentSpeed = widget.controller.value.playbackSpeed;

    final double? selectedSpeed = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return _VideoBottomSheetFrame(
          title: 'Playback speed',
          children: _playbackSpeeds.map((double speed) {
            return _VideoSelectionTile(
              title: _speedLabel(speed),
              isSelected: (currentSpeed - speed).abs() < 0.001,
              onTap: () => Navigator.of(sheetContext).pop(speed),
            );
          }).toList(growable: false),
        );
      },
    );

    if (selectedSpeed == null || !mounted) {
      return;
    }

    try {
      await widget.controller.setPlaybackSpeed(selectedSpeed);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to change playback speed.'),
          ),
        );
      }
    }
  }

  Future<void> _showQualitySheet() async {
    final Future<void> Function(ChapterVideoQualityOption? quality)?
    onQualityChanged = widget.onQualityChanged;

    if (onQualityChanged == null) {
      return;
    }

    final String currentLabel =
        widget.selectedQualityListenable?.value ?? 'Auto';

    final String? selectedLabel = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return _VideoBottomSheetFrame(
          title: 'Quality',
          children: <Widget>[
            _VideoSelectionTile(
              title: 'Auto',
              subtitle: 'Recommended',
              isSelected: currentLabel == 'Auto',
              onTap: () => Navigator.of(sheetContext).pop('Auto'),
            ),
            ...widget.qualityOptions.reversed.map(
                  (ChapterVideoQualityOption quality) => _VideoSelectionTile(
                title: quality.label,
                isSelected: currentLabel == quality.label,
                onTap: () =>
                    Navigator.of(sheetContext).pop(quality.label),
              ),
            ),
          ],
        );
      },
    );

    if (selectedLabel == null || selectedLabel == currentLabel || !mounted) {
      return;
    }

    ChapterVideoQualityOption? selectedQuality;
    if (selectedLabel != 'Auto') {
      for (final ChapterVideoQualityOption quality in widget.qualityOptions) {
        if (quality.label == selectedLabel) {
          selectedQuality = quality;
          break;
        }
      }

      if (selectedQuality == null) {
        return;
      }
    }

    await onQualityChanged(selectedQuality);
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

    return value.position >=
        value.duration - const Duration(milliseconds: 400);
  }

  String _speedLabel(double speed) {
    if (speed == speed.roundToDouble()) {
      return '${speed.toInt()}x';
    }

    return '${speed.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')}x';
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
                    showSettings: widget.showSettings,
                    onSettingsTap: _showSettingsSheet,
                    onPlayPauseTap: _togglePlayback,
                    onRewindTap: () => _seekBy(const Duration(seconds: -10)),
                    onForwardTap: () => _seekBy(const Duration(seconds: 10)),
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
  final bool showSettings;
  final VoidCallback onSettingsTap;
  final VoidCallback onPlayPauseTap;
  final VoidCallback onRewindTap;
  final VoidCallback onForwardTap;
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
    required this.showSettings,
    required this.onSettingsTap,
    required this.onPlayPauseTap,
    required this.onRewindTap,
    required this.onForwardTap,
    required this.onSeek,
    this.onFullscreenTap,
    this.onCloseFullscreenTap,
  });

  @override

  Widget build(BuildContext context) {
    final double playButtonSize = isFullscreen ? 58 : 64.w;
    final double playIconSize = isFullscreen ? 34 : 38.w;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.black.withValues(alpha: 0.28),
            AppColors.black.withValues(alpha: 0.04),
            AppColors.black.withValues(alpha: 0.82),
          ],
          stops: const <double>[0, 0.48, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          /*
         * Settings now stays at the top-right.
         */
          if (showSettings)
            Positioned(
              top: isFullscreen ? 8 : 6.h,
              right: isFullscreen ? 8 : 6.w,
              child: _VideoActionButton(
                tooltip: 'Settings',
                icon: Icons.settings_rounded,
                isFullscreen: isFullscreen,
                onTap: onSettingsTap,
              ),
            ),

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _VideoActionButton(
                  tooltip: 'Back 10 seconds',
                  icon: Icons.replay_10_rounded,
                  isFullscreen: isFullscreen,
                  onTap: value.isBuffering ? null : onRewindTap,
                ),
                SizedBox(width: isFullscreen ? 14 : 14.w),
                GestureDetector(
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
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: AppColors.white,
                              size: playIconSize,
                            ),
                    ),
                  ),
                ),
                SizedBox(width: isFullscreen ? 14 : 14.w),
                _VideoActionButton(
                  tooltip: 'Forward 10 seconds',
                  icon: Icons.forward_10_rounded,
                  isFullscreen: isFullscreen,
                  onTap: value.isBuffering ? null : onForwardTap,
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: isFullscreen ? 8 : 6.w,
                  ),
                  child: _BottomVideoActions(
                    isFullscreen: isFullscreen,
                    onFullscreenTap: onFullscreenTap,
                    onCloseFullscreenTap: onCloseFullscreenTap,
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
        ],
      ),
    );
  }
}

class _BottomVideoActions extends StatelessWidget {
  final bool isFullscreen;
  final VoidCallback? onFullscreenTap;
  final VoidCallback? onCloseFullscreenTap;

  const _BottomVideoActions({
    required this.isFullscreen,
    this.onFullscreenTap,
    this.onCloseFullscreenTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _VideoActionButton(
          tooltip: isFullscreen ? 'Exit fullscreen' : 'Fullscreen',
          icon: isFullscreen
              ? Icons.close_fullscreen_rounded
              : Icons.fullscreen_rounded,
          isFullscreen: isFullscreen,
          onTap: isFullscreen
              ? onCloseFullscreenTap
              : onFullscreenTap,
        ),
      ],
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

    final double fontSize =
    isFullscreen ? 12 : AppFont.font12.sp;

    final double horizontalGap =
    isFullscreen ? 8 : 8.w;

    final double verticalGap =
    isFullscreen ? 4 : 4.h;

    final double trackHeight =
    isFullscreen ? 3 : 3.h;

    final double horizontalPadding =
    isFullscreen ? 12 : 12.w;

    final double progressTouchHeight =
    isFullscreen ? 16 : 16.h;

    return ValueListenableBuilder<bool>(
      valueListenable: hasWatchedFullyListenable,
      builder: (
          BuildContext context,
          bool hasWatchedFully,
          Widget? child,
          ) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Row(
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
                    '${_durationLabel(
                      position,
                      fallbackPositionLabel,
                    )} / '
                        '${_durationLabel(
                      duration,
                      fallbackDurationLabel,
                    )}',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      color: AppColors.homeLime,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: verticalGap),
            LayoutBuilder(
              builder: (
                  BuildContext context,
                  BoxConstraints constraints,
                  ) {
                void seekToPosition(double horizontalPosition) {
                  if (duration.inMilliseconds <= 0 ||
                      constraints.maxWidth <= 0) {
                    return;
                  }

                  final double seekProgress =
                  (horizontalPosition / constraints.maxWidth)
                      .clamp(0.0, 1.0)
                      .toDouble();

                  final double targetMilliseconds =
                      seekProgress * duration.inMilliseconds;

                  onSeek(targetMilliseconds);
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,

                  onTapDown: (TapDownDetails details) {
                    seekToPosition(details.localPosition.dx);
                  },

                  onHorizontalDragStart: (DragStartDetails details) {
                    seekToPosition(details.localPosition.dx);
                  },

                  onHorizontalDragUpdate: (DragUpdateDetails details) {
                    seekToPosition(details.localPosition.dx);
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: progressTouchHeight,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: trackHeight,
                        color: AppColors.homeLime,
                        backgroundColor:
                        AppColors.chapterProgressTrack,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _durationLabel(
      Duration duration,
      String fallback,
      ) {
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
  final String tooltip;
  final IconData icon;
  final bool isFullscreen;
  final VoidCallback? onTap;

  const _VideoActionButton({
    required this.tooltip,
    required this.icon,
    required this.isFullscreen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = isFullscreen ? 28 : 27.w;
    final double buttonSize = isFullscreen ? 42 : 40.w;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(
          width: buttonSize,
          height: buttonSize,
        ),
        splashRadius: buttonSize / 2,
        icon: Icon(
          icon,
          color: AppColors.white,
          size: iconSize,
        ),
      ),
    );
  }
}

enum _VideoSettingsAction {
  quality,
  playbackSpeed,
}

class _VideoBottomSheetFrame extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _VideoBottomSheetFrame({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 10),
                  children: children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _VideoSettingsTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _VideoSelectionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _VideoSelectionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 24,
        child: isSelected
            ? const Icon(Icons.check, size: 22)
            : const SizedBox.shrink(),
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      onTap: onTap,
    );
  }
}
