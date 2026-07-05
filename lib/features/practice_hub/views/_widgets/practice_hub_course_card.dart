import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final Color cardColor = isActive
        ? const Color(0xFF207400)
        : AppColors.white;
    final Color titleColor = isActive
        ? AppColors.white
        : const Color(0xFF6B6D70);
    final Color subtitleColor = isActive
        ? AppColors.white.withValues(alpha: 0.82)
        : const Color(0xFFA4A6A8);
    final Color labelColor = isActive
        ? AppColors.white
        : const Color(0xFF8D9092);
    final Color iconBackground = isActive
        ? AppColors.white.withValues(alpha: 0.22)
        : const Color(0xFFE8E9EA);
    final Color iconColor = isActive
        ? AppColors.white
        : const Color(0xFF777B7E);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : 264.w,
        height: 238.h,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(38.r),
          border: Border.all(
            color: isActive ? Colors.transparent : const Color(0xFFE4E4E4),
            width: 1.2.w,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isActive
                  ? const Color(0xFF124D00)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isActive ? 0 : 14.r,
              offset: Offset(0, isActive ? 6.h : 5.h),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 22.h,
              left: 22.w,
              child: Container(
                width: 51.r,
                height: 51.r,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 25.r,
                  color: iconColor,
                ),
              ),
            ),
            Positioned(
              top: 22.h,
              right: 22.w,
              child: _CourseStatusChip(
                status: course.statusLabel,
                isActive: isActive,
                isLocked: isLocked,
              ),
            ),
            Positioned(
              left: 22.w,
              right: 22.w,
              bottom: 25.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 23.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    course.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                  SizedBox(height: 27.h),
                  Row(
                    children: <Widget>[
                      Text(
                        'PROGRESS',
                        style: TextStyle(
                          fontSize: AppFont.font10.sp,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: labelColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        course.progressLabel,
                        style: TextStyle(
                          fontSize: AppFont.font11.sp,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 9.h),
                  _ProgressLine(
                    progress: course.progress,
                    isActive: isActive,
                  ),
                ],
              ),
            ),
          ],
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
      height: 25.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF8BFF4F) : const Color(0xFFE6E7E8),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isLocked) ...<Widget>[
            Icon(
              Icons.lock_outline_rounded,
              size: 10.r,
              color: const Color(0xFF777B7E),
            ),
            SizedBox(width: 3.w),
          ],
          Text(
            status,
            style: TextStyle(
              fontSize: AppFont.font11.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
              color: isActive
                  ? const Color(0xFF197100)
                  : const Color(0xFF6E7275),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.progress, required this.isActive});

  final double progress;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        height: 12.h,
        color: isActive
            ? AppColors.white.withValues(alpha: 0.32)
            : const Color(0xFFE6E7E8),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(height: 12.h, color: const Color(0xFF80FF43)),
        ),
      ),
    );
  }
}
