import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/user_session_controller.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';

class AiTutorHeader extends StatelessWidget {
  final String title;
  final bool lightBackground;
  final VoidCallback? onBackTap;
  final bool backEnabled;

  const AiTutorHeader({
    super.key,
    this.title = 'AI Tutor',
    this.lightBackground = false,
    this.onBackTap,
    this.backEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: lightBackground
      //     ? const Color(0xFFEFFFF0)
      //     : const Color(0xFFF8FAFA),
      padding: EdgeInsets.fromLTRB(24.w, 13.h, 24.w, 0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 38.h,
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: backEnabled ? (onBackTap ?? Get.back<void>) : null,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: backEnabled ? 1 : .35,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 22.r,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: AppFont.font14.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 22.r),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          const AiTutorCreditRow(),
        ],
      ),
    );
  }
}

class AiTutorCreditRow extends GetView<UserSessionController> {
  const AiTutorCreditRow({super.key});

  @override
  UserSessionController get controller => Get.find<UserSessionController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: <Widget>[
          AiTutorMiniChip(
            icon: Icons.diamond_rounded,
            label: controller.aiTextBalanceLabel,
          ),
          const Spacer(),
          AiTutorMiniChip(
            icon: Icons.mic_rounded,
            label: controller.aiVoiceBalanceLabel,
          ),
        ],
      ),
    );
  }
}

class AiTutorMiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const AiTutorMiniChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16.r, color: AppColors.primaryGreen),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF526053),
            ),
          ),
        ],
      ),
    );
  }
}

class AiTutorDateChip extends StatelessWidget {
  const AiTutorDateChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 20.h,
        padding: EdgeInsets.symmetric(horizontal: 11.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(13.r),
        ),
        child: Text(
          'today'.tr,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFA0A6A4),
          ),
        ),
      ),
    );
  }
}

class AiTutorWaveform extends StatefulWidget {
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;
  final bool dense;
  final bool animate;
  final bool thinking;
  final double audioLevel;

  const AiTutorWaveform({
    super.key,
    required this.activeColor,
    this.inactiveColor = const Color(0xFFE2E8E2),
    this.width = 70,
    this.height = 28,
    this.dense = false,
    this.animate = false,
    this.thinking = false,
    this.audioLevel = 0,
  });

  @override
  State<AiTutorWaveform> createState() => _AiTutorWaveformState();
}

class _AiTutorWaveformState extends State<AiTutorWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant AiTutorWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.thinking != widget.thinking) {
      _animationController.duration = Duration(
        milliseconds: widget.thinking ? 660 : 900,
      );
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width.w,
      height: widget.height.h,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget? child) {
          if (!widget.animate) {
            return _buildThinkingDots();
          }
          return _buildAudioBars();
        },
      ),
    );
  }

  Widget _buildThinkingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List<Widget>.generate(5, (int index) {
        final double phase =
            (_animationController.value * math.pi * 2) - (index * .68);
        final double wave = (math.sin(phase) + 1) / 2;
        final double offset = -(wave * (widget.thinking ? 9 : 6));
        final double scale = .72 + (wave * .38);

        return Transform.translate(
          offset: Offset(0, offset.h),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: (widget.dense ? 5 : 7).r,
              height: (widget.dense ? 5 : 7).r,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: widget.activeColor.withValues(
                  alpha: .48 + (wave * .52),
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAudioBars() {
    final List<double> bars = widget.dense
        ? <double>[.25, .55, .36, .8, .5, .92, .65, .35, .75, .48]
        : <double>[
            .20,
            .35,
            .52,
            .78,
            .42,
            .92,
            .65,
            .48,
            .86,
            .55,
            .33,
            .72,
            .44,
            .22,
          ];
    final double audioEnergy = math.sqrt(
      widget.audioLevel.clamp(0.0, 1.0).toDouble(),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List<Widget>.generate(bars.length, (int index) {
        final double phase =
            (_animationController.value * math.pi * 2) + (index * .72);
        final double normalizedWave = (math.sin(phase) + 1) / 2;
        final double energy = .22 + (audioEnergy * .78);
        final double movement = .58 + (normalizedWave * .42);
        final double barHeight =
            (widget.height * bars[index] * energy * movement)
                .clamp(4.0, widget.height)
                .toDouble();

        return Container(
          width: widget.dense ? 2.2.w : 2.6.w,
          height: barHeight.h,
          margin: EdgeInsets.symmetric(
            horizontal: widget.dense ? 1.2.w : 1.6.w,
          ),
          decoration: BoxDecoration(
            color: audioEnergy > .04
                ? widget.activeColor
                : widget.inactiveColor,
            borderRadius: BorderRadius.circular(999.r),
          ),
        );
      }),
    );
  }
}

class AiTutorInputBar extends StatelessWidget {
  final TextEditingController controller;
  final String inputText;
  final ValueChanged<String> onChanged;
  final VoidCallback onSendTap;
  final VoidCallback? onVoiceTap;
  final bool showVoiceAction;
  final String hint;

  const AiTutorInputBar({
    super.key,
    required this.controller,
    required this.inputText,
    required this.onChanged,
    required this.onSendTap,
    this.onVoiceTap,
    this.showVoiceAction = true,
    this.hint = 'Type or speak a phrase...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.h,
      padding: EdgeInsets.fromLTRB(18.w, 0, 7.w, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(31.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: (_) => onSendTap(),
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF26312E),
              ),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9AA29F),
                ),
              ),
            ),
          ),
          if (showVoiceAction && onVoiceTap != null) ...<Widget>[
            GestureDetector(
              onTap: onVoiceTap,
              child: Icon(
                Icons.graphic_eq_rounded,
                size: 18.r,
                color: const Color(0xFF50605A),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          GestureDetector(
            onTap: onSendTap,
            child: Container(
              width: 42.r,
              height: 42.r,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                size: 20.r,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AiTutorTypingDots extends StatelessWidget {
  const AiTutorTypingDots({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(3, (int index) {
        return Container(
          width: 5.r,
          height: 5.r,
          margin: EdgeInsets.only(right: 6.w),
          decoration: BoxDecoration(
            color: index == 1
                ? AppColors.primaryGreen
                : AppColors.primaryGreen.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
