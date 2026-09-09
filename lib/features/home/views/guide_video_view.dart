import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../core/themes/app_colors.dart';

class GuideVideoView extends StatefulWidget {
  const GuideVideoView({super.key, required this.videoId});

  final String videoId;

  @override
  State<GuideVideoView> createState() => _GuideVideoViewState();
}

class _GuideVideoViewState extends State<GuideVideoView> {
  late final YoutubePlayerController _youtubeController;
  bool _isLoading = true;
  bool _hasLoadError = false;

  @override
  void initState() {
    super.initState();

    _youtubeController = YoutubePlayerController(
      key: widget.videoId,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        playsInline: true,
        enableCaption: true,
        privacyEnhancedMode: true,
        strictRelatedVideos: true,
      ),
    );

    _youtubeController.setFullScreenListener((bool isFullscreen) {
      unawaited(_handleFullscreenChangeSafely(isFullscreen));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadVideo());
    });
  }

  Future<void> _loadVideo() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasLoadError = false;
    });

    try {
      await _youtubeController.loadVideoById(videoId: widget.videoId);
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasLoadError = true;
      });
    }
  }

  Future<void> _handleFullscreenChangeSafely(bool isFullscreen) async {
    try {
      await _handleFullscreenChange(isFullscreen);
    } catch (_) {}
  }

  Future<void> _handleFullscreenChange(bool isFullscreen) async {
    if (isFullscreen) {
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      return;
    }

    await _restorePortraitMode();
  }

  Future<void> _restorePortraitMode() async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    unawaited(_disposePlayerSafely());

    super.dispose();
  }

  Future<void> _disposePlayerSafely() async {
    try {
      await _youtubeController.close();
    } catch (_) {}

    try {
      await _restorePortraitMode();
    } catch (_) {}
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
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                YoutubePlayer(
                  controller: _youtubeController,
                  aspectRatio: 16 / 9,
                  autoFullScreen: true,
                  enableFullScreenOnVerticalDrag: true,
                ),
                if (_isLoading)
                  const ColoredBox(
                    color: Colors.black,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_hasLoadError)
                  ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.videocam_off_outlined,
                            color: Colors.white70,
                            size: 42,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'guide_video_unavailable'.tr,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _loadVideo,
                            child: Text('try_again'.tr),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
