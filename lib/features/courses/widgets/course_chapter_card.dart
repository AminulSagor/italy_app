import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/course_models.dart';

class CourseChapterCard extends StatelessWidget {
  final CourseChapterModel chapter;
  final VoidCallback? onTap;

  const CourseChapterCard({
    super.key,
    required this.chapter,
    this.onTap,
  });

  bool get _isCurrent =>
      chapter.state == CourseChapterState.current;

  bool get _isLocked =>
      chapter.state == CourseChapterState.locked;

  @override
  Widget build(BuildContext context) {
    if (_isCurrent) {
      return _CurrentChapterCard(
        chapter: chapter,
        onTap: onTap,
      );
    }

    return GestureDetector(
      onTap: _isLocked ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 94.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        decoration: BoxDecoration(
          color: _isLocked
              ? AppColors.coursesLockedCardBg
              : AppColors.coursesUnlockedCardBg,
          borderRadius: BorderRadius.circular(
            kCourseDetailCardRadius.r,
          ),
          boxShadow: _isLocked
              ? const <BoxShadow>[]
              : <BoxShadow>[
            BoxShadow(
              color: AppColors.homeNeutralShadow,
              blurRadius: 0,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Opacity(
          opacity: _isLocked ? 0.72 : 1,
          child: Row(
            children: <Widget>[
              _ChapterIcon(chapter: chapter),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    if (chapter.statusLabel != null &&
                        chapter.statusLabel!.trim().isNotEmpty)
                      ...<Widget>[
                        Text(
                          chapter.statusLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFont.font11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                            letterSpacing: 1.2,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],
                    Text(
                      chapter.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w700,
                        color: _isLocked
                            ? AppColors
                            .coursesCardDisabledText
                            : AppColors.homePrimaryText,
                        height: 1.25,
                      ),
                    ),
                    if (chapter.subtitle.trim().isNotEmpty)
                      ...<Widget>[
                        SizedBox(height: 4.h),
                        Text(
                          chapter.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFont.font13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.bodyText,
                            height: 1.2,
                          ),
                        ),
                      ],
                  ],
                ),
              ),
              if (chapter.tagLabel != null &&
                  chapter.tagLabel!.trim().isNotEmpty)
                ...<Widget>[
                  SizedBox(width: 8.w),
                  _Tag(label: chapter.tagLabel!),
                ],
              SizedBox(width: 8.w),
              Icon(
                _isLocked
                    ? Icons.lock_outline_rounded
                    : Icons.chevron_right_rounded,
                color: AppColors.coursesLockedIcon,
                size: 22.sp,
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

  const _CurrentChapterCard({
    required this.chapter,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
    chapter.progress.clamp(0.0, 1.0).toDouble();

    final int progressPercentage =
    (progress * 100).round();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(
            kCourseDetailCardRadius.r,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.homeCardShadow,
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 52.w,
                  height: 52.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(
                      alpha: 0.24,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.white,
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        chapter.statusLabel?.trim().isNotEmpty ==
                            true
                            ? chapter.statusLabel!
                            : 'current_study'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.homeLime,
                          letterSpacing: 1.2,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        chapter.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.white,
                  size: 24.sp,
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
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
                  'chapter_progress_percent'.trParams(
                    <String, String>{
                      'progress':
                      progressPercentage.toString(),
                    },
                  ),
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homeLime,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(
                kHomePillRadius.r,
              ),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9.h,
                color: AppColors.homeLime,
                backgroundColor:
                AppColors.black.withValues(alpha: 0.18),
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

  const _ChapterIcon({
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted =
        chapter.state == CourseChapterState.completed;

    final bool isLocked =
        chapter.state == CourseChapterState.locked;

    return Container(
      width: 44.w,
      height: 44.w,
      alignment: Alignment.center,
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
            ? Icons.check_rounded
            : isLocked
            ? Icons.lock_outline_rounded
            : Icons.bookmark_border_rounded,
        color: isCompleted
            ? AppColors.primaryGreen
            : isLocked
            ? AppColors.coursesLockedIcon
            : AppColors.coursesChapterBlue,
        size: 20.sp,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({
    required this.label,
  });

  bool get _isPro =>
      label.trim().toUpperCase() == 'PRO';

  String get _translatedLabel {
    switch (label.trim().toUpperCase()) {
      case 'PRO':
        return 'course_tag_pro'.tr;
      case 'FREE':
        return 'course_tag_free'.tr;
      default:
        return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: _isPro
            ? AppColors.coursesProTagBg
            : AppColors.coursesFreeTagBg,
        borderRadius: BorderRadius.circular(
          kRadius10.r,
        ),
      ),
      child: Text(
        _translatedLabel,
        maxLines: 1,
        style: TextStyle(
          fontSize: AppFont.font10.sp,
          fontWeight: FontWeight.w800,
          color: _isPro
              ? AppColors.coursesCreamText
              : AppColors.primaryGreen,
          height: 1.1,
        ),
      ),
    );
  }
}