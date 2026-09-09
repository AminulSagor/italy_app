import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../../courses/models/course_models.dart';

class PracticeHubCourseCard extends StatelessWidget {
  const PracticeHubCourseCard({
    required this.course,
    required this.onTap,
    this.fullWidth = false,
    super.key,
  });

  final CourseCardModel course;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final bool isActive = course.state == CourseCardState.active;
    final bool isLocked = course.state == CourseCardState.locked;

    final double progress = course.progress.clamp(0.0, 1.0);

    final Color cardColor =
    isActive ? const Color(0xFF207400) : AppColors.white;

    final Color titleColor =
    isActive ? AppColors.white : const Color(0xFF515457);

    final Color subtitleColor = isActive
        ? AppColors.white.withValues(alpha: 0.82)
        : const Color(0xFF85898C);

    final Color labelColor = isActive
        ? AppColors.white.withValues(alpha: 0.88)
        : const Color(0xFF767A7D);

    final Color iconBackground = isActive
        ? AppColors.white.withValues(alpha: 0.18)
        : const Color(0xFFF0F1F1);

    final Color iconColor =
    isActive ? AppColors.white : const Color(0xFF686D70);

    return Semantics(
      button: true,
      label: '${course.title}, ${course.statusLabel}',
      value: course.progressLabel,
      child: SizedBox(
        width: fullWidth ? double.infinity : 264.w,
        height: 240,
        child: Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(28.r),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28.r),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: isActive
                      ? Colors.transparent
                      : const Color(0xFFE2E4E5),
                  width: 1.w,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: isActive
                        ? const Color(0xFF124D00)
                        : Colors.black.withValues(alpha: 0.07),
                    blurRadius: isActive ? 0 : 12.r,
                    offset: Offset(0, isActive ? 5.h : 4.h),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  16.h,
                  16.w,
                  16.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            color: iconBackground,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 22.r,
                            color: iconColor,
                          ),
                        ),

                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _CourseStatusChip(
                              status: course.statusLabel,
                              isActive: isActive,
                              isLocked: isLocked,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // Course name receives the strongest visual priority.
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.sp,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.35,
                        color: titleColor,
                      ),
                    ),

                    if (course.subtitle.trim().isNotEmpty) ...<Widget>[
                      SizedBox(height: 6.h),
                      Text(
                        course.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font13.sp,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor,
                        ),
                      ),
                    ],

                    const Spacer(),

                    Row(
                      children: <Widget>[
                        Text(
                          'progress'.tr.toUpperCase(),
                          style: TextStyle(
                            fontSize: AppFont.font10.sp,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: labelColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          course.progressLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFont.font11.sp,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            color: labelColor,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 9.h),

                    _ProgressLine(
                      progress: progress,
                      progressLabel: course.progressLabel,
                      isActive: isActive,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseStatusChip extends StatelessWidget {
  const _CourseStatusChip({
    required this.status,
    required this.isActive,
    required this.isLocked,
  });

  final String status;
  final bool isActive;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 28.h,
        maxWidth: 130.w,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF9CFF68)
            : const Color(0xFFF0F1F1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isLocked) ...<Widget>[
            Icon(
              Icons.lock_outline_rounded,
              size: 13.r,
              color: const Color(0xFF686D70),
            ),
            SizedBox(width: 4.w),
          ],
          Flexible(
            child: Text(
              status.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font10.sp,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isActive
                    ? const Color(0xFF175E00)
                    : const Color(0xFF64686B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.progress,
    required this.progressLabel,
    required this.isActive,
  });

  final double progress;
  final String progressLabel;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'progress'.tr,
      value: progressLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999.r),
        child: SizedBox(
          height: 10.h,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: progress,
            ),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (
                BuildContext context,
                double animatedProgress,
                Widget? child,
                ) {
              return LinearProgressIndicator(
                value: animatedProgress,
                backgroundColor: isActive
                    ? AppColors.white.withValues(alpha: 0.25)
                    : const Color(0xFFE4E6E7),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF80FF43),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
