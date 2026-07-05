import 'package:get/get.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(34.w, 36.h, 34.w, 30.h),
      decoration: BoxDecoration(
        color: AppColors.chapterContentCardBg,
        borderRadius: BorderRadius.circular(kChapterContentCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 0,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            lesson.title,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
            ),
          ),
          if (audio?.fileId.isNotEmpty == true) ...<Widget>[
            SizedBox(height: 24.h),
            _AudioPlayerControls(
              audioUrl: audio!.url,
              loadAudioUrl: loadAudioUrl,
              onAudioCompleted: onAudioCompleted,
            ),
          ],
          if (lesson.italianText.isNotEmpty ||
              lesson.italianHighlightText.isNotEmpty ||
              lesson.italianMissingText.isNotEmpty) ...<Widget>[
            SizedBox(height: 24.h),
            _TheoryTextPanel(lesson: lesson),
          ],
          if (lesson.banglaText.isNotEmpty ||
              lesson.banglaHighlightText.isNotEmpty) ...<Widget>[
            Divider(height: 28.h),
            _TranslationPanel(lesson: lesson),
          ],
        ],
      ),
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
  State<_AudioPlayerControls> createState() => _AudioPlayerControlsState();
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
      _resetSource();
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _resetSource() async {
    await _audioPlayer.stop();
    if (!mounted) return;

    setState(() {
      _isPreparing = false;
      _isPrepared = false;
      _hasReportedCompletion = false;
      _errorMessage = null;
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

    setState(() {
      _isPreparing = true;
      _errorMessage = null;
    });

    try {
      String audioUrl = widget.audioUrl;
      if (audioUrl.isEmpty) {
        audioUrl = await widget.loadAudioUrl() ?? '';
      }
      if (audioUrl.isEmpty) {
        throw StateError('audio_url_is_not_available'.tr);
      }

      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.setSpeed(_speed);
      await _audioPlayer.setVolume(_isMuted ? 0 : 1);

      if (!mounted) return false;
      setState(() {
        _isPreparing = false;
        _isPrepared = true;
      });
      return true;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _isPreparing = false;
        _isPrepared = false;
        _errorMessage = 'audio_could_not_be_loaded_tap_play_to_retry'.tr;
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
    setState(() => _speed = speed);
    if (_isPrepared) {
      await _audioPlayer.setSpeed(speed);
    }
  }

  Future<void> _toggleMute() async {
    final bool nextMutedState = !_isMuted;
    setState(() => _isMuted = nextMutedState);
    await _audioPlayer.setVolume(nextMutedState ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        StreamBuilder<Duration>(
          stream: _audioPlayer.positionStream,
          builder: (_, AsyncSnapshot<Duration> snapshot) {
            final Duration position = snapshot.data ?? Duration.zero;
            final Duration duration = _audioPlayer.duration ?? Duration.zero;
            final double max = duration.inMilliseconds.toDouble();
            final double value = position.inMilliseconds
                .clamp(0, duration.inMilliseconds)
                .toDouble();

            return Column(
              children: <Widget>[
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 10.h,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: AppColors.primaryGreen,
                    inactiveTrackColor: AppColors.legacyColorFFD0D1D2,
                    thumbColor: AppColors.primaryGreen,
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: max <= 0 ? 0 : value,
                    min: 0,
                    max: max <= 0 ? 1 : max,
                    onChanged: !_isPrepared || max <= 0
                        ? null
                        : (double newValue) {
                            _audioPlayer.seek(
                              Duration(milliseconds: newValue.round()),
                            );
                          },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_durationLabel(position), style: _durationStyle()),
                    Text(_durationLabel(duration), style: _durationStyle()),
                  ],
                ),
              ],
            );
          },
        ),
        if (_errorMessage != null) ...<Widget>[
          SizedBox(height: 8.h),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blockDangerRed,
            ),
          ),
        ],
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _CircleIcon(
              icon: _isMuted
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
              onTap: _toggleMute,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.legacyColorFFF1F2F2,
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
              ),
              child: Row(
                children: <Widget>[
                  _SpeedPill(
                    label: 'gen_0_75'.tr,
                    isSelected: _speed == 0.75,
                    onTap: () => _setSpeed(0.75),
                  ),
                  4.w.horizontalSpace,
                  _SpeedPill(
                    label: 'gen_1'.tr,
                    isSelected: _speed == 1,
                    onTap: () => _setSpeed(1),
                  ),
                  4.w.horizontalSpace,
                  _SpeedPill(
                    label: 'gen_1_25'.tr,
                    isSelected: _speed == 1.25,
                    onTap: () => _setSpeed(1.25),
                  ),
                ],
              ),
            ),
            StreamBuilder<PlayerState>(
              stream: _audioPlayer.playerStateStream,
              builder: (_, AsyncSnapshot<PlayerState> snapshot) {
                final PlayerState? state = snapshot.data;
                final bool isBuffering =
                    _isPreparing ||
                    state?.processingState == ProcessingState.loading ||
                    state?.processingState == ProcessingState.buffering;
                final bool isPlaying = state?.playing ?? false;

                return _CircleIcon(
                  icon: isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  isLoading: isBuffering,
                  onTap: isBuffering ? null : _togglePlay,
                );
              },
            ),
          ],
        ),
      ],
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
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _TheoryTextPanel extends StatelessWidget {
  final LessonContentModel lesson;

  const _TheoryTextPanel({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.chapterTextPanelBg,
        borderRadius: BorderRadius.circular(kRadius20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (lesson.italianText.isNotEmpty)
            Text(lesson.italianText, style: _bodyStyle()),
          if (lesson.italianHighlightText.isNotEmpty) ...<Widget>[
            SizedBox(height: 8.h),
            Text(
              lesson.italianHighlightText,
              style: _bodyStyle().copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
                letterSpacing: 1.2,
              ),
            ),
          ],
          if (lesson.italianMissingText.isNotEmpty) ...<Widget>[
            SizedBox(height: 12.h),
            Text(
              lesson.italianMissingText,
              style: _bodyStyle().copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.blockDangerRed,
              ),
            ),
          ],
        ],
      ),
    );
  }

  TextStyle _bodyStyle() {
    return TextStyle(
      fontSize: AppFont.font16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.bodyText,
      height: 1.45,
    );
  }
}

class _TranslationPanel extends StatelessWidget {
  final LessonContentModel lesson;

  const _TranslationPanel({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Text(
            'lesson_translationlabel'.trParams(<String, String>{'translationlabel': lesson.translationLabel.toString()}),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyText.withAlpha(150),
              height: 1.45,
            ),
          ),
        ),
        8.h.verticalSpace,
        Text(
          [
            lesson.banglaText,
            lesson.banglaHighlightText,
          ].where((String item) => item.trim().isNotEmpty).join('\n'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
            height: 1.4,
          ),
        ),
      ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.white,
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppFont.font11.sp,
            fontWeight: FontWeight.w800,
            color: isSelected ? AppColors.white : AppColors.homePrimaryText,
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const _CircleIcon({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryGreen,
                  ),
                )
              : Icon(icon, color: AppColors.primaryGreen, size: 25.w),
        ),
      ),
    );
  }
}
