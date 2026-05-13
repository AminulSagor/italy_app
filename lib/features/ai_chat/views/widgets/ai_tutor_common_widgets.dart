import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';

class AiTutorHeader extends StatelessWidget {
  final String title;
  final bool lightBackground;

  const AiTutorHeader({
    super.key,
    this.title = 'AI Tutor',
    this.lightBackground = false,
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
                  onTap: Get.back<void>,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 22.r,
                    color: AppColors.primaryGreen,
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

class AiTutorCreditRow extends StatelessWidget {
  const AiTutorCreditRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        AiTutorMiniChip(icon: Icons.diamond_rounded, label: '1.2k Tokens'),
        Spacer(),
        AiTutorMiniChip(icon: Icons.mic_rounded, label: '45m Voice'),
      ],
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
          'TODAY',
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

class AiTutorWaveform extends StatelessWidget {
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;
  final bool dense;

  const AiTutorWaveform({
    super.key,
    required this.activeColor,
    this.inactiveColor = const Color(0xFFE2E8E2),
    this.width = 70,
    this.height = 28,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<double> bars = dense
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

    return SizedBox(
      width: width.w,
      height: height.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List<Widget>.generate(bars.length, (int index) {
          final bool active = index < bars.length * .72;
          return Container(
            width: dense ? 2.2.w : 2.6.w,
            height: (height * bars[index]).h,
            margin: EdgeInsets.symmetric(horizontal: dense ? 1.2.w : 1.6.w),
            decoration: BoxDecoration(
              color: active ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(999.r),
            ),
          );
        }),
      ),
    );
  }
}

class AiTutorInputBar extends StatelessWidget {
  final TextEditingController controller;
  final String inputText;
  final ValueChanged<String> onChanged;
  final VoidCallback onSendTap;
  final VoidCallback onMicTap;
  final VoidCallback onEqTap;
  final String hint;

  const AiTutorInputBar({
    super.key,
    required this.controller,
    required this.inputText,
    required this.onChanged,
    required this.onSendTap,
    required this.onMicTap,
    required this.onEqTap,
    this.hint = 'Type or speak a phrase...',
  });

  @override
  Widget build(BuildContext context) {
    final bool hasText = inputText.trim().isNotEmpty;

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
          GestureDetector(
            onTap: onEqTap,
            child: Icon(
              Icons.graphic_eq_rounded,
              size: 18.r,
              color: const Color(0xFF50605A),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: hasText ? onSendTap : onMicTap,
            child: Container(
              width: 42.r,
              height: 42.r,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasText ? Icons.send_rounded : Icons.mic_rounded,
                size: hasText ? 20.r : 22.r,
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
