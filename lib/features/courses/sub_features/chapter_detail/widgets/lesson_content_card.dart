import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/chapter_detail_models.dart';

class LessonContentCard extends StatelessWidget {
  final LessonContentModel lesson;
  final ChapterMediaModel? audio;
  final Future<String?> Function() loadAudioUrl;
  final VoidCallback onAudioCompleted;

  const LessonContentCard({
    super.key,
    required this.lesson,
    required this.audio,
    required this.loadAudioUrl,
    required this.onAudioCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasItalianContent =
        lesson.italianText.trim().isNotEmpty ||
            lesson.italianHighlightText.trim().isNotEmpty ||
            lesson.italianMissingText.trim().isNotEmpty;

    final bool hasBanglaContent =
        lesson.banglaText.trim().isNotEmpty ||
            lesson.banglaHighlightText.trim().isNotEmpty;

    final bool hasAudio = audio?.fileId.trim().isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (lesson.title.trim().isNotEmpty)
          Text(
            lesson.title,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
              height: 1.25,
            ),
          ),

        if (hasAudio) ...<Widget>[
          SizedBox(height: 20.h),
          _AudioPlayerControls(
            audioUrl: audio!.url,
            loadAudioUrl: loadAudioUrl,
            onAudioCompleted: onAudioCompleted,
          ),
        ],

        if (hasItalianContent) ...<Widget>[
          SizedBox(height: 24.h),
          _TheoryTextPanel(lesson: lesson),
        ],

        if (hasBanglaContent) ...<Widget>[
          SizedBox(height: 24.h),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.legacyColorFFD0D1D2,
          ),
          SizedBox(height: 20.h),
          _TranslationPanel(lesson: lesson),
        ],
      ],
    );
  }
}

class _AudioPlayerControls extends StatefulWidget {
  final String audioUrl;
  final Future<String?> Function() loadAudioUrl;
  final VoidCallback onAudioCompleted;

  const _AudioPlayerControls({
    required this.audioUrl,
    required this.loadAudioUrl,
    required this.onAudioCompleted,
  });

  @override
  State<_AudioPlayerControls> createState() =>
      _AudioPlayerControlsState();
}

class _AudioPlayerControlsState extends State<_AudioPlayerControls> {
  late final AudioPlayer _audioPlayer;

  StreamSubscription<PlayerState>? _playerStateSubscription;

