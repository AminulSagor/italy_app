import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/chapter_detail_models.dart';

class ChapterResourceCard extends StatelessWidget {
  final ChapterResourceModel resource;
  final VoidCallback? onTap;

  const ChapterResourceCard({
    super.key,
    required this.resource,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBook = resource.iconName == 'book';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: kChapterResourceCardHeight.h,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: isBook
                    ? AppColors.chapterResourceBookBg
                    : AppColors.chapterResourceVocabBg,
                borderRadius: BorderRadius.circular(kRadius16.r),
              ),
              child: Icon(
                isBook ? Icons.menu_book_rounded : Icons.style_rounded,
                color: isBook
                    ? AppColors.chapterResourceBookText
                    : AppColors.chapterResourceVocabText,
                size: 28.w,
              ),
            ),
            8.h.verticalSpace,
            Text(
              resource.title,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.homePrimaryText,
              ),
            ),
            4.h.verticalSpace,
            Text(
              resource.subtitle,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.bodyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
