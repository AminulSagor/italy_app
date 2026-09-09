import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
      duration: const Duration(milliseconds: 240),
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
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 18.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
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
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 16.r,
              offset: Offset(0, 7.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 44.r,
              height: 44.r,
              decoration: const BoxDecoration(
                color: Color(0xFF78FF3E),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.desktop_windows_rounded,
                size: 22.r,
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
                fontSize: AppFont.font13.sp,
                height: 1.2,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF85FF43),
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              exam.examTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'exam_progress_requirement'.trParams(
                <String, String>{
                  'progress': exam.courseProgressPercent.toString(),
                  'required': exam.unlockCompletionPercent.toString(),
                },
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font12.sp,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF85FF43),
              ),
            ),

            SizedBox(height: 16.h),

            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.w,
              runSpacing: 8.h,
              children: <Widget>[
                _ExamMiniPill(
                  text: 'percent_required'.trParams(
                    <String, String>{
                      'percent': exam.unlockCompletionPercent.toString(),
                    },
                  ),
                  icon: Icons.info_outline_rounded,
                  active: true,
                ),
                _ExamMiniPill(
                  text: 'locked'.tr,
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
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          18.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
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
              blurRadius: 16.r,
              offset: Offset(0, 7.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 54.r,
                  height: 54.r,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF81FF42),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        size: 20.r,
                        color: const Color(0xFF187000),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Text(
                    exam.courseName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.h),

            Text(
              exam.examTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font22.sp,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              exam.statusLabelKey.tr,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF86FF45),
              ),
            ),

            SizedBox(height: 18.h),

            CustomButton(
              onPressed: onStartTap,
              text: exam.actionLabelKey.tr,
              height: 48,
              width: double.infinity,
              showShadow: true,
              btnColor: AppColors.white,
              btnShadowColor: AppColors.black,
              borderColor: AppColors.black,
              textColor: AppColors.black,
              fontSize: AppFont.font14,
              fontWeight: FontWeight.w800,
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
      constraints: BoxConstraints(
        minHeight: 28.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF153B0A)
            : AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          width: 1,
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
            color: active
                ? const Color(0xFF83FF45)
                : const Color(0xFFA3A9A0),
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font11.sp,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: active
                    ? const Color(0xFF83FF45)
                    : const Color(0xFFA3A9A0),
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return pill;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: pill,
    );
  }
}