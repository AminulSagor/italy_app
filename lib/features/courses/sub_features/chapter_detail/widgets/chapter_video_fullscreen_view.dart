import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/themes/app_colors.dart';
import 'chapter_video_player_surface.dart';

class ChapterVideoFullscreenView extends StatefulWidget {
  final VideoPlayerController controller;
  final ValueListenable<bool> hasWatchedFullyListenable;
  final String progressLabel;
  final String fallbackPositionLabel;
  final String fallbackDurationLabel;

  const ChapterVideoFullscreenView({
    super.key,
    required this.controller,
    required this.hasWatchedFullyListenable,
    required this.progressLabel,
    required this.fallbackPositionLabel,
    required this.fallbackDurationLabel,
  });

  @override
  State<ChapterVideoFullscreenView> createState() =>
      _ChapterVideoFullscreenViewState();
}

class _ChapterVideoFullscreenViewState
    extends State<ChapterVideoFullscreenView> {
  bool _isClosing = false;
  bool _portraitRestored = false;

  @override
  void initState() {
    super.initState();

    unawaited(_enterFullscreenMode());
  }

  Future<void> _enterFullscreenMode() async {
    /*
     * Fullscreen course videos are allowed to rotate
     * into either landscape direction.
     */
    await SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  Future<void> _restoreNormalScreenMode() async {
    if (_portraitRestored) {
      return;
    }

    /*
     * Restore portrait before closing this route.
     *
     * This prevents the underlying course page from
     * briefly rebuilding with landscape dimensions.
     */
    await SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ],
    );

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    _portraitRestored = true;

    /*
     * Keep the fullscreen route visible until Flutter
     * receives the portrait MediaQuery dimensions.
     */
    if (mounted) {
      await _waitForPortraitLayout();
    }
  }

  Future<void> _waitForPortraitLayout() async {
    const int maximumChecks = 12;

    for (int check = 0; check < maximumChecks; check++) {
      if (!mounted) {
        return;
      }

      final Size screenSize = MediaQuery.sizeOf(context);

      if (screenSize.height >= screenSize.width) {
        await WidgetsBinding.instance.endOfFrame;
        return;
      }

      await Future<void>.delayed(
        const Duration(milliseconds: 30),
      );
    }
  }

  Future<void> _closeFullscreen() async {
    if (_isClosing) {
      return;
    }

    _isClosing = true;

    try {
      await _restoreNormalScreenMode();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } finally {
      _isClosing = false;
    }
  }

  @override
  void dispose() {
    /*
     * Fallback for cases where the route is removed
     * without using the fullscreen close action.
     */
    if (!_portraitRestored) {
      unawaited(
        SystemChrome.setPreferredOrientations(
          <DeviceOrientation>[
            DeviceOrientation.portraitUp,
          ],
        ),
      );

      unawaited(
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
        ),
      );
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (
          bool didPop,
          Object? result,
          ) {
        if (!didPop) {
          unawaited(_closeFullscreen());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: ChapterVideoPlayerSurface(
          controller: widget.controller,
          hasWatchedFullyListenable:
          widget.hasWatchedFullyListenable,
          progressLabel: widget.progressLabel,
          fallbackPositionLabel:
          widget.fallbackPositionLabel,
          fallbackDurationLabel:
          widget.fallbackDurationLabel,
          isFullscreen: true,
          onCloseFullscreenTap: () {
            unawaited(_closeFullscreen());
          },
        ),
      ),
    );
  }
}