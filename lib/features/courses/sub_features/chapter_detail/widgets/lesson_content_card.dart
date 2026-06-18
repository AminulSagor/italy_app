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
  final VoidCallback onAudioStarted;

  const LessonContentCard({
    super.key,
    required this.lesson,
    required this.audio,
    required this.onAudioStarted,
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
          if (audio?.url.isNotEmpty == true) ...<Widget>[
            SizedBox(height: 24.h),
            _AudioPlayerControls(
              audioUrl: audio!.url,
              onAudioStarted: onAudioStarted,
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
  final VoidCallback onAudioStarted;

  const _AudioPlayerControls({
    required this.audioUrl,
    required this.onAudioStarted,
  });

  @override
  State<_AudioPlayerControls> createState() => _AudioPlayerControlsState();
}

class _AudioPlayerControlsState extends State<_AudioPlayerControls> {
  late final AudioPlayer _audioPlayer;
  double _speed = 1;
  bool _hasRecordedListen = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(widget.audioUrl);
  }

  @override
  void didUpdateWidget(covariant _AudioPlayerControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _audioPlayer.setUrl(widget.audioUrl);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      return;
    }

    if (!_hasRecordedListen) {
      _hasRecordedListen = true;
      widget.onAudioStarted();
    }
    await _audioPlayer.play();
  }

  Future<void> _setSpeed(double speed) async {
    setState(() => _speed = speed);
    await _audioPlayer.setSpeed(speed);
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
                    onChanged: max <= 0
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
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _CircleIcon(icon: Icons.volume_up_rounded, onTap: () {}),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.legacyColorFFF1F2F2,
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
              ),
              child: Row(
                children: <Widget>[
                  _SpeedPill(
                    label: '0.75×',
                    isSelected: _speed == 0.75,
                    onTap: () => _setSpeed(0.75),
                  ),
                  4.w.horizontalSpace,
                  _SpeedPill(
                    label: '1×',
                    isSelected: _speed == 1,
                    onTap: () => _setSpeed(1),
                  ),
                  4.w.horizontalSpace,
                  _SpeedPill(
                    label: '1.25×',
                    isSelected: _speed == 1.25,
                    onTap: () => _setSpeed(1.25),
                  ),
                ],
              ),
            ),
            StreamBuilder<bool>(
              stream: _audioPlayer.playingStream,
              builder: (_, AsyncSnapshot<bool> snapshot) {
                final bool isPlaying = snapshot.data ?? false;
                return _CircleIcon(
                  icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  onTap: _togglePlay,
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
            Text(
              lesson.italianText,
              style: _bodyStyle(),
            ),
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
            '—${lesson.translationLabel}—',
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
          [lesson.banglaText, lesson.banglaHighlightText]
              .where((String item) => item.trim().isNotEmpty)
              .join('\n'),
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
  final VoidCallback onTap;

  const _CircleIcon({required this.icon, required this.onTap});

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
        child: Icon(icon, color: AppColors.primaryGreen, size: 25.w),
      ),
    );
  }
}
