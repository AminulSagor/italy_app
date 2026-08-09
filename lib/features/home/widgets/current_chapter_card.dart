import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/home_models.dart';

class CurrentChapterCard extends StatelessWidget {
  const CurrentChapterCard({
    super.key,
    required this.chapter,
    this.onContinueTap,
  });

  final HomeChapterModel chapter;
  final VoidCallback? onContinueTap;

  @override
  Widget build(BuildContext context) {
    final double progress =
    chapter.progress.clamp(0.0, 1.0).toDouble();

    return Container(
      width: double.infinity,

      /*
       * No large forced min-height.
       *
       * Let the content determine the card height,
       * which makes the Home screen feel much lighter.
       */
      padding: EdgeInsets.fromLTRB(
        20.w,
        18.h,
        20.w,
        18.h,
      ),

      decoration: BoxDecoration(
        gradient: AppColors.homeChapterGradient,
        borderRadius: BorderRadius.circular(
          kHomeCardRadius.r,
        ),

        /*
         * Softer shadow.
         *
         * The old 24 blur / 12 offset made the card
         * visually heavier than the surrounding Home UI.
         */
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeCardShadow,
            blurRadius: 18.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          /*
           * Course / context label
           */
          _CourseLabel(
            text: chapter.courseTitle.isEmpty
                ? 'current_chapter'.tr
                : chapter.courseTitle.toUpperCase(),
          ),

          SizedBox(height: 10.h),

          /*
           * Main lesson title.
           *
           * This is the most important information,
           * so it gets the strongest visual weight.
           */
          Text(
            chapter.lessonTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              height: 1.16,
              letterSpacing: -0.2,
              color: AppColors.homePaleGreen,
            ),
          ),

          if (chapter.chapterTitle.isNotEmpty) ...<Widget>[
            SizedBox(height: 5.h),

            Row(
              children: <Widget>[
                Icon(
                  Icons.menu_book_rounded,
                  size: 14.r,
                  color: AppColors.homeBarLight,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    chapter.chapterTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: AppColors.homeBarLight,
                    ),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 16.h),

          /*
           * Progress header
           */
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'chapter_progress'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homePaleGreen,
                  ),
                ),
              ),

              /*
               * Percentage receives a little more
               * emphasis than the label.
               */
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 9.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.homeProgressTrack,
                  borderRadius: BorderRadius.circular(
                    kHomePillRadius.r,
                  ),
                ),
                child: Text(
                  chapter.progressLabel,
                  style: TextStyle(
                    fontSize: AppFont.font11.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.chatSeenText,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          /*
           * Lime is deliberately reserved for progress.
           *
           * That gives it a clear semantic meaning:
           * lime = advancement / active state.
           */
          ClipRRect(
            borderRadius: BorderRadius.circular(
              kHomePillRadius.r,
            ),
            child: LinearProgressIndicator(
              minHeight: 6.h,
              value: progress,
              backgroundColor:
              AppColors.homeProgressTrack,
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                AppColors.homeLime,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          /*
           * Compact primary action.
           *
           * White creates maximum contrast against
           * the green background without adding
           * another competing accent color.
           */
          CustomButton(
            onPressed: onContinueTap ?? () {},
            text: 'continue_learning'.tr,
            width: double.infinity,
            height: 46.h,
            icon: Icons.play_arrow_rounded,
            textColor: AppColors.primaryGreen,
            btnColor: AppColors.white,
            borderRadius: kHomePillRadius.r,
            fontSize: AppFont.font14.sp,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}

class _CourseLabel extends StatelessWidget {
  const _CourseLabel({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 7.r,
          height: 7.r,
          decoration: const BoxDecoration(
            color: AppColors.homeLime,
            shape: BoxShape.circle,
          ),
        ),

        SizedBox(width: 7.w),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font10.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: AppColors.homeBarLight,
            ),
          ),
        ),
      ],
    );
  }
}