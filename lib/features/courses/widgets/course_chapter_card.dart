import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/course_models.dart';
import 'package:get/get.dart';

class CourseChapterCard extends StatelessWidget {
  final CourseChapterModel chapter;
  final VoidCallback? onTap;

  const CourseChapterCard({super.key, required this.chapter, this.onTap});

  bool get _isCompleted => chapter.state == CourseChapterState.completed;
  bool get _isCurrent => chapter.state == CourseChapterState.current;
  bool get _isLocked => chapter.state == CourseChapterState.locked;

  @override
  Widget build(BuildContext context) {
    if (_isCurrent) {
      return _CurrentChapterCard(chapter: chapter, onTap: onTap);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: kCourseDetailChapterHeight.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: _isLocked
              ? AppColors.coursesLockedCardBg
              : AppColors.coursesUnlockedCardBg,
          borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
          boxShadow: _isLocked
              ? const <BoxShadow>[]
              : <BoxShadow>[
                  BoxShadow(
                    color: AppColors.homeNeutralShadow,
                    blurRadius: 0,
                    offset: Offset(0, 5.h),
                  ),
                ],
        ),
        child: Opacity(
          opacity: _isLocked ? 0.72 : 1,
          child: Row(
            children: <Widget>[
              _ChapterIcon(chapter: chapter),
              SizedBox(width: 18.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (chapter.statusLabel != null) ...<Widget>[
                      Text(
                        chapter.statusLabel!,
                        style: TextStyle(
                          fontSize: AppFont.font12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                          letterSpacing: 1.8,
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                    Text(
                      chapter.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFont.font18.sp,
                        fontWeight: FontWeight.w700,
                        color: _isLocked
                            ? AppColors.coursesCardDisabledText
                            : AppColors.homePrimaryText,
                        height: 1.24,
                      ),
                    ),
                    if (chapter.subtitle.isNotEmpty) ...<Widget>[
                      SizedBox(height: 4.h),
                      Text(
                        chapter.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font15.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.bodyText,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (chapter.tagLabel != null) _Tag(label: chapter.tagLabel!),
              SizedBox(width: 12.w),
              Icon(
                _isLocked
                    ? Icons.lock_outline_rounded
                    : Icons.chevron_right_rounded,
                color: _isLocked
                    ? AppColors.coursesLockedIcon
                    : AppColors.coursesLockedIcon,
                size: 28.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentChapterCard extends StatelessWidget {
  final CourseChapterModel chapter;
  final VoidCallback? onTap;

  const _CurrentChapterCard({required this.chapter, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: kCourseDetailCurrentHeight.h,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.homeCardShadow,
              blurRadius: 24.r,
              offset: Offset(0, 16.h),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 65.w,
                  height: 65.w,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.24),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.white,
                    size: 30.w,
                  ),
                ),
                SizedBox(width: 22.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        chapter.statusLabel ?? 'current_study'.tr,
                        style: TextStyle(
                          fontSize: AppFont.font12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.homeLime,
                          letterSpacing: 1.8,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        chapter.title,
                        style: TextStyle(
                          fontSize: AppFont.font20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'progress'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homeLime,
                  ),
                ),
                Text(
                  'chapter_progress_100_round'.trParams(<String, String>{'progress': (chapter.progress * 100).round().toString()}),
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homeLime,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
              child: LinearProgressIndicator(
                value: chapter.progress,
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
                minHeight: 14.h,
                color: AppColors.homeLime,
                backgroundColor: AppColors.black.withValues(alpha: 0.18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterIcon extends StatelessWidget {
  final CourseChapterModel chapter;

  const _ChapterIcon({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = chapter.state == CourseChapterState.completed;
    final bool isLocked = chapter.state == CourseChapterState.locked;

    return Container(
      width: kCourseIconCircleSize.w,
      height: kCourseIconCircleSize.w,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.legacyColorFFE8F4DF
            : isLocked
            ? AppColors.coursesCardDisabledIconBg
            : AppColors.coursesChapterBlueBg,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCompleted
            ? Icons.check_circle_outline_rounded
            : isLocked
            ? Icons.lock_outline_rounded
            : Icons.bookmark_border_rounded,
        color: isCompleted
            ? AppColors.primaryGreen
            : isLocked
            ? AppColors.coursesLockedIcon
            : AppColors.coursesChapterBlue,
        size: 20.w,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    final bool isPro = label == 'PRO';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isPro ? AppColors.coursesProTagBg : AppColors.coursesFreeTagBg,
        borderRadius: BorderRadius.circular(kRadius10.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppFont.font10.sp,
          fontWeight: FontWeight.w900,
          color: isPro ? AppColors.coursesCreamText : AppColors.primaryGreen,
        ),
      ),
    );
  }
}
