import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../core/themes/app_colors.dart';

class GuideVideoView extends StatefulWidget {
  const GuideVideoView({
    super.key,
    required this.videoId,
  });

  final String videoId;

  @override
  State<GuideVideoView> createState() =>
      _GuideVideoViewState();
}

class _GuideVideoViewState extends State<GuideVideoView> {
  late final YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();

    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        playsInline: true,
        enableCaption: true,
        privacyEnhancedMode: true,
        strictRelatedVideos: true,
      ),
    );

    _youtubeController.setFullScreenListener(
          (bool isFullscreen) {
        unawaited(
          _handleFullscreenChange(isFullscreen),
        );
      },
    );
  }

  Future<void> _handleFullscreenChange(
      bool isFullscreen,
      ) async {
    if (isFullscreen) {
      await SystemChrome.setPreferredOrientations(
        <DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );

      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );

      return;
    }

    await _restorePortraitMode();
  }

  Future<void> _restorePortraitMode() async {
    await SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ],
    );

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }

  @override
  void dispose() {
    unawaited(_youtubeController.close());
    unawaited(_restorePortraitMode());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('guide_video'.tr),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: YoutubePlayer(
            controller: _youtubeController,
            aspectRatio: 16 / 9,
            autoFullScreen: true,
            enableFullScreenOnVerticalDrag: true,
          ),
        ),
      ),
    );
  }
}