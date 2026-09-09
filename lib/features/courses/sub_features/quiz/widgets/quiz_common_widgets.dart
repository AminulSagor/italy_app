import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';

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
    final double progress = total <= 0
        ? 0
        : (current / total).clamp(0.0, 1.0).toDouble();

    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onCloseTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 40.w,
            height: 40.w,
            child: Icon(
              Icons.close_rounded,
              color: AppColors.bodyText,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              kHomePillRadius.r,
            ),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: kQuizTopProgressHeight.h,
              color: AppColors.primaryGreen,
              backgroundColor: AppColors.quizProgressTrack,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          constraints: BoxConstraints(
            minWidth: 58.w,
            minHeight: 36.h,
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.legacyColorFFF1F2F2,
            borderRadius: BorderRadius.circular(
              kHomePillRadius.r,
            ),
          ),
          child: Text(
            'current_total'.trParams(
              <String, String>{
                'current': current.toString(),
                'total': total.toString(),
              },
            ),
            maxLines: 1,
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
  final bool isExamMode;
  final Widget? feedback;
  final VoidCallback onCheckTap;
  final VoidCallback onNextTap;
  final VoidCallback? onSkipTap;

  const QuizBottomAction({
    super.key,
    required this.showWrongResult,
    required this.isLoading,
    required this.onCheckTap,
    required this.onNextTap,
    this.isExamMode = false,
    this.feedback,
    this.onSkipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        kQuizHorizontalPadding.w,
        showWrongResult ? 20.h : 16.h,
        kQuizHorizontalPadding.w,
        12.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kRadius16.r),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 14.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: isExamMode
            ? Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onSkipTap,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(54.h),
                  side: const BorderSide(
                    color: AppColors.primaryGreen,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      kHomePillRadius.r,
                    ),
                  ),
                ),
                child: Text(
                  'skip'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomButton.primary(
                text: 'submit'.tr,
                isLoading: isLoading,
                onPressed: onCheckTap,
              ),
            ),
          ],
        )
            : showWrongResult
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (feedback != null) feedback!,
            if (feedback != null) SizedBox(height: 14.h),
            CustomButton.primary(
              text: 'next_question'.tr,
              onPressed: onNextTap,
            ),
          ],
        )
            : CustomButton.primary(
          text: 'check_answer'.tr,
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
    final Color backgroundColor = isWrong
        ? AppColors.quizWrongBg
        : isSelected
        ? AppColors.homeLime
        : AppColors.white;

    final Color borderColor = isWrong
        ? AppColors.quizWrongBorder
        : isSelected
        ? AppColors.chapterSelectedGreenBorder
        : AppColors.quizAnswerShadow;

    final Color shadowColor = isWrong
        ? AppColors.quizWrongShadow
        : isSelected
        ? AppColors.primaryBtnShadow
        : AppColors.quizAnswerShadow;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: height.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 18.w,
          vertical: 14.h,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radius.r),
          border: Border.all(
            color: borderColor,
            width: 2.w,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadowColor,
              blurRadius: 0,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w800,
            color: isWrong
                ? AppColors.quizWrongShadow
                : AppColors.homePrimaryText,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

class AudioPromptCard extends StatefulWidget {
  final String audioUrl;
  final bool compact;

  const AudioPromptCard({
    super.key,
    required this.audioUrl,
    this.compact = false,
  });

  @override
  State<AudioPromptCard> createState() =>
      _AudioPromptCardState();
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

    _playerStateSubscription =
        _player.playerStateStream.listen(
              (PlayerState state) {
            if (!mounted) {
              return;
            }

            final bool isCompleted =
                state.processingState == ProcessingState.completed;

            setState(() {
              _isPlaying = state.playing && !isCompleted;
              _isLoading =
                  state.processingState == ProcessingState.loading ||
                      state.processingState == ProcessingState.buffering;
            });

            if (isCompleted && state.playing) {
              unawaited(_player.pause());
            }
          },
        );

    unawaited(_loadAudio());
  }

  @override
  void didUpdateWidget(covariant AudioPromptCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.audioUrl != widget.audioUrl) {
      unawaited(_loadAudio());
    }
  }

  Future<void> _loadAudio() async {
    await _player.stop();

    if (!mounted) {
      return;
    }

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
        _hasError = true;
        _isPlaying = false;
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_isLoading || _hasError) {
      return;
    }

    if (_player.processingState == ProcessingState.completed) {
      await _player.pause();
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _cycleSpeed() async {
    if (_isLoading || _hasError) {
      return;
    }

    final int nextIndex =
        (_speedIndex + 1) % _speeds.length;

    await _player.setSpeed(_speeds[nextIndex]);

    if (!mounted) {
      return;
    }

    setState(() {
      _speedIndex = nextIndex;
    });
  }

  Future<void> _restartAudio() async {
    if (_isLoading || _hasError) {
      return;
    }

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
    final double iconSize = widget.compact ? 70.w : 82.w;
    final double playButtonSize = widget.compact ? 56.w : 62.w;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 18.w,
        vertical: widget.compact ? 24.h : 30.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          kCourseDetailCardRadius.r,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 0,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: iconSize,
            height: iconSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.homeLime,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _hasError
                  ? Icons.audio_file_rounded
                  : Icons.volume_up_rounded,
              color: AppColors.primaryGreen,
              size: widget.compact ? 34.sp : 42.sp,
            ),
          ),
          SizedBox(height: widget.compact ? 22.h : 28.h),
          Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: _RoundAudioButton(
                    label: 'audio_speed_multiplier'.trParams(
                      <String, String>{
                        'speed': _formatSpeed(_speed),
                      },
                    ),
                    isEnabled: !_isLoading && !_hasError,
                    onTap: _cycleSpeed,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: _togglePlayback,
                    behavior: HitTestBehavior.opaque,
                    child: Opacity(
                      opacity: _hasError ? 0.45 : 1,
                      child: Container(
                        width: playButtonSize,
                        height: playButtonSize,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: _isLoading
                            ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child:
                          const CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.white,
                          size: 30.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: _RoundAudioButton(
                    icon: Icons.replay_rounded,
                    isEnabled: !_isLoading && !_hasError,
                    onTap: _restartAudio,
                  ),
                ),
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
  final String? label;
  final IconData? icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const _RoundAudioButton({
    this.label,
    this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.45,
        child: Container(
          width: 46.w,
          height: 46.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.legacyColorFFF1F2F2,
            shape: BoxShape.circle,
          ),
          child: icon == null
              ? FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
              ),
              child: Text(
                label ?? '',
                maxLines: 1,
                style: TextStyle(
                  fontSize: AppFont.font12.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.bodyText,
                ),
              ),
            ),
          )
              : Icon(
            icon,
            color: AppColors.bodyText,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}