  double _speed = 1;
  bool _isMuted = false;
  bool _isPreparing = false;
  bool _isPrepared = false;
  bool _hasReportedCompletion = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      _handlePlayerState,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_prepareAudio());
      }
    });
  }

  @override
  void didUpdateWidget(covariant _AudioPlayerControls oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.audioUrl != widget.audioUrl) {
      unawaited(_resetSource());
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    unawaited(_audioPlayer.dispose());

    super.dispose();
  }

  Future<void> _resetSource() async {
    await _audioPlayer.stop();

    if (!mounted) {
      return;
    }

    setState(() {
      _isPreparing = false;
      _isPrepared = false;
      _hasReportedCompletion = false;
      _errorMessage = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_prepareAudio());
      }
    });
  }

  void _handlePlayerState(PlayerState state) {
    if (state.processingState != ProcessingState.completed ||
        _hasReportedCompletion) {
      return;
    }

    _hasReportedCompletion = true;
    widget.onAudioCompleted();
  }

  Future<bool> _prepareAudio() async {
    if (_isPrepared) {
      return true;
    }

    if (_isPreparing) {
      return false;
    }

    if (!mounted) {
      return false;
    }

    setState(() {
      _isPreparing = true;
      _errorMessage = null;
    });

    try {
      String audioUrl = widget.audioUrl.trim();

      if (audioUrl.isEmpty) {
        audioUrl = (await widget.loadAudioUrl())?.trim() ?? '';
      }

      if (audioUrl.isEmpty) {
        throw StateError('audio_url_is_not_available'.tr);
      }

      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.setSpeed(_speed);
      await _audioPlayer.setVolume(_isMuted ? 0 : 1);

      if (!mounted) {
        return false;
      }

      setState(() {
        _isPreparing = false;
        _isPrepared = true;
        _errorMessage = null;
      });

      return true;
    } catch (error, stackTrace) {
      debugPrint('Audio preparation failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return false;
      }

      setState(() {
        _isPreparing = false;
        _isPrepared = false;
        _errorMessage =
            'audio_could_not_be_loaded_tap_play_to_retry'.tr;
      });

      return false;
    }
  }

  Future<void> _togglePlay() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      return;
    }

    final bool isReady = await _prepareAudio();

    if (!isReady) {
      return;
    }

    if (_audioPlayer.processingState == ProcessingState.completed) {
      await _audioPlayer.seek(Duration.zero);
    }

    await _audioPlayer.play();
  }

  Future<void> _setSpeed(double speed) async {
    if (_speed == speed) {
      return;
    }

    setState(() {
      _speed = speed;
    });

    if (_isPrepared) {
      await _audioPlayer.setSpeed(speed);
    }
  }

  Future<void> _toggleMute() async {
    final bool nextMutedState = !_isMuted;

    setState(() {
      _isMuted = nextMutedState;
    });

    await _audioPlayer.setVolume(nextMutedState ? 0 : 1);
  }

  Future<void> _seekTo(double milliseconds) async {
    final Duration duration =
        _audioPlayer.duration ?? Duration.zero;

    if (!_isPrepared || duration.inMilliseconds <= 0) {
      return;
    }

    final int targetMilliseconds = milliseconds
        .round()
        .clamp(0, duration.inMilliseconds)
        .toInt();

    await _audioPlayer.seek(
      Duration(milliseconds: targetMilliseconds),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StreamBuilder<Duration?>(
          stream: _audioPlayer.durationStream,
          initialData: _audioPlayer.duration,
          builder: (
              BuildContext context,
              AsyncSnapshot<Duration?> durationSnapshot,
              ) {
            final Duration duration =
                durationSnapshot.data ?? Duration.zero;

            return StreamBuilder<Duration>(
              stream: _audioPlayer.positionStream,
              initialData: _audioPlayer.position,
              builder: (
                  BuildContext context,
                  AsyncSnapshot<Duration> positionSnapshot,
                  ) {
                Duration position =
                    positionSnapshot.data ?? Duration.zero;

                if (duration.inMilliseconds > 0 &&
                    position > duration) {
                  position = duration;
                }

                final double maximum =
                duration.inMilliseconds.toDouble();

                final double currentValue = maximum <= 0
                    ? 0
                    : position.inMilliseconds
                    .clamp(0, duration.inMilliseconds)
                    .toDouble();

                return Column(
                  children: <Widget>[
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6.h,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 8.r,
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: 14.r,
                        ),
                        activeTrackColor: AppColors.primaryGreen,
                        inactiveTrackColor:
                        AppColors.legacyColorFFD0D1D2,
                        thumbColor: AppColors.primaryGreen,
                        overlayColor: AppColors.primaryGreen.withValues(
                          alpha: 0.14,
                        ),
                        trackShape:
                        const RoundedRectSliderTrackShape(),
                      ),
                      child: Slider(
                        value: currentValue,
                        min: 0,
                        max: maximum <= 0 ? 1 : maximum,
                        onChanged:
                        !_isPrepared || maximum <= 0
                            ? null
                            : (double newValue) {
                          unawaited(_seekTo(newValue));
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          _durationLabel(position),
                          style: _durationStyle(),
                        ),
                        Text(
                          _durationLabel(duration),
                          style: _durationStyle(),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),

        if (_errorMessage != null) ...<Widget>[
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blockDangerRed,
                height: 1.35,
              ),
            ),
          ),
        ],

        SizedBox(height: 18.h),

        LayoutBuilder(
          builder: (
              BuildContext context,
              BoxConstraints constraints,
              ) {
            final bool useCompactLayout =
                constraints.maxWidth < 340.w;

            if (useCompactLayout) {
              return Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _AudioIconButton(
                        icon: _isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        semanticLabel: _isMuted
                            ? 'unmute'.tr
                            : 'mute'.tr,
                        onTap: _toggleMute,
                      ),
                      _buildPlayPauseButton(),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Align(
                    alignment: Alignment.center,
                    child: _PlaybackSpeedSelector(
                      selectedSpeed: _speed,
                      onSpeedChanged: _setSpeed,
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: <Widget>[
                _AudioIconButton(
                  icon: _isMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  semanticLabel: _isMuted
                      ? 'unmute'.tr
                      : 'mute'.tr,
                  onTap: _toggleMute,
                ),
                Expanded(
                  child: Center(
                    child: _PlaybackSpeedSelector(
                      selectedSpeed: _speed,
                      onSpeedChanged: _setSpeed,
                    ),
                  ),
                ),
                _buildPlayPauseButton(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      initialData: _audioPlayer.playerState,
      builder: (
          BuildContext context,
          AsyncSnapshot<PlayerState> snapshot,
          ) {
        final PlayerState? state = snapshot.data;

        final bool isBuffering =
            _isPreparing ||
                state?.processingState == ProcessingState.loading ||
                state?.processingState == ProcessingState.buffering;

        final bool isPlaying = state?.playing ?? false;

        return _AudioIconButton(
          icon: isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          semanticLabel: isPlaying ? 'pause'.tr : 'play'.tr,
          isPrimary: true,
          isLoading: isBuffering,
          onTap: isBuffering ? null : _togglePlay,
        );
      },
    );
  }

  TextStyle _durationStyle() {
    return TextStyle(
      fontSize: AppFont.font12.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.bodyText,
    );
  }

  String _durationLabel(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    final String paddedMinutes = minutes
        .toString()
        .padLeft(2, '0');

    final String paddedSeconds = seconds
        .toString()
        .padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$paddedMinutes:$paddedSeconds';
    }

    return '$minutes:$paddedSeconds';
  }
}

class _TheoryTextPanel extends StatefulWidget {
  final LessonContentModel lesson;

  const _TheoryTextPanel({
    required this.lesson,
  });

  @override
  State<_TheoryTextPanel> createState() => _TheoryTextPanelState();
}

class _TheoryTextPanelState extends State<_TheoryTextPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final LessonContentModel lesson = widget.lesson;

    final String previewText = <String>[
      lesson.italianText,
      lesson.italianHighlightText,
      lesson.italianMissingText,
    ].where((String text) => text.trim().isNotEmpty).join(' ');

    if (!_isExpanded) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              previewText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _bodyStyle(),
            ),
          ),

          SizedBox(width: 6.w),

          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = true;
              });
            },
            child: Text(
              'See more',
              style: TextStyle(
                fontSize: AppFont.font13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (lesson.italianText.trim().isNotEmpty)
          Text(
            lesson.italianText,
            style: _bodyStyle(),
          ),

        if (lesson.italianHighlightText.trim().isNotEmpty) ...<Widget>[
          SizedBox(height: 10.h),
          Text(
            lesson.italianHighlightText,
            style: _bodyStyle().copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
              letterSpacing: 0.2,
            ),
          ),
        ],

        if (lesson.italianMissingText.trim().isNotEmpty) ...<Widget>[
          SizedBox(height: 12.h),
          Text(
            lesson.italianMissingText,
            style: _bodyStyle().copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.blockDangerRed,
            ),
          ),
        ],

        SizedBox(height: 6.h),

        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = false;
            });
          },
          child: Text(
            'See less',
            style: TextStyle(
              fontSize: AppFont.font13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _bodyStyle() {
    return TextStyle(
      fontSize: AppFont.font16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.bodyText,
      height: 1.55,
    );
  }
}

class _TranslationPanel extends StatefulWidget {
  final LessonContentModel lesson;

  const _TranslationPanel({
    required this.lesson,
  });

  @override
  State<_TranslationPanel> createState() => _TranslationPanelState();
}

class _TranslationPanelState extends State<_TranslationPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final LessonContentModel lesson = widget.lesson;

    final String translatedText = <String>[
      lesson.banglaText,
      lesson.banglaHighlightText,
    ].where((String item) => item.trim().isNotEmpty).join('\n\n');

    final TextStyle textStyle = TextStyle(
      fontSize: AppFont.font16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.black,
      height: 1.55,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (lesson.translationLabel.trim().isNotEmpty) ...<Widget>[
          SizedBox(
            width: double.infinity,
            child: Text(
              lesson.translationLabel,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: AppFont.font11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.bodyText.withValues(alpha: 0.65),
                height: 1.35,
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],

        if (!_isExpanded)
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  translatedText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),

              SizedBox(width: 6.w),

              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = true;
                  });
                },
                child: Text(
                  'See more',
                  style: TextStyle(
                    fontSize: AppFont.font13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          )
        else ...<Widget>[
          Text(
            translatedText,
            style: textStyle,
          ),

          SizedBox(height: 6.h),

          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = false;
              });
            },
            child: Text(
              'See less',
              style: TextStyle(
                fontSize: AppFont.font13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PlaybackSpeedSelector extends StatelessWidget {
  final double selectedSpeed;
  final ValueChanged<double> onSpeedChanged;

  const _PlaybackSpeedSelector({
    required this.selectedSpeed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFF1F2F2,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _SpeedPill(
            label: 'gen_0_75'.tr,
            isSelected: selectedSpeed == 0.75,
            onTap: () => onSpeedChanged(0.75),
          ),
          SizedBox(width: 4.w),
          _SpeedPill(
            label: 'gen_1'.tr,
            isSelected: selectedSpeed == 1,
            onTap: () => onSpeedChanged(1),
          ),
          SizedBox(width: 4.w),
          _SpeedPill(
            label: 'gen_1_25'.tr,
            isSelected: selectedSpeed == 1.25,
            onTap: () => onSpeedChanged(1.25),
          ),
        ],
      ),
    );
  }
}

class _SpeedPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpeedPill({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected
            ? AppColors.primaryGreen
            : Colors.transparent,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
          child: Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 11.w),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppFont.font11.sp,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? AppColors.white
                    : AppColors.homePrimaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isPrimary;

  const _AudioIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.isLoading = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isPrimary
        ? AppColors.primaryGreen
        : AppColors.white;

    final Color foregroundColor = isPrimary
        ? AppColors.white
        : AppColors.primaryGreen;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48.w,
            height: 48.w,
            child: Center(
              child: isLoading
                  ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: foregroundColor,
                ),
              )
                  : Icon(
                icon,
                color: foregroundColor,
                size: 25.w,
              ),
            ),
          ),
        ),
      ),
    );
  }
}