import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../models/practice_hub_models.dart';

class PracticeHubFinalExamCard extends StatelessWidget {
  const PracticeHubFinalExamCard({
    super.key,
    required this.exam,
    required this.onTap,
    required this.onStartTap,
    required this.onWatchMoreLessonsTap,
  });

  final PracticeFinalExamCourseModel exam;
  final VoidCallback onTap;
  final VoidCallback onStartTap;
  final VoidCallback onWatchMoreLessonsTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: exam.isUnlocked
          ? _ReadyFinalExamCard(
              key: ValueKey<String>('ready-${exam.courseId}'),
              exam: exam,
              onTap: onTap,
              onStartTap: onStartTap,
            )
          : _LockedFinalExamCard(
              key: ValueKey<String>('locked-${exam.courseId}'),
              exam: exam,
              onTap: onTap,
              onLockedButtonTap: onWatchMoreLessonsTap,
            ),
    );
  }
}

class _LockedFinalExamCard extends StatelessWidget {
  const _LockedFinalExamCard({
    super.key,
    required this.exam,
    required this.onTap,
    required this.onLockedButtonTap,
  });

  final PracticeFinalExamCourseModel exam;
  final VoidCallback onTap;
  final VoidCallback onLockedButtonTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 236.h),
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 26.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF122E16),
              Color(0xFF193B13),
              Color(0xFF102914),
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24.r,
              offset: Offset(0, 14.h),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: 55.r,
              height: 55.r,
              decoration: const BoxDecoration(
                color: Color(0xFF78FF3E),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.desktop_windows_rounded,
                size: 28.r,
                color: const Color(0xFF102D16),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              exam.courseName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF85FF43),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              exam.examTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              '${exam.courseProgressPercent}% completed • ${exam.unlockCompletionPercent}% required',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF85FF43),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _ExamMiniPill(
                  text: '${exam.unlockCompletionPercent}% Required',
                  icon: Icons.info_outline_rounded,
                  active: true,
                ),
                SizedBox(width: 12.w),
                _ExamMiniPill(
                  text: 'Locked',
                  icon: Icons.lock_rounded,
                  active: false,
                  onTap: onLockedButtonTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyFinalExamCard extends StatelessWidget {
  const _ReadyFinalExamCard({
    super.key,
    required this.exam,
    required this.onTap,
    required this.onStartTap,
  });

  final PracticeFinalExamCourseModel exam;
  final VoidCallback onTap;
  final VoidCallback onStartTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 300.h),
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(32.w, 30.h, 32.w, 30.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF145300),
              Color(0xFF1F6700),
              Color(0xFF123F00),
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 22.r,
              offset: Offset(0, 12.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 76.r,
                  height: 76.r,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF81FF42),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        size: 28.r,
                        color: const Color(0xFF187000),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    exam.courseName,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font20.sp,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              exam.examTitle,
              style: TextStyle(
                fontSize: AppFont.font30.sp,
                height: 1,
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Ready for your final challenge!',
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF86FF45),
              ),
            ),
            SizedBox(height: 28.h),
            CustomButton(
              onPressed: onStartTap,
              text: 'START FINAL EXAM',
              height: 60,
              width: double.infinity,
              showShadow: true,
              btnColor: AppColors.white,
              btnShadowColor: AppColors.black,
              borderColor: AppColors.black,
              textColor: AppColors.black,
              fontSize: AppFont.font16,
              fontWeight: FontWeight.w900,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamMiniPill extends StatelessWidget {
  const _ExamMiniPill({
    required this.text,
    required this.icon,
    required this.active,
    this.onTap,
  });

  final String text;
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget pill = Container(
      height: 28.h,
      padding: EdgeInsets.symmetric(horizontal: 11.w),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF153B0A)
            : AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: active
              ? const Color(0xFF2F7C16)
              : AppColors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 13.r,
            color: active ? const Color(0xFF83FF45) : const Color(0xFFA3A9A0),
          ),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TextStyle(
              fontSize: AppFont.font11.sp,
              fontWeight: FontWeight.w900,
              color: active
                  ? const Color(0xFF83FF45)
                  : const Color(0xFFA3A9A0),
            ),
          ),
        ],
      ),
    );

    return onTap == null
        ? pill
        : GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: pill,
          );
  }
}
