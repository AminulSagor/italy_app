import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/course_models.dart';

class SkillBuilderCard extends StatelessWidget {
  final SkillBuilderModel skill;

  const SkillBuilderCard({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    final _SkillTone tone = _SkillTone.fromType(skill.tone);

    return Container(
      height: kSkillCardHeight.h,
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(kSkillCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tone.shadow,
            blurRadius: 0,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(_skillIcon(skill.iconName), color: tone.foreground, size: 34.w),
          SizedBox(height: 16.h),
          Text(
            skill.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font15.sp,
              fontWeight: FontWeight.w900,
              color: tone.foreground,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _skillIcon(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.business_center_rounded;
      case 'workbench':
        return Icons.work_rounded;
      case 'target':
        return Icons.track_changes_rounded;
      case 'bolt':
      default:
        return Icons.bolt_rounded;
    }
  }
}

class _SkillTone {
  final Color background;
  final Color shadow;
  final Color foreground;

  const _SkillTone({
    required this.background,
    required this.shadow,
    required this.foreground,
  });

  factory _SkillTone.fromType(SkillBuilderTone tone) {
    switch (tone) {
      case SkillBuilderTone.yellow:
        return const _SkillTone(
          background: AppColors.coursesYellowSkillBg,
          shadow: AppColors.coursesYellowSkillShadow,
          foreground: AppColors.coursesYellowSkillText,
        );
      case SkillBuilderTone.blue:
        return const _SkillTone(
          background: AppColors.coursesBlueSkillBg,
          shadow: AppColors.coursesBlueSkillShadow,
          foreground: AppColors.coursesBlueSkillText,
        );
      case SkillBuilderTone.pink:
        return const _SkillTone(
          background: AppColors.coursesPinkSkillBg,
          shadow: AppColors.coursesPinkSkillShadow,
          foreground: AppColors.coursesPinkSkillText,
        );
      case SkillBuilderTone.green:
        return const _SkillTone(
          background: AppColors.coursesGreenSkillBg,
          shadow: AppColors.coursesGreenSkillShadow,
          foreground: AppColors.coursesGreenSkillText,
        );
    }
  }
}
