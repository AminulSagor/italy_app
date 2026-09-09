import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../models/ai_tutor_level_test_models.dart';

class AiTutorLevelTestHeader extends StatelessWidget {
  const AiTutorLevelTestHeader({
    super.key,
    required this.title,
    required this.onBackTap,
  });

  final String title;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: onBackTap,
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 24.r,
                color: const Color(0xFF193F34),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF173F33),
                ),
              ),
            ),
          ),
          SizedBox(width: 40.r),
        ],
      ),
    );
  }
}

class AiTutorLevelMeasureCard extends StatelessWidget {
  const AiTutorLevelMeasureCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final compactTextHeight = Get.locale?.languageCode == 'bn' ? 1.25 : 1.0;

    return Container(
      height: 87.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 17.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30.r, color: iconColor),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    height: compactTextHeight,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF303635),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: compactTextHeight,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF636A67),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AiTutorLevelPrimaryButton extends StatelessWidget {
  const AiTutorLevelPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final bool enabled = isEnabled && !isLoading;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        height: 58.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primaryGreen
              : AppColors.primaryGreen.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: isLoading
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.white,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }
}

class AiTutorSkillChip extends StatelessWidget {
  const AiTutorSkillChip({super.key, required this.skill});

  final AiTutorSkillType skill;

  @override
  Widget build(BuildContext context) {
    final ({String label, IconData icon, Color color, Color background}) data =
        switch (skill) {
      AiTutorSkillType.speaking => (
          label: 'gen_speaking_1'.tr,
          icon: Icons.mic_rounded,
          color: const Color(0xFF09649F),
          background: const Color(0xFFDDF1FF),
        ),
      AiTutorSkillType.vocabulary => (
          label: 'gen_vocabulary_1'.tr,
          icon: Icons.chat_bubble_rounded,
          color: const Color(0xFF8A4D00),
          background: const Color(0xFFFFEFD8),
        ),
      AiTutorSkillType.grammar => (
          label: 'gen_grammar_1'.tr,
          icon: Icons.menu_book_rounded,
          color: AppColors.primaryGreen,
          background: const Color(0xFFDDFCE7),
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: data.background,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(data.icon, size: 16.r, color: data.color),
          SizedBox(width: 6.w),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: data.color,
            ),
          ),
        ],
      ),
    );
  }
}
