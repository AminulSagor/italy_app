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


  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ],
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ],
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: ChapterVideoPlayerSurface(
        controller: widget.controller,
        hasWatchedFullyListenable: widget.hasWatchedFullyListenable,
        progressLabel: widget.progressLabel,
        fallbackPositionLabel: widget.fallbackPositionLabel,
        fallbackDurationLabel: widget.fallbackDurationLabel,
        isFullscreen: true,
        onCloseFullscreenTap: () => Navigator.of(context).pop(),
      ),
    );
  }
}
