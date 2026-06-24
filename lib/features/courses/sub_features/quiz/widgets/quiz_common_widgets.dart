import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class QuizTopBar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback onCloseTap;

  const QuizTopBar({
    super.key,
    required this.current,
    required this.total,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : current / total;

    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onCloseTap,
          child: Icon(
            Icons.close_rounded,
            color: AppColors.bodyText,
            size: 20.w,
          ),
        ),
        SizedBox(width: 28.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: kQuizTopProgressHeight.h,
              color: AppColors.primaryGreen,
              backgroundColor: AppColors.quizProgressTrack,
            ),
          ),
        ),
        SizedBox(width: 24.w),
        Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.legacyColorFFF1F2F2,
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
          ),
          child: Text(
            '$current/$total',
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.bodyText,
            ),
          ),
        ),
      ],
    );
  }
}

class QuizBottomAction extends StatelessWidget {
  final bool showWrongResult;
  final bool isLoading;
  final Widget? feedback;
  final VoidCallback onCheckTap;
  final VoidCallback onNextTap;

  const QuizBottomAction({
    super.key,
    required this.showWrongResult,
    required this.isLoading,
    required this.onCheckTap,
    required this.onNextTap,
    this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        kQuizHorizontalPadding.w,
        showWrongResult ? 28.h : 20.h,
        kQuizHorizontalPadding.w,
        24.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadius16.r)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 22.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: showWrongResult
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ?feedback,
                  SizedBox(height: 18.h),
                  CustomButton.primary(
                    text: 'Next Question',
                    onPressed: onNextTap,
                  ),
                ],
              )
            : CustomButton.primary(
                text: 'Check Answer',
                isLoading: isLoading,
                onPressed: onCheckTap,
              ),
      ),
    );
  }
}

class CustomQuizButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isWrong;
  final double height;
  final double radius;

  const CustomQuizButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isWrong = false,
    this.height = kQuizOptionHeight,
    this.radius = kRadius48,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isWrong
        ? AppColors.quizWrongBg
        : isSelected
        ? AppColors.homeLime
        : AppColors.white;
    final Color border = isWrong
        ? AppColors.quizWrongBorder
        : isSelected
        ? AppColors.chapterSelectedGreenBorder
        : AppColors.quizAnswerShadow;
    final Color shadow = isWrong
        ? AppColors.quizWrongShadow
        : isSelected
        ? AppColors.primaryBtnShadow
        : AppColors.quizAnswerShadow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius.r),
          border: Border.all(color: border, width: 2.w),
          boxShadow: <BoxShadow>[
            BoxShadow(color: shadow, blurRadius: 0, offset: Offset(0, 8.h)),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font18.sp,
            fontWeight: FontWeight.w900,
            color: isWrong
                ? AppColors.quizWrongShadow
                : AppColors.homePrimaryText,
          ),
        ),
      ),
    );
  }
}

class AudioPromptCard extends StatefulWidget {
  const AudioPromptCard({
    super.key,
    required this.audioUrl,
    this.compact = false,
  });

  final String audioUrl;
  final bool compact;

  @override
  State<AudioPromptCard> createState() => _AudioPromptCardState();
}

class _AudioPromptCardState extends State<AudioPromptCard> {
  static const List<double> _speeds = <double>[
    0.5,
    0.75,
    1,
    1.25,
    1.5,
    2,
  ];

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isPlaying = false;
  int _speedIndex = 2;

  double get _speed => _speeds[_speedIndex];

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _player.playerStateStream.listen(
      (PlayerState state) {
        if (!mounted) return;
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      },
    );
    _loadAudio();
  }

  @override
  void didUpdateWidget(covariant AudioPromptCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _loadAudio();
    }
  }

  Future<void> _loadAudio() async {
    await _player.stop();
    if (!mounted) return;

    if (widget.audioUrl.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _isPlaying = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _isPlaying = false;
    });

    try {
      await _player.setUrl(widget.audioUrl.trim());
      await _player.setSpeed(_speed);
      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_isLoading || _hasError) return;

    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }

    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _cycleSpeed() async {
    if (_isLoading || _hasError) return;

    final int nextIndex = (_speedIndex + 1) % _speeds.length;
    await _player.setSpeed(_speeds[nextIndex]);
    if (!mounted) return;
    setState(() => _speedIndex = nextIndex);
  }

  Future<void> _restartAudio() async {
    if (_isLoading || _hasError) return;
    await _player.seek(Duration.zero);
    await _player.play();
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = widget.compact ? 230.h : 280.h;

    return Container(
      height: cardHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 0,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(widget.compact ? 18.w : 24.w),
            decoration: const BoxDecoration(
              color: AppColors.homeLime,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _hasError ? Icons.audio_file_rounded : Icons.volume_up_rounded,
              color: AppColors.primaryGreen,
              size: widget.compact ? 40.w : 50.w,
            ),
          ),
          SizedBox(height: widget.compact ? 30.h : 46.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _RoundAudioButton(
                label: '${_formatSpeed(_speed)}x',
                onTap: _cycleSpeed,
              ),
              SizedBox(width: 48.w),
              GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  width: 64.w,
                  height: 64.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.white,
                          size: 32.w,
                        ),
                ),
              ),
              SizedBox(width: 48.w),
              _RoundAudioButton(
                icon: Icons.replay_rounded,
                onTap: _restartAudio,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSpeed(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}

class _RoundAudioButton extends StatelessWidget {
  const _RoundAudioButton({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.legacyColorFFF1F2F2,
          shape: BoxShape.circle,
        ),
        child: icon == null
            ? Text(
                label ?? '',
                style: TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.bodyText,
                ),
              )
            : Icon(icon, color: AppColors.bodyText, size: 20.w),
      ),
    );
  }
}
